#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Variables
APP_DIR="/opt/flask_app"
REPO_URL="https://github.com/diyakou/serverTraffic.git"  # Adjusted to use Git directly
PYTHON_VERSION="3"
SERVICE_FILE="/etc/systemd/system/flask_app.service"

# Prompt the user for environment variables
read -p "Enter your name: " NAME
read -p "Enter your phone number: " PHONE
read -p "Enter the server IP address: " IP
read -p "Enter the traffic limit: " TRAFFIC

# Update package list and install dependencies
if [ -x "$(command -v apt)" ]; then
  apt update
  apt install -y python3 python3-venv git nginx python-is-python3
elif [ -x "$(command -v yum)" ]; then
  yum update -y
  yum install -y python3 python3-venv git nginx
else
  echo "Unsupported package manager. Please install dependencies manually."
  exit 1
fi

# Create application directory
mkdir -p $APP_DIR
cd $APP_DIR

# Clone the repository
git clone $REPO_URL .

# Set up virtual environment
python${PYTHON_VERSION} -m venv venv
source venv/bin/activate

# Install Python packages
pip install -r requirements.txt

# Create .env file with environment variables
cat <<EOF > $APP_DIR/.env
NAME=$NAME
PHONE=$PHONE
IP=$IP
TRAFFIC=$TRAFFIC
EOF

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

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to apply new service
systemctl daemon-reload
systemctl start flask_app
systemctl enable flask_app

# Configure Nginx
cat <<EOF > /etc/nginx/sites-available/flask_app
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
ln -s /etc/nginx/sites-available/flask_app /etc/nginx/sites-enabled

# Remove default Nginx site configuration if it exists
[ -e /etc/nginx/sites-enabled/default ] && rm /etc/nginx/sites-enabled/default

# Restart Nginx
systemctl restart nginx

# Open firewall ports if necessary
if [ -x "$(command -v ufw)" ]; then
  ufw allow 'Nginx Full'
elif [ -x "$(command -v firewall-cmd)" ]; then
  firewall-cmd --permanent --zone=public --add-service=http
  firewall-cmd --permanent --zone=public --add-service=https
  firewall-cmd --reload
fi

echo "Installation complete. Your Flask application should be running."
