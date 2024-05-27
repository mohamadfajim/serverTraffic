Sure, here's a beautiful and detailed README for your Flask application repository on GitHub:

---

# Flask Application Setup and Installation Script

This repository contains a Flask application along with an automated installation script to set up and configure the application on Ubuntu, Debian, or CentOS servers. The script installs all necessary dependencies, sets up the environment, and configures the server to run the Flask application seamlessly.

## Features

- Automated installation and setup
- Environment variable configuration through prompts
- Python virtual environment setup
- Systemd service configuration for application management
- Nginx configuration for reverse proxy setup
- Firewall configuration

## Prerequisites

Before running the installation script, ensure you have:

- Root access to the server
- Git installed on the server

## Installation

1. **Clone the repository:**
    ```sh
    git clone https://github.com/diyakou/serverTraffic.git
    cd yourflaskapp
    ```

2. **Make the installation script executable:**
    ```sh
    chmod +x install_flask_app.sh
    ```

3. **Run the installation script:**
    ```sh
    sudo ./install_flask_app.sh
    ```

4. **Follow the prompts to enter your configuration details:**
    - Enter your name
    - Enter your phone number
    - Enter the server IP address
    - Enter the traffic limit

## Script Details

The installation script performs the following tasks:

1. **Updates the package list and installs dependencies:**
    - Python 3.8
    - Python 3.8 venv
    - Git
    - Nginx

2. **Prompts the user for configuration details:**
    - Name
    - Phone number
    - Server IP address
    - Traffic limit

3. **Clones the repository and sets up the virtual environment:**
    - Clones the Flask application repository
    - Sets up a Python virtual environment
    - Installs required Python packages

4. **Creates a `.env` file with user-provided environment variables:**
    - Saves name, phone number, IP address, and traffic limit to `.env`

5. **Configures systemd to manage the Flask application:**
    - Creates a systemd service file for the Flask application
    - Reloads systemd and starts the Flask application service

6. **Configures Nginx as a reverse proxy:**
    - Sets up Nginx configuration to forward requests to the Flask application
    - Restarts Nginx

7. **Configures firewall rules if applicable:**
    - Opens HTTP/HTTPS ports in the firewall

## Usage

After the installation is complete, the Flask application should be running and accessible via the server's IP address.

- **To start the Flask application service:**
    ```sh
    sudo systemctl start flask_app
    ```

- **To stop the Flask application service:**
    ```sh
    sudo systemctl stop flask_app
    ```

- **To enable the Flask application service to start on boot:**
    ```sh
    sudo systemctl enable flask_app
    ```

## Troubleshooting

If you encounter any issues during the installation or setup process, check the following:

- Ensure all dependencies are installed correctly
- Verify the configuration details entered during the setup
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

---
