# Deployment Guide for Internal Server

This guide will help you deploy the application on your local server for internal users with VPN access restriction.

## Prerequisites

- Node.js (v18 or higher)
- npm or yarn
- Git
- VPN server configured for your network
- Server with network access

## Step 1: Clone the Lovable.dev Project

Lovable.dev projects can be cloned using their Git repository. To get the repository URL:

1. Visit: https://lovable.dev/projects/125a4fb9-d206-48cd-b774-08566e87cacd
2. Look for the "Clone" or "Download" option in the project
3. Copy the Git repository URL

Once you have the repository URL, clone it:

```bash
git clone <repository-url>
cd <project-directory>
```

## Step 2: Build the Application

Install dependencies and build the application:

```bash
# Install dependencies
npm install

# Build the production version
npm run build
```

## Step 3: Configure Network Access

### Option A: Using the Development Server (Quick Setup)

For quick internal testing, you can use the development server:

```bash
# Bind to all network interfaces to allow access from other machines
HOST=0.0.0.0 PORT=3000 npm run dev
```

### Option B: Using a Production Server (Recommended)

For production deployment, use a proper web server:

1. **Using serve (npm package)**:
```bash
# Install serve globally
npm install -g serve

# Serve the built application
serve -s dist -l 3000 --host 0.0.0.0
```

2. **Using PM2 (for process management)**:
```bash
# Install PM2 globally
npm install -g pm2

# Create ecosystem file (see ecosystem.config.js)
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save

# Setup PM2 to start on system boot
pm2 startup
```

### Firewall Configuration

Open port 3000 on your server:

```bash
# For Ubuntu/Debian with ufw
sudo ufw allow 3000/tcp

# For CentOS/RHEL with firewalld
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --reload
```

## Step 4: Restrict Access with VPN

To restrict access to VPN-connected users only:

### Method 1: Firewall Rules (Recommended)

Configure the firewall to only allow connections from the VPN subnet:

```bash
# For ufw (Ubuntu/Debian)
# Replace 10.8.0.0/24 with your VPN subnet
sudo ufw delete allow 3000/tcp  # Remove the previous rule
sudo ufw allow from 10.8.0.0/24 to any port 3000 proto tcp

# For firewalld (CentOS/RHEL)
sudo firewall-cmd --permanent --remove-port=3000/tcp
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.8.0.0/24" port protocol="tcp" port="3000" accept'
sudo firewall-cmd --reload
```

### Method 2: Bind to VPN Interface Only

Configure the application to listen only on the VPN interface:

```bash
# Replace 10.8.0.1 with your server's VPN IP address
HOST=10.8.0.1 PORT=3000 npm run dev
```

### Method 3: Reverse Proxy with Access Control

Use Nginx with IP-based access control:

```nginx
server {
    listen 3000;
    server_name <your-server-ip>;

    # Only allow VPN subnet
    allow 10.8.0.0/24;
    deny all;

    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## Step 5: Access the Application

Users can now access the application via:

```
http://<your-server-ip>:3000
```

**Note**: Users must be connected to the VPN to access the application.

## Monitoring and Maintenance

### Check Application Status (if using PM2)

```bash
pm2 status
pm2 logs
pm2 restart all
```

### View Application Logs

```bash
pm2 logs <app-name>
```

### Update the Application

```bash
# Pull latest changes
git pull origin main

# Rebuild
npm install
npm run build

# Restart (if using PM2)
pm2 restart all
```

## Troubleshooting

### Cannot Access from Other Machines

1. Check if the application is bound to `0.0.0.0` instead of `localhost`
2. Verify firewall rules allow traffic on port 3000
3. Ensure the VPN is properly configured
4. Check if the server IP is reachable from the client machine

### Port Already in Use

```bash
# Find process using port 3000
sudo lsof -i :3000

# Kill the process if needed
sudo kill -9 <PID>
```

### VPN Users Cannot Access

1. Verify VPN connection is active on client machine
2. Check firewall rules allow traffic from VPN subnet
3. Verify the VPN IP range matches the configured rules
4. Test connectivity: `ping <your-server-ip>` from client

## Security Recommendations

1. **Keep VPN credentials secure**: Ensure only authorized users have VPN access
2. **Regular updates**: Keep the application and dependencies updated
3. **HTTPS**: Consider setting up HTTPS with a reverse proxy (Nginx/Apache)
4. **Monitoring**: Set up logging and monitoring for security events
5. **Backup**: Regular backups of application data and configuration
