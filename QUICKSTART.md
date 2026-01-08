# Quick Start Guide

This guide provides a streamlined approach to deploying the application on your local server with VPN access restriction.

## Prerequisites Checklist

- [ ] Node.js v18+ installed
- [ ] npm or yarn installed
- [ ] Git installed
- [ ] VPN server configured on your network
- [ ] Server with network access
- [ ] VPN subnet information (e.g., 10.8.0.0/24)

## Quick Deployment (5 Minutes)

### Method 1: Automated Script (Recommended)

```bash
# Run the automated deployment script
bash deploy-server.sh
```

The script will:
1. Check prerequisites
2. Prompt for VPN configuration
3. Clone the Lovable.dev project
4. Install dependencies and build
5. Configure firewall (optional)
6. Start the application

### Method 2: Manual Deployment

#### 1. Clone the Lovable.dev Project

Visit https://lovable.dev/projects/125a4fb9-d206-48cd-b774-08566e87cacd and get the Git repository URL:

```bash
git clone <repository-url>
cd <project-directory>
```

#### 2. Install and Build

```bash
npm install
npm run build
```

#### 3. Configure VPN Access

Choose one of these methods:

**Option A: Firewall Rules (Recommended)**

```bash
# Ubuntu/Debian (ufw)
sudo ufw allow from 10.8.0.0/24 to any port 3000 proto tcp

# CentOS/RHEL (firewalld)
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.8.0.0/24" port protocol="tcp" port="3000" accept'
sudo firewall-cmd --reload
```

**Option B: Bind to VPN IP Only**

```bash
# Replace 10.8.0.1 with your server's VPN IP
HOST=10.8.0.1 PORT=3000 npm run dev
```

#### 4. Start the Application

**Development Server:**
```bash
HOST=0.0.0.0 PORT=3000 npm run dev
```

**Production with PM2:**
```bash
npm install -g pm2
pm2 start ecosystem.config.js
pm2 save
```

**Docker:**
```bash
docker-compose up -d
```

## Access the Application

Users can access via:
```
http://<your-server-ip>:3000
```

**Important:** Users must be connected to the VPN.

## Verification Steps

### 1. Check Application is Running

```bash
# Check if port 3000 is listening
sudo netstat -tlnp | grep 3000

# Or using ss
sudo ss -tlnp | grep 3000
```

### 2. Test VPN Access

**From VPN-connected machine:**
```bash
# Should return the application page
curl http://<your-server-ip>:3000

# Or open in browser
# http://<your-server-ip>:3000
```

**From non-VPN machine:**
```bash
# Should timeout or be refused
curl http://<your-server-ip>:3000
```

### 3. Monitor Application

**PM2:**
```bash
pm2 status
pm2 logs
```

**Docker:**
```bash
docker-compose ps
docker-compose logs -f
```

## Troubleshooting

### Issue: Cannot access from VPN

**Check 1: VPN connection**
```bash
# On client machine, verify VPN is active
ip addr show  # Look for VPN interface (tun0, wg0, etc.)
```

**Check 2: Firewall rules**
```bash
# Ubuntu/Debian
sudo ufw status numbered

# CentOS/RHEL
sudo firewall-cmd --list-all
```

**Check 3: Application binding**
```bash
# Verify app is listening on correct interface
sudo netstat -tlnp | grep 3000
```

### Issue: Port already in use

```bash
# Find and stop the process
sudo lsof -i :3000
sudo kill -9 <PID>
```

### Issue: Application crashes

**Check logs:**
```bash
# PM2
pm2 logs --err

# Docker
docker-compose logs

# Direct run
npm run dev  # Check console output
```

## Next Steps

- [ ] Test access from VPN-connected devices
- [ ] Set up SSL/TLS for HTTPS (see DEPLOYMENT.md)
- [ ] Configure automatic backups
- [ ] Set up monitoring and alerts
- [ ] Document VPN access procedure for users

## Getting Help

- See full deployment guide: `DEPLOYMENT.md`
- Check Nginx configuration: `nginx-vpn-config.conf`
- PM2 configuration: `ecosystem.config.js`
- Docker setup: `docker-compose.yml`

## Security Reminder

- ✓ Only VPN users can access the application
- ✓ Keep VPN credentials secure
- ✓ Regularly update the application
- ✓ Monitor access logs for unusual activity
- ✓ Use HTTPS in production
