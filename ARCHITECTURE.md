# Deployment Architecture

## Overview

This repository provides a complete deployment solution for running a Lovable.dev web application on a local server with VPN-restricted access.

```
┌─────────────────────────────────────────────────────────────┐
│                     Internet / Users                         │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ VPN Connection Required
                         │
┌────────────────────────▼────────────────────────────────────┐
│                    VPN Server                                │
│                  (10.8.0.0/24)                              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ Encrypted Tunnel
                         │
┌────────────────────────▼────────────────────────────────────┐
│               Firewall (ufw/firewalld)                      │
│         Allow: 10.8.0.0/24 → Port 3000                     │
│         Deny: All other traffic                             │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │
┌────────────────────────▼────────────────────────────────────┐
│            Application Server (Port 3000)                    │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Node.js Application (Lovable.dev Project)        │    │
│  │  - React/Vue/Angular frontend                      │    │
│  │  - Built with npm build                            │    │
│  │  - Served by Vite/webpack dev server or serve     │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Deployment Options

### Option 1: Development Server (Quick & Easy)
```
User → VPN → Firewall → Node.js Dev Server (port 3000)
```
**Pros:** Fast setup, hot reload, easy debugging
**Cons:** Not for production, less stable

### Option 2: PM2 Process Manager (Recommended)
```
User → VPN → Firewall → PM2 → Node.js App (port 3000)
```
**Pros:** Auto-restart, monitoring, logs, clustering
**Cons:** Requires PM2 installation

### Option 3: Docker (Isolated & Portable)
```
User → VPN → Firewall → Docker → Container (port 3000)
```
**Pros:** Isolated, reproducible, easy updates
**Cons:** Docker overhead, more complex

### Option 4: Nginx Reverse Proxy (Enterprise)
```
User → VPN → Firewall → Nginx (port 3000) → Node.js (port 3001)
```
**Pros:** SSL, caching, load balancing, security headers
**Cons:** More complex setup

## File Structure

```
System-Productivity/
├── README.md                      # Overview and quick links
├── QUICKSTART.md                  # 5-minute deployment guide
├── DEPLOYMENT.md                  # Comprehensive deployment docs
├── SECURITY.md                    # Security checklist and best practices
│
├── deploy-server.sh               # Automated deployment script
├── .env.example                   # Environment variables template
├── .gitignore                     # Git ignore patterns
│
├── ecosystem.config.js            # PM2 configuration
├── docker-compose.yml             # Docker Compose setup
├── Dockerfile                     # Docker image definition
├── nginx-vpn-config.conf          # Nginx reverse proxy config
└── system-productivity.service    # Systemd service file
```

## Deployment Workflow

```
┌─────────────────────────────────────────────────────────────┐
│ Step 1: Get the Lovable.dev Project                         │
│ Visit: lovable.dev/projects/125a4fb9-d206-48cd-b774-08566e87│
│ Clone the Git repository                                     │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│ Step 2: Install Dependencies                                 │
│ npm install                                                   │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│ Step 3: Build Application                                    │
│ npm run build                                                 │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│ Step 4: Configure VPN Restriction                            │
│ Option A: Firewall rules (recommended)                       │
│ Option B: Bind to VPN interface                              │
│ Option C: Nginx proxy with access control                    │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│ Step 5: Start Application                                    │
│ Choose: Dev Server / PM2 / Docker / Systemd                 │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│ Step 6: Verify & Test                                        │
│ - Test VPN access (should work)                              │
│ - Test non-VPN access (should fail)                          │
│ - Monitor logs and performance                               │
└─────────────────────────────────────────────────────────────┘
```

## Security Layers

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: VPN Authentication                                  │
│ - Strong encryption (WireGuard/OpenVPN)                     │
│ - User credentials required                                  │
│ - Session management                                         │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│ Layer 2: Network Firewall                                    │
│ - Port 3000 restricted to VPN subnet                        │
│ - All other traffic blocked                                  │
│ - Connection logging                                         │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│ Layer 3: Application Security                                │
│ - HTTPS/TLS (optional via Nginx)                            │
│ - Security headers                                           │
│ - Rate limiting (optional)                                   │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│ Layer 4: Monitoring & Logging                                │
│ - Access logs                                                │
│ - Error logs                                                 │
│ - Security audit logs                                        │
└─────────────────────────────────────────────────────────────┘
```

## Quick Start Commands

### Automated (Easiest)
```bash
bash deploy-server.sh
```

### Manual PM2
```bash
git clone <lovable-repo-url>
cd <project-dir>
npm install && npm run build
pm2 start ecosystem.config.js
```

### Manual Docker
```bash
git clone <lovable-repo-url>
cd <project-dir>
docker-compose up -d
```

### Manual Development
```bash
git clone <lovable-repo-url>
cd <project-dir>
npm install
HOST=0.0.0.0 PORT=3000 npm run dev
```

## Network Topology

```
┌────────────────────────────────────────────────────────┐
│                    Corporate Network                    │
│                                                         │
│  ┌──────────────┐         ┌──────────────┐            │
│  │   User PC    │         │   User PC    │            │
│  │ (VPN Client) │         │ (VPN Client) │            │
│  └──────┬───────┘         └──────┬───────┘            │
│         │                        │                     │
│         └────────────┬───────────┘                     │
│                      │                                 │
│              ┌───────▼────────┐                        │
│              │  VPN Server    │                        │
│              │  10.8.0.1      │                        │
│              └───────┬────────┘                        │
│                      │                                 │
│              ┌───────▼────────┐                        │
│              │ App Server     │                        │
│              │ Port 3000      │                        │
│              │ 10.8.0.100     │                        │
│              └────────────────┘                        │
│                                                         │
└────────────────────────────────────────────────────────┘
```

## Access Control Matrix

| Source | VPN Connected | Port 3000 Access | Result |
|--------|---------------|------------------|--------|
| Internal User | ✅ Yes | ✅ Allowed | ✅ Access Granted |
| Internal User | ❌ No | ❌ Blocked | ❌ Connection Refused |
| External User | ❌ No | ❌ Blocked | ❌ Connection Timeout |
| External User | ✅ Yes (via VPN) | ✅ Allowed | ✅ Access Granted |

## Troubleshooting Flow

```
Cannot Access Application
         │
         ▼
Is VPN connected? ─────No─────▶ Connect to VPN
         │Yes
         ▼
Can ping server? ─────No──────▶ Check network/VPN
         │Yes
         ▼
Port 3000 open? ──────No──────▶ Check firewall rules
         │Yes
         ▼
Is app running? ──────No──────▶ Start application
         │Yes
         ▼
Check app logs ───────────────▶ Review for errors
```

## Maintenance Schedule

| Frequency | Task | Command |
|-----------|------|---------|
| Daily | Check app status | `pm2 status` or `docker-compose ps` |
| Daily | Review logs | `pm2 logs` or `docker-compose logs` |
| Weekly | Update dependencies | `npm update && npm audit fix` |
| Weekly | Check VPN logs | Review VPN server logs |
| Monthly | Security audit | `npm audit` + review access |
| Monthly | Backup configs | Backup all configuration files |
| Quarterly | Full review | Complete security checklist |

## Key Features

✅ **Multiple Deployment Methods**: Choose what works best for your infrastructure
✅ **VPN-Restricted Access**: Only authorized VPN users can access
✅ **Automated Setup**: Single script deployment option
✅ **Production Ready**: PM2, Docker, and systemd configurations
✅ **Security Focused**: Multiple security layers and best practices
✅ **Well Documented**: Comprehensive guides for all scenarios
✅ **Easy Maintenance**: Clear procedures for updates and monitoring

## Support Resources

- **Quick Start**: See `QUICKSTART.md`
- **Full Guide**: See `DEPLOYMENT.md`
- **Security**: See `SECURITY.md`
- **Lovable Project**: https://lovable.dev/projects/125a4fb9-d206-48cd-b774-08566e87cacd
