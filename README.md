# System-Productivity

Internal application deployment with VPN-restricted access.

## Overview

This repository contains deployment configurations and documentation for running a web application on a local server with VPN access restriction. Users can access the application at `http://<your-server-ip>:3000` only when connected to the VPN.

## Quick Start

Get up and running in 5 minutes:

```bash
bash deploy-server.sh
```

See [QUICKSTART.md](QUICKSTART.md) for detailed quick start instructions.

## Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Fast deployment guide (5 minutes)
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Comprehensive deployment documentation
- **[ecosystem.config.js](ecosystem.config.js)** - PM2 process manager configuration
- **[docker-compose.yml](docker-compose.yml)** - Docker deployment setup
- **[nginx-vpn-config.conf](nginx-vpn-config.conf)** - Nginx reverse proxy with VPN restriction

## Features

- ✅ Clone and build Lovable.dev project
- ✅ Serve on local network (port 3000)
- ✅ VPN access restriction
- ✅ Multiple deployment methods (PM2, Docker, direct)
- ✅ Automated setup script
- ✅ Firewall configuration
- ✅ Production-ready configurations

## Deployment Methods

### 1. Automated Script (Recommended)
```bash
bash deploy-server.sh
```

### 2. PM2 Process Manager
```bash
npm install
npm run build
pm2 start ecosystem.config.js
```

### 3. Docker
```bash
docker-compose up -d
```

### 4. Development Server
```bash
npm install
HOST=0.0.0.0 PORT=3000 npm run dev
```

## VPN Access Restriction

The application is configured to only allow access from users connected to the VPN. This is achieved through:

1. **Firewall rules** - Restrict port 3000 to VPN subnet only
2. **Application binding** - Bind to VPN interface IP address
3. **Reverse proxy** - Use Nginx with IP-based access control

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed configuration.

## Requirements

- Node.js v18 or higher
- npm or yarn
- Git
- VPN server configured on your network
- Server with network access

## Getting the Lovable.dev Project

1. Visit: https://lovable.dev/projects/125a4fb9-d206-48cd-b774-08566e87cacd
2. Get the Git repository URL
3. Clone using the deployment script or manually

## Security

- Only VPN-connected users can access the application
- Firewall rules restrict access to VPN subnet
- Supports HTTPS with reverse proxy
- Regular security updates recommended

## Support

For issues or questions:
1. Check [DEPLOYMENT.md](DEPLOYMENT.md) troubleshooting section
2. Review application logs
3. Verify VPN connection and firewall rules

## License

See the license in the cloned Lovable.dev project repository.