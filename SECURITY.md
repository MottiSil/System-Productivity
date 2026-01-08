# Security Checklist

Use this checklist to ensure your deployment is secure.

## Pre-Deployment Security

- [ ] VPN server is properly configured and secured
- [ ] VPN uses strong encryption (OpenVPN, WireGuard, etc.)
- [ ] VPN credentials are distributed securely
- [ ] Server OS is up to date with security patches
- [ ] Firewall is enabled on the server

## Network Security

- [ ] Port 3000 is restricted to VPN subnet only
- [ ] No other unnecessary ports are exposed
- [ ] VPN subnet is correctly configured in firewall rules
- [ ] Test access from non-VPN machines (should be blocked)
- [ ] Test access from VPN-connected machines (should work)

## Application Security

- [ ] Application dependencies are up to date (`npm audit`)
- [ ] Environment variables are properly secured
- [ ] No sensitive data in configuration files
- [ ] `.env` files are in `.gitignore`
- [ ] Build is production-optimized (`NODE_ENV=production`)

## Access Control

- [ ] Only authorized users have VPN credentials
- [ ] VPN user accounts are reviewed regularly
- [ ] Revoke VPN access for former employees immediately
- [ ] Implement VPN session timeouts if possible
- [ ] Monitor VPN connection logs

## Server Hardening

- [ ] SSH is secured (key-based auth, non-standard port)
- [ ] Fail2ban or similar is configured
- [ ] Automatic security updates are enabled
- [ ] Minimal services are running
- [ ] Server logs are monitored

## Application Hardening

- [ ] Application runs as non-root user
- [ ] File permissions are properly set
- [ ] HTTPS is configured (if using reverse proxy)
- [ ] Security headers are configured (if using reverse proxy)
- [ ] Rate limiting is implemented (if applicable)

## Monitoring and Logging

- [ ] Application logs are being collected
- [ ] Access logs are being monitored
- [ ] Failed access attempts are logged
- [ ] Set up alerts for unusual activity
- [ ] Regular log reviews are scheduled

## Backup and Recovery

- [ ] Regular backups are configured
- [ ] Backup restoration process is tested
- [ ] Backups are stored securely (encrypted)
- [ ] Disaster recovery plan is documented
- [ ] Configuration files are backed up

## Maintenance

- [ ] Schedule regular security updates
- [ ] Document update procedure
- [ ] Test updates in staging environment first
- [ ] Have rollback plan for failed updates
- [ ] Keep inventory of installed software/versions

## Compliance

- [ ] Security policies are documented
- [ ] Access logs retention policy is defined
- [ ] Data handling procedures are documented
- [ ] Incident response plan is created
- [ ] Regular security audits are scheduled

## Post-Deployment Verification

Run these checks after deployment:

### 1. Port Access Test
```bash
# From VPN-connected machine (should work)
curl http://<server-ip>:3000

# From non-VPN machine (should fail)
curl http://<server-ip>:3000 --connect-timeout 5
```

### 2. Firewall Status
```bash
# Ubuntu/Debian
sudo ufw status verbose

# CentOS/RHEL
sudo firewall-cmd --list-all
```

### 3. Application Security
```bash
# Check for vulnerable dependencies
npm audit

# Fix vulnerabilities
npm audit fix
```

### 4. Process Status
```bash
# Check application is running as correct user
ps aux | grep node

# Verify not running as root
```

### 5. Network Binding
```bash
# Verify application is bound to correct interface
sudo netstat -tlnp | grep 3000
```

## Regular Security Tasks

### Daily
- Review access logs for unusual activity
- Check application status and health

### Weekly
- Review VPN connection logs
- Check for application updates
- Review security alerts

### Monthly
- Run `npm audit` and update dependencies
- Review user access list
- Test backup restoration
- Review firewall rules

### Quarterly
- Full security audit
- Update documentation
- Review and test disaster recovery plan
- Security training for team

## Incident Response

If a security incident is detected:

1. **Immediate Actions**
   - Disconnect affected systems if necessary
   - Document everything
   - Notify security team/management

2. **Investigation**
   - Review logs for suspicious activity
   - Identify affected systems and data
   - Determine attack vector

3. **Containment**
   - Block malicious IPs in firewall
   - Revoke compromised credentials
   - Isolate affected systems

4. **Recovery**
   - Restore from clean backups if needed
   - Update all credentials
   - Apply security patches

5. **Post-Incident**
   - Document lessons learned
   - Update security procedures
   - Conduct security review

## Resources

- OWASP Top 10: https://owasp.org/www-project-top-ten/
- Node.js Security Best Practices: https://nodejs.org/en/docs/guides/security/
- VPN Security Guide: Consult your VPN provider documentation
- CIS Benchmarks: https://www.cisecurity.org/cis-benchmarks/

## Emergency Contacts

Document your emergency contacts:

- [ ] Network Administrator: _______________
- [ ] Security Team: _______________
- [ ] VPN Provider Support: _______________
- [ ] On-call Developer: _______________
- [ ] Management Contact: _______________
