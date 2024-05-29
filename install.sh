#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Variables
APP_DIR="/opt/flask_app"
REPO_URL="https://github.com/diyakou/serverTraffic.git"
PYTHON_VERSION="3"
SERVICE_FILE="/etc/systemd/system/flask_app.service"
NGINX_CONFIG="/etc/nginx/sites-available/flask_app"
NGINX_CONFIG_ENABLED="/etc/nginx/sites-enabled/flask_app"
LOG_DIR="/var/log/flask_app"

# Prompt the user for environment variables
read -p "Enter your name: " NAME
read -p "Enter your phone number: " PHONE
read -p "Enter the server IP address: " IP
read -p "Enter the traffic limit: " TRAFFIC

# Update package list and install dependencies
if [ -x "$(command -v apt)" ]; then
  apt update
  apt install -y python3 python3-venv git nginx python-is-python3 || { echo "Failed to install dependencies"; exit 1; }
elif [ -x "$(command -v yum)" ]; then
  yum update -y
  yum install -y python3 python3-venv git nginx || { echo "Failed to install dependencies"; exit 1; }
else
  echo "Unsupported package manager. Please install dependencies manually."
  exit 1
fi

# Create application directory
mkdir -p $APP_DIR || { echo "Failed to create application directory"; exit 1; }
cd $APP_DIR || { echo "Failed to change directory"; exit 1; }

# Clone the repository
git clone $REPO_URL . || { echo "Failed to clone repository"; exit 1; }

# Set up virtual environment
python${PYTHON_VERSION} -m venv venv || { echo "Failed to create virtual environment"; exit 1; }
source venv/bin/activate || { echo "Failed to activate virtual environment"; exit 1; }

# Install Python packages
pip install -r requirements.txt || { echo "Failed to install Python packages"; exit 1; }

# Create .env file with environment variables
cat <<EOF > $APP_DIR/.env
NAME=$NAME
PHONE=$PHONE
IP=$IP
TRAFFIC=$TRAFFIC
EOF

# Ensure the log directory exists and set permissions
mkdir -p $LOG_DIR || { echo "Failed to create log directory"; exit 1; }
chown www-data:www-data $LOG_DIR || { echo "Failed to set permissions on log directory"; exit 1; }

# Create systemd service
cat <<EOF > $SERVICE_FILE
[Unit]
Description=Gunicorn instance to serve flask_app
After=network.target

[Service]
User=root
Group=www-data
WorkingDirectory=$APP_DIR
Environment="PATH=$APP_DIR/venv/bin"
EnvironmentFile=$APP_DIR/.env
ExecStart=$APP_DIR/venv/bin/gunicorn --workers 3 --bind unix:$APP_DIR/flask_app.sock wsgi:app

# Logging settings
StandardOutput=append:$LOG_DIR/gunicorn.log
StandardError=append:$LOG_DIR/gunicorn_error.log

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to apply new service
systemctl daemon-reload || { echo "Failed to reload systemd"; exit 1; }
systemctl start flask_app || { echo "Failed to start flask_app service"; exit 1; }
systemctl enable flask_app || { echo "Failed to enable flask_app service"; exit 1; }

# Configure Nginx
cat <<EOF > $NGINX_CONFIG
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://unix:$APP_DIR/flask_app.sock;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Enable the Nginx site configuration
ln -s $NGINX_CONFIG $NGINX_CONFIG_ENABLED || { echo "Failed to enable Nginx site configuration"; exit 1; }

# Remove default Nginx site configuration if it exists
[ -e /etc/nginx/sites-enabled/default ] && rm /etc/nginx/sites-enabled/default || echo "Default Nginx site configuration does not exist"

# Restart Nginx
systemctl restart nginx || { echo "Failed to restart Nginx"; exit 1; }

# Open firewall ports if necessary
if [ -x "$(command -v ufw)" ]; then
  ufw allow 'Nginx Full' || { echo "Failed to open firewall ports using ufw"; exit 1; }
elif [ -x "$(command -v firewall-cmd)" ]; then
  firewall-cmd --permanent --zone=public --add-service=http || { echo "Failed to add HTTP service to firewall"; exit 1; }
  firewall-cmd --permanent --zone=public --add-service=https || { echo "Failed to add HTTPS service to firewall"; exit 1; }
  firewall-cmd --reload || { echo "Failed to reload firewall"; exit 1; }
else
  echo "No known firewall manager found. Please configure your firewall manually."
fi

echo "Installation complete. Your Flask application should be running."
