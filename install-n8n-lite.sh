#!/bin/bash

# N8N Installation Script for Ubuntu 22 VPS with Security Hardening
# Author: Auto-generated installer
# Version: 1.0

set -e  # Exit on any error

# ASCII Art Banner
clear
echo -e "\033[0;36m"
cat << "EOF"
░▒▓███████▓▒░░▒▓█▓▒░▒▓███████▓▒░ ░▒▓██████▓▒░ ░▒▓██████▓▒░ ░▒▓██████▓▒░  
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓███████▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓███████▓▒░░▒▓███████▓▒░░▒▓███████▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓███████▓▒░ ░▒▓██████▓▒░ ░▒▓██████▓▒░ ░▒▓██████▓▒░  

═══════════════════════════════════════════════════════════════════════════════════════════════════════════
                                    🚀 UBUNTU 22 VPS SECURITY INSTALLER 🚀                                    
                                        Created by: RID999                                                 
═══════════════════════════════════════════════════════════════════════════════════════════════════════════
EOF
echo -e "\033[0m"

echo -e "\033[1;32m"
echo "🔧 Features included:"
echo "   ✅ N8N Workflow Automation"
echo "   🔒 Advanced Security Hardening"
echo "   🛡️  UFW Firewall + Fail2Ban"
echo "   📊 Monitoring & Log Rotation"
echo "   🚀 Auto-restart & Health Checks"
echo ""
echo -e "\033[1;33m⚠️  This script will modify your system security settings!"
echo -e "\033[1;36m🎯 Target Port: 5551"
echo -e "\033[0m"

# Confirmation prompt
echo -ne "\033[1;37mDo you want to continue with the installation? (y/N): \033[0m"
read -r CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo -e "\033[1;31mInstallation cancelled.\033[0m"
    exit 1
fi

echo ""
echo -e "\033[1;32m🚀 Starting installation...\033[0m"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
N8N_PORT=5551
N8N_USER="n8n"
N8N_HOME="/home/$N8N_USER"

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root (use sudo)"
fi

log "Starting N8N installation with security hardening..."

# System update and upgrade
log "Updating system packages..."
apt update -y
apt upgrade -y

# Install essential packages
log "Installing essential packages..."
apt install -y curl wget git build-essential software-properties-common apt-transport-https ca-certificates gnupg lsb-release ufw fail2ban unattended-upgrades

# Configure automatic security updates
log "Configuring automatic security updates..."
echo 'Unattended-Upgrade::Automatic-Reboot "false";' >> /etc/apt/apt.conf.d/50unattended-upgrades
echo 'Unattended-Upgrade::Remove-Unused-Dependencies "true";' >> /etc/apt/apt.conf.d/50unattended-upgrades
systemctl enable unattended-upgrades

# Install Node.js (LTS version)
log "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt install -y nodejs

# Verify Node.js installation
node_version=$(node --version)
npm_version=$(npm --version)
log "Node.js version: $node_version"
log "NPM version: $npm_version"

# Create n8n user
log "Creating n8n user..."
if ! id "$N8N_USER" &>/dev/null; then
    useradd -m -s /bin/bash $N8N_USER
    log "User $N8N_USER created successfully"
else
    log "User $N8N_USER already exists"
fi

# Configure UFW Firewall
log "Configuring UFW firewall..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing

# Allow SSH (check current SSH port)
SSH_PORT=$(ss -tlnp | grep sshd | awk '{print $4}' | cut -d':' -f2 | head -n1)
if [ -z "$SSH_PORT" ]; then
    SSH_PORT=22
fi
ufw allow $SSH_PORT/tcp comment 'SSH'

# Allow N8N port with rate limiting
ufw allow $N8N_PORT/tcp comment 'N8N Application'

# Enable firewall
ufw --force enable

# Configure Fail2Ban
log "Configuring Fail2Ban..."
cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
backend = systemd

[sshd]
enabled = true
port = $SSH_PORT
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600

[n8n-bruteforce]
enabled = true
port = $N8N_PORT
filter = n8n-bruteforce
logpath = /var/log/n8n/n8n.log
maxretry = 5
bantime = 7200
EOF

# Create Fail2Ban filter for N8N
mkdir -p /etc/fail2ban/filter.d
cat > /etc/fail2ban/filter.d/n8n-bruteforce.conf << EOF
[Definition]
failregex = ^.*Authentication failed.*<HOST>.*$
            ^.*Invalid credentials.*<HOST>.*$
            ^.*Login attempt failed.*<HOST>.*$
ignoreregex =
EOF

# Restart and enable Fail2Ban
systemctl restart fail2ban
systemctl enable fail2ban

# Install N8N globally
log "Installing N8N..."
npm install -g n8n

# Create N8N directories
log "Setting up N8N directories..."
mkdir -p /var/log/n8n
mkdir -p $N8N_HOME/.n8n
chown -R $N8N_USER:$N8N_USER /var/log/n8n
chown -R $N8N_USER:$N8N_USER $N8N_HOME

# Create N8N configuration
log "Creating N8N configuration..."
cat > $N8N_HOME/.n8n/config << EOF
N8N_PORT=$N8N_PORT
N8N_HOST=0.0.0.0
N8N_PROTOCOL=http
WEBHOOK_URL=http://$(curl -s ifconfig.me):$N8N_PORT/
N8N_LOG_LEVEL=info
N8N_LOG_OUTPUT=file
N8N_LOG_FILE=/var/log/n8n/n8n.log
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=$(openssl rand -base64 12)
DB_TYPE=sqlite
EOF

chown $N8N_USER:$N8N_USER $N8N_HOME/.n8n/config

# Create systemd service
log "Creating N8N systemd service..."
cat > /etc/systemd/system/n8n.service << EOF
[Unit]
Description=n8n workflow automation
After=network.target

[Service]
Type=simple
User=$N8N_USER
ExecStart=/usr/bin/n8n start
EnvironmentFile=$N8N_HOME/.n8n/config
Restart=on-failure
RestartSec=5
StandardOutput=append:/var/log/n8n/n8n.log
StandardError=append:/var/log/n8n/n8n.log

# Security settings
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=/home/$N8N_USER
ProtectKernelTunables=yes
ProtectKernelModules=yes
ProtectControlGroups=yes

[Install]
WantedBy=multi-user.target
EOF

# Set up log rotation
log "Setting up log rotation..."
cat > /etc/logrotate.d/n8n << EOF
/var/log/n8n/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 644 $N8N_USER $N8N_USER
    postrotate
        systemctl reload n8n
    endscript
}
EOF

# Enable and start N8N service
log "Starting N8N service..."
systemctl daemon-reload
systemctl enable n8n
systemctl start n8n

# Wait for service to start
sleep 5

# Check service status
if systemctl is-active --quiet n8n; then
    log "N8N service started successfully"
else
    error "N8N service failed to start"
fi

# Security hardening
log "Applying additional security hardening..."

# Disable root login via SSH (if not already disabled)
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Disable password authentication (uncomment if you have SSH keys set up)
# sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Restart SSH service
systemctl restart sshd

# Set up basic monitoring
log "Setting up basic monitoring..."
cat > /usr/local/bin/n8n-monitor.sh << 'EOF'
#!/bin/bash
if ! systemctl is-active --quiet n8n; then
    echo "$(date): N8N service is down, attempting restart" >> /var/log/n8n/monitor.log
    systemctl restart n8n
fi
EOF

chmod +x /usr/local/bin/n8n-monitor.sh

# Add monitoring to crontab
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/n8n-monitor.sh") | crontab -

# Get server IP
SERVER_IP=$(curl -s ifconfig.me)

# Display installation summary
echo
log "============================================="
log "N8N INSTALLATION COMPLETED SUCCESSFULLY!"
log "============================================="
echo
log "N8N Configuration:"
log "  URL: http://$SERVER_IP:$N8N_PORT"
log "  Port: $N8N_PORT"
log "  User: $N8N_USER"
echo
log "Security Features Enabled:"
log "  ✓ UFW Firewall configured"
log "  ✓ Fail2Ban protection active"
log "  ✓ Automatic security updates"
log "  ✓ Service hardening applied"
log "  ✓ Log rotation configured"
log "  ✓ Basic monitoring enabled"
echo
log "Authentication:"
AUTH_USER=$(grep N8N_BASIC_AUTH_USER $N8N_HOME/.n8n/config | cut -d'=' -f2)
AUTH_PASS=$(grep N8N_BASIC_AUTH_PASSWORD $N8N_HOME/.n8n/config | cut -d'=' -f2)
log "  Username: $AUTH_USER"
log "  Password: $AUTH_PASS"
echo
log "Useful Commands:"
log "  Check status: systemctl status n8n"
log "  View logs: tail -f /var/log/n8n/n8n.log"
log "  Restart service: systemctl restart n8n"
log "  Firewall status: ufw status"
log "  Fail2ban status: fail2ban-client status"
echo
warn "IMPORTANT: Save your authentication credentials!"
warn "Change the default password after first login!"
echo
log "Installation completed successfully!"
log "Access N8N at: http://$SERVER_IP:$N8N_PORT"
