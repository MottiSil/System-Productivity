#!/bin/bash

# Setup script for deploying the application on local server
# This script helps automate the deployment process

set -e

echo "==================================="
echo "System Productivity App - Deployment Setup"
echo "==================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "Warning: Running as root. Consider running as a non-root user with sudo privileges."
    echo ""
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "Step 1: Checking prerequisites..."

if ! command_exists node; then
    echo "Error: Node.js is not installed. Please install Node.js v18 or higher."
    exit 1
fi

if ! command_exists npm; then
    echo "Error: npm is not installed. Please install npm."
    exit 1
fi

if ! command_exists git; then
    echo "Error: Git is not installed. Please install Git."
    exit 1
fi

echo "✓ Node.js $(node --version)"
echo "✓ npm $(npm --version)"
echo "✓ Git $(git --version)"
echo ""

# Get VPN subnet from user
echo "Step 2: VPN Configuration"
read -p "Enter your VPN subnet (e.g., 10.8.0.0/24) [press Enter to skip]: " VPN_SUBNET
echo ""

# Get server VPN IP
read -p "Enter your server's VPN IP address [press Enter to skip]: " SERVER_VPN_IP
echo ""

# Ask deployment method
echo "Step 3: Choose deployment method"
echo "1) Development server (quick setup)"
echo "2) Production with PM2 (recommended)"
echo "3) Docker deployment"
read -p "Enter choice [1-3]: " DEPLOY_METHOD
echo ""

# Clone the repository if needed
echo "Step 4: Repository Setup"
if [ ! -f "package.json" ]; then
    echo "package.json not found. Please clone the Lovable.dev project first:"
    echo "Visit: https://lovable.dev/projects/125a4fb9-d206-48cd-b774-08566e87cacd"
    read -p "Enter the Git repository URL: " REPO_URL
    echo "Cloning repository..."
    git clone "$REPO_URL" lovable-app
    cd lovable-app
else
    echo "✓ Repository already exists"
fi
echo ""

# Install dependencies
echo "Step 5: Installing dependencies..."
npm install
echo ""

# Build the application
echo "Step 6: Building application..."
npm run build
echo ""

# Configure firewall if VPN subnet provided
if [ -n "$VPN_SUBNET" ]; then
    echo "Step 7: Configuring firewall..."
    
    if command_exists ufw; then
        echo "Detected ufw firewall"
        read -p "Configure ufw to allow traffic only from VPN subnet? (y/n): " CONFIGURE_UFW
        if [ "$CONFIGURE_UFW" = "y" ]; then
            sudo ufw allow from "$VPN_SUBNET" to any port 3000 proto tcp
            echo "✓ Firewall configured for VPN subnet: $VPN_SUBNET"
        fi
    elif command_exists firewall-cmd; then
        echo "Detected firewalld"
        read -p "Configure firewalld to allow traffic only from VPN subnet? (y/n): " CONFIGURE_FIREWALLD
        if [ "$CONFIGURE_FIREWALLD" = "y" ]; then
            sudo firewall-cmd --permanent --add-rich-rule="rule family=\"ipv4\" source address=\"$VPN_SUBNET\" port protocol=\"tcp\" port=\"3000\" accept"
            sudo firewall-cmd --reload
            echo "✓ Firewall configured for VPN subnet: $VPN_SUBNET"
        fi
    else
        echo "No supported firewall detected (ufw/firewalld). Please configure manually."
    fi
    echo ""
fi

# Deploy based on chosen method
echo "Step 8: Starting application..."

case $DEPLOY_METHOD in
    1)
        echo "Starting development server..."
        if [ -n "$SERVER_VPN_IP" ]; then
            echo "Binding to VPN IP: $SERVER_VPN_IP"
            HOST="$SERVER_VPN_IP" PORT=3000 npm run dev &
        else
            echo "Binding to all interfaces (0.0.0.0)"
            HOST=0.0.0.0 PORT=3000 npm run dev &
        fi
        echo "✓ Development server started in background"
        ;;
    2)
        echo "Setting up PM2..."
        if ! command_exists pm2; then
            echo "Installing PM2..."
            npm install -g pm2
        fi
        
        # Update ecosystem.config.js if VPN IP provided
        if [ -n "$SERVER_VPN_IP" ]; then
            sed -i "s/HOST: '0.0.0.0'/HOST: '$SERVER_VPN_IP'/g" ecosystem.config.js
        fi
        
        pm2 start ecosystem.config.js
        pm2 save
        echo "✓ Application started with PM2"
        echo ""
        echo "Useful PM2 commands:"
        echo "  pm2 status          - Check application status"
        echo "  pm2 logs            - View logs"
        echo "  pm2 restart all     - Restart application"
        echo "  pm2 startup         - Configure PM2 to start on boot"
        ;;
    3)
        echo "Starting with Docker..."
        if ! command_exists docker; then
            echo "Error: Docker is not installed. Please install Docker first."
            exit 1
        fi
        
        docker-compose up -d
        echo "✓ Application started with Docker"
        echo ""
        echo "Useful Docker commands:"
        echo "  docker-compose ps           - Check container status"
        echo "  docker-compose logs -f      - View logs"
        echo "  docker-compose restart      - Restart application"
        echo "  docker-compose down         - Stop application"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "==================================="
echo "Deployment Complete!"
echo "==================================="
echo ""

# Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "Access the application at: http://$SERVER_IP:3000"

if [ -n "$VPN_SUBNET" ]; then
    echo ""
    echo "⚠️  IMPORTANT: Access is restricted to VPN subnet: $VPN_SUBNET"
    echo "Users must be connected to the VPN to access the application."
fi

echo ""
echo "For more information, see DEPLOYMENT.md"
