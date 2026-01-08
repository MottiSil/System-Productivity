# Troubleshooting Guide

Common issues and solutions when deploying the application.

## Table of Contents

1. [VPN Connection Issues](#vpn-connection-issues)
2. [Port Access Problems](#port-access-problems)
3. [Application Won't Start](#application-wont-start)
4. [Performance Issues](#performance-issues)
5. [Docker Problems](#docker-problems)
6. [PM2 Issues](#pm2-issues)
7. [Network Configuration](#network-configuration)
8. [Build and Dependencies](#build-and-dependencies)

---

## VPN Connection Issues

### Problem: Cannot connect to VPN

**Symptoms:**
- VPN client shows connection failed
- Cannot ping VPN server
- VPN client stuck on "connecting"

**Solutions:**

1. **Verify VPN server is running:**
```bash
# On VPN server
sudo systemctl status openvpn
# or for WireGuard
sudo systemctl status wg-quick@wg0
```

2. **Check VPN credentials:**
- Verify username and password
- Check certificate expiration
- Ensure client config is up to date

3. **Test VPN port connectivity:**
```bash
# From client machine
telnet <vpn-server-ip> <vpn-port>
# or
nc -zv <vpn-server-ip> <vpn-port>
```

4. **Review VPN logs:**
```bash
# OpenVPN
sudo journalctl -u openvpn

# WireGuard
sudo journalctl -u wg-quick@wg0
```

### Problem: VPN connects but cannot access application

**Symptoms:**
- VPN shows connected
- Can ping VPN server
- Cannot access http://<server-ip>:3000

**Solutions:**

1. **Verify you got a VPN IP:**
```bash
# On client machine
ip addr show  # Look for tun0, wg0, or similar interface
# Should show an IP in VPN subnet (e.g., 10.8.0.x)
```

2. **Check routing:**
```bash
# Verify route to application server
ip route get <server-vpn-ip>
```

3. **Test connectivity to server:**
```bash
# Ping application server VPN IP
ping <server-vpn-ip>

# Test port 3000 specifically
telnet <server-vpn-ip> 3000
# or
nc -zv <server-vpn-ip> 3000
```

4. **Check VPN split tunneling:**
- Ensure VPN routes traffic to application server
- May need to disable split tunneling or add specific routes

---

## Port Access Problems

### Problem: Port 3000 connection refused

**Symptoms:**
- `curl: (7) Failed to connect to <ip> port 3000: Connection refused`
- Browser shows "Connection refused"

**Solutions:**

1. **Verify application is running:**
```bash
# Check if anything is listening on port 3000
sudo netstat -tlnp | grep 3000
# or
sudo ss -tlnp | grep 3000
```

2. **If nothing is listening, start the application:**
```bash
# PM2
pm2 start ecosystem.config.js

# Docker
docker-compose up -d

# Direct
HOST=0.0.0.0 PORT=3000 npm run dev
```

3. **Check application logs:**
```bash
# PM2
pm2 logs

# Docker
docker-compose logs -f

# Systemd
sudo journalctl -u system-productivity -f
```

### Problem: Port 3000 connection timeout

**Symptoms:**
- `curl: (28) Connection timed out`
- Browser keeps loading, then times out

**Solutions:**

1. **Check firewall rules:**
```bash
# Ubuntu/Debian (ufw)
sudo ufw status numbered

# CentOS/RHEL (firewalld)
sudo firewall-cmd --list-all
```

2. **Verify firewall allows VPN subnet:**
```bash
# Should see rule like:
# allow from 10.8.0.0/24 to any port 3000

# If not, add it:
# ufw
sudo ufw allow from 10.8.0.0/24 to any port 3000 proto tcp

# firewalld
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.8.0.0/24" port protocol="tcp" port="3000" accept'
sudo firewall-cmd --reload
```

3. **Check if application is bound to correct interface:**
```bash
sudo netstat -tlnp | grep 3000
# Should show 0.0.0.0:3000 or <vpn-ip>:3000
# NOT 127.0.0.1:3000 (localhost only)
```

4. **If bound to localhost only:**
- Update environment: `HOST=0.0.0.0`
- Restart application

### Problem: Port 3000 already in use

**Symptoms:**
- `Error: listen EADDRINUSE: address already in use :::3000`
- Application fails to start

**Solutions:**

1. **Find process using port 3000:**
```bash
sudo lsof -i :3000
# or
sudo netstat -tlnp | grep 3000
```

2. **Stop the conflicting process:**
```bash
# Get PID from above command, then:
sudo kill <PID>

# If process won't stop:
sudo kill -9 <PID>
```

3. **Or use a different port:**
```bash
PORT=3001 npm run dev
```

---

## Application Won't Start

### Problem: npm install fails

**Symptoms:**
- Errors during `npm install`
- Missing dependencies
- Permission errors

**Solutions:**

1. **Clear npm cache:**
```bash
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

2. **Check Node.js version:**
```bash
node --version
# Should be v18 or higher
```

3. **Fix permission issues:**
```bash
# Don't use sudo for npm install
# If you did, fix permissions:
sudo chown -R $USER:$USER .
```

4. **Check disk space:**
```bash
df -h
# Ensure adequate space available
```

### Problem: npm run build fails

**Symptoms:**
- Build errors
- TypeScript errors
- Out of memory errors

**Solutions:**

1. **Increase Node.js memory:**
```bash
NODE_OPTIONS="--max-old-space-size=4096" npm run build
```

2. **Check for syntax errors:**
```bash
npm run lint
# Fix any reported errors
```

3. **Clear build cache:**
```bash
rm -rf dist/ .cache/ node_modules/.cache/
npm run build
```

4. **Check dependencies:**
```bash
npm audit fix
npm update
```

### Problem: Application crashes on startup

**Symptoms:**
- Application starts then immediately exits
- Error in logs about missing modules or configuration

**Solutions:**

1. **Check logs for error details:**
```bash
# PM2
pm2 logs --err

# Docker
docker-compose logs

# Direct run (see console output)
npm run dev
```

2. **Verify environment variables:**
```bash
# Check .env file exists and is valid
cat .env

# Ensure required variables are set
```

3. **Verify build was successful:**
```bash
ls -la dist/
# Should contain built files
```

4. **Test with development server first:**
```bash
npm run dev
# If this works, issue is with production build
```

---

## Performance Issues

### Problem: Slow response times

**Solutions:**

1. **Check server resources:**
```bash
# CPU usage
top

# Memory usage
free -h

# Disk I/O
iostat -x 1
```

2. **Check application logs for errors:**
```bash
pm2 logs
```

3. **Monitor network latency:**
```bash
# From client
ping <server-ip>
```

4. **Consider using production build:**
```bash
# Development builds are slower
npm run build
npm run preview
```

### Problem: High memory usage

**Solutions:**

1. **Restart application:**
```bash
pm2 restart all
# or
docker-compose restart
```

2. **Configure memory limits:**
```javascript
// In ecosystem.config.js
max_memory_restart: '512M'  // Adjust as needed
```

3. **Check for memory leaks:**
```bash
# Monitor memory over time
pm2 monit
```

---

## Docker Problems

### Problem: Docker build fails

**Solutions:**

1. **Check Docker is installed and running:**
```bash
docker --version
sudo systemctl status docker
```

2. **Clean Docker cache:**
```bash
docker system prune -a
```

3. **Build with no cache:**
```bash
docker-compose build --no-cache
```

### Problem: Container won't start

**Solutions:**

1. **Check logs:**
```bash
docker-compose logs -f
```

2. **Check container status:**
```bash
docker-compose ps
```

3. **Rebuild container:**
```bash
docker-compose down
docker-compose up -d --build
```

### Problem: Cannot access containerized app

**Solutions:**

1. **Verify port mapping:**
```bash
docker-compose ps
# Should show 0.0.0.0:3000->3000/tcp
```

2. **Check container network:**
```bash
docker network ls
docker network inspect <network-name>
```

3. **Verify firewall allows Docker:**
```bash
# Docker should handle this, but verify:
sudo ufw status
```

---

## PM2 Issues

### Problem: PM2 command not found

**Solutions:**

```bash
# Install PM2 globally
npm install -g pm2

# Or use npx
npx pm2 status
```

### Problem: Application not restarting after crash

**Solutions:**

1. **Check PM2 configuration:**
```javascript
// In ecosystem.config.js
autorestart: true  // Should be true
```

2. **Check error logs:**
```bash
pm2 logs --err
```

3. **Reset PM2:**
```bash
pm2 delete all
pm2 start ecosystem.config.js
```

### Problem: PM2 doesn't start on boot

**Solutions:**

```bash
# Generate startup script
pm2 startup

# Follow the instructions output by above command
# Then save current processes
pm2 save
```

---

## Network Configuration

### Problem: Cannot determine server IP

**Solutions:**

```bash
# List all IPs
hostname -I

# VPN interface IP
ip addr show | grep -A 2 "tun0\|wg0"

# Or check specific interface
ip addr show eth0
```

### Problem: Firewall rules not working

**Solutions:**

1. **Verify firewall is enabled:**
```bash
# ufw
sudo ufw status

# firewalld
sudo systemctl status firewalld
```

2. **Check rule order (first match wins):**
```bash
sudo ufw status numbered
```

3. **Reset and reapply rules:**
```bash
# BE CAREFUL - this removes all rules
# Ensure you have console access first
sudo ufw reset
sudo ufw default deny incoming
sudo ufw allow from 10.8.0.0/24 to any port 3000
sudo ufw enable
```

---

## Build and Dependencies

### Problem: Outdated dependencies

**Solutions:**

```bash
# Check for updates
npm outdated

# Update all
npm update

# Update specific package
npm update <package-name>

# Check for security issues
npm audit
npm audit fix
```

### Problem: Dependency conflicts

**Solutions:**

```bash
# Try force resolution
npm install --legacy-peer-deps

# Or clean install
rm -rf node_modules package-lock.json
npm install
```

---

## General Diagnostic Commands

### Check Everything Script

```bash
#!/bin/bash
echo "=== System Info ==="
uname -a
echo ""

echo "=== Node.js Version ==="
node --version
echo ""

echo "=== Application Status ==="
pm2 status
echo ""

echo "=== Port 3000 Status ==="
sudo netstat -tlnp | grep 3000
echo ""

echo "=== Firewall Status ==="
sudo ufw status
echo ""

echo "=== VPN Interface ==="
ip addr show | grep -A 2 "tun\|wg"
echo ""

echo "=== Recent Logs ==="
pm2 logs --lines 20
echo ""

echo "=== Disk Space ==="
df -h
echo ""

echo "=== Memory ==="
free -h
```

Save as `diagnostic.sh` and run with `bash diagnostic.sh`

---

## Getting Help

If none of these solutions work:

1. **Gather diagnostic information:**
   - Output of `diagnostic.sh` script above
   - Full error messages and logs
   - Steps to reproduce the issue

2. **Check documentation:**
   - `DEPLOYMENT.md` for deployment details
   - `SECURITY.md` for security configuration
   - `QUICKSTART.md` for basic setup

3. **Common log locations:**
   - PM2: `~/.pm2/logs/`
   - Docker: `docker-compose logs`
   - Systemd: `journalctl -u system-productivity`
   - Nginx: `/var/log/nginx/`
   - VPN: `/var/log/openvpn/` or `journalctl`

4. **Test in isolation:**
   - Try running without PM2/Docker
   - Test without VPN restriction first
   - Verify each component separately
