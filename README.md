Sure, I'll create a README similar to the one in the provided repository. The README will include installation instructions that prompt the user for configuration details during the setup process.

### README.md

```markdown
# Flask Server Traffic Monitor

This repository contains a Flask application for monitoring server traffic, complete with an automated installation script that sets up the application on Ubuntu, Debian, or CentOS servers.

## Features

- Automated installation and setup
- Interactive prompts for configuration details
- Python virtual environment setup
- Systemd service configuration for application management
- Nginx configuration for reverse proxy setup
- Firewall configuration

## Prerequisites

Before running the installation script, ensure you have:

- Root access to the server
- Git installed on the server

## Installation

Follow these steps to install and configure the Flask Server Traffic Monitor:

### Step 1: Clone the Repository

```sh
git clone https://github.com/diyakou/serverTraffic.git
cd serverTraffic
```

### Step 2: Run the Installation Script

Make the installation script executable and run it:

```sh
chmod +x install.sh
sudo ./install.sh
```

### Step 3: Follow the Prompts

The script will prompt you for the following configuration details:

- **Name:** Your name
- **Phone Number:** Your phone number
- **Server IP Address:** The IP address of the server
- **Traffic Limit:** The traffic limit in bytes

### Example Prompts

```sh
Enter your name: John Doe
Enter your phone number: 123-456-7890
Enter the server IP address: 192.168.1.1
Enter the traffic limit: 2321231
```

## Usage

After the installation is complete, the Flask application should be running and accessible via the server's IP address.

### Managing the Flask Application Service

- **Start the service:**
  ```sh
  sudo systemctl start flask_app
  ```

- **Stop the service:**
  ```sh
  sudo systemctl stop flask_app
  ```

- **Enable the service to start on boot:**
  ```sh
  sudo systemctl enable flask_app
  ```

### Accessing the Application

Open a web browser and navigate to `http://<your-server-ip>` to access the Flask Server Traffic Monitor.

## Troubleshooting

If you encounter any issues during the installation or setup process, check the following:

- Ensure all dependencies are installed correctly.
- Verify the configuration details entered during the setup.
- Check the status of the systemd service:
  ```sh
  sudo systemctl status flask_app
  ```

- Check the Nginx error logs for any configuration issues:
  ```sh
  sudo tail -f /var/log/nginx/error.log
  ```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Flask](https://flask.palletsprojects.com/) - The web framework used
- [Gunicorn](https://gunicorn.org/) - The WSGI HTTP Server used
- [Nginx](https://www.nginx.com/) - The reverse proxy server used
- [psutil](https://github.com/giampaolo/psutil) - The library for system and process utilities
```

### Installation Script (`install_flask_app.sh`)

```bash
#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Variables
APP_DIR="/opt/flask_app"
REPO_URL="https://github.com/diyakou/serverTraffic.git"
PYTHON_VERSION="3.8"
SERVICE_FILE="/etc/systemd/system/flask_app.service"

# Prompt the user for environment variables
read -p "Enter your name: " NAME
read -p "Enter your phone number: " PHONE
read -p "Enter the server IP address: " IP
read -p "Enter the traffic limit: " TRAFFIC

# Update package list and install dependencies
if [ -x "$(command -v apt)" ]; then
  apt update
  apt install -y python$PYTHON_VERSION python$PYTHON_VERSION-venv git nginx
elif [ -x "$(command -v yum)" ]; then
  yum update -y
  yum install -y python$PYTHON_VERSION python$PYTHON_VERSION-venv git nginx
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
python$PYTHON_VERSION -m venv venv
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

# Remove default Nginx site configuration
rm /etc/nginx/sites-enabled/default

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
```

### Explanation:

- **README.md:** Provides a detailed overview of the project, installation steps, usage instructions, and troubleshooting tips.
- **Installation Script:** Automates the setup process by prompting the user for necessary configuration details and setting up the Flask application along with the necessary services and configurations.
