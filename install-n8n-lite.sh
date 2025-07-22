#!/bin/bash

# N8N Docker Installation Script for Ubuntu 22 VPS (1GB RAM Optimized)
# Author: Auto-generated installer
# Version: 2.0 - Docker Edition

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
                             🐳 DOCKER N8N - 1GB VPS OPTIMIZED INSTALLER 🐳                                    
                                        Created by: RIDWAN                                                   
═══════════════════════════════════════════════════════════════════════════════════════════════════════════
EOF
echo -e "\033[0m"

echo -e "\033[1;32m"
echo "🔧 Optimized Features for 1GB VPS:"
echo "   🐳 Docker N8N (Lightweight)"
echo "   💾 Memory Optimized (~300MB RAM)"
echo "   🔒 Essential Security Only"
echo "   🛡️  UFW Firewall + Basic Protection"
echo "   📊 Minimal Logging"
echo "   🚀 Auto-restart & Health Checks"
echo ""
echo -e "\033[1;33m⚠️  Optimized for low-resource VPS (1GB RAM)!"
echo -e "\033[1;36m🎯 Target Port: 5551"
echo -e "\033[0m"

# Confirmation prompt
echo -ne "\033[1;37mDo you want to continue with the Docker installation? (y/N): \033[0m"
read -r CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo -e "\033[1;31mInstallation cancelled.\033[0m"
    exit 1
fi

echo ""
echo -e "\033[1;32m🚀 Starting Docker N8N installation...\033[0m"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
N8N_PORT=5551
N8N_DATA_DIR="/opt/n8n-data"
DOCKER_COMPOSE_DIR="/opt/n8n"

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

# Check available memory
TOTAL_MEM=$(free -m | awk 'NR==2{printf "%.0f", $2}')
if [ "$TOTAL_MEM" -lt 900 ]; then
    error "Insufficient memory. This script requires at least 1GB RAM. Current: ${TOTAL_MEM}MB"
fi

log "System Memory: ${TOTAL_MEM}MB - OK for Docker N8N"

# System update (minimal for faster deployment)
log "Quick system update..."
apt update -y
apt upgrade -y --with-new-pkgs

# Install essential packages only
log "Installing essential packages..."
apt install -y curl wget ufw fail2ban htop unattended-upgrades

# Configure automatic security updates (lightweight)
log "Configuring automatic security updates..."
echo 'Unattended-Upgrade::Automatic-Reboot "false";' >> /etc/apt/apt.conf.d/50unattended-upgrades
systemctl enable unattended-upgrades

# Install Docker
log "Installing Docker..."
curl -fsSL https://get.docker.com | sh
systemctl start docker
systemctl enable docker

# Install Docker Compose
log "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Verify Docker installation
docker --version
docker-compose --version

# Configure UFW Firewall (minimal rules)
log "Configuring UFW firewall..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing

# Allow SSH (detect current port)
SSH_PORT=$(ss -tlnp | grep sshd | awk '{print $4}' | cut -d':' -f2 | head -n1)
if [ -z "$SSH_PORT" ]; then
    SSH_PORT=22
fi
ufw allow $SSH_PORT/tcp comment 'SSH'

# Allow N8N port
ufw allow $N8N_PORT/tcp comment 'N8N Docker'

# Enable firewall
ufw --force enable

# Configure Fail2Ban (lightweight)
log "Configuring Fail2Ban..."
cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 1800
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = $SSH_PORT
maxretry = 3
bantime = 3600
EOF

systemctl restart fail2ban
systemctl enable fail2ban

# Create N8N directories
log "Setting up N8N directories..."
mkdir -p $N8N_DATA_DIR
mkdir -p $DOCKER_COMPOSE_DIR
mkdir -p /var/log/n8n

# Generate secure credentials
N8N_USER="admin"
N8N_PASSWORD=$(openssl rand -base64 12)
WEBHOOK_URL="http://$(curl -s ifconfig.me):$N8N_PORT/"

# Create optimized docker-compose.yml for 1GB VPS
log "Creating Docker Compose configuration..."
cat > $DOCKER_COMPOSE_DIR/docker-compose.yml << EOF
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "$N8N_PORT:5678"
    environment:
      # Basic Configuration
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - WEBHOOK_URL=$WEBHOOK_URL
      
      # Memory Optimization
      - NODE_OPTIONS=--max-old-space-size=512
      - N8N_LOG_LEVEL=warn
      - N8N_LOG_OUTPUT=console
      
      # Security
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=$N8N_USER
      - N8N_BASIC_AUTH_PASSWORD=$N8N_PASSWORD
      
      # Database (SQLite for minimal resource usage)
      - DB_TYPE=sqlite
      - DB_SQLITE_DATABASE=/home/node/.n8n/database.sqlite
      
      # Performance Tweaks for 1GB VPS
      - N8N_DISABLE_UI=false
      - N8N_METRICS=false
      - N8N_DIAGNOSTICS_ENABLED=false
      
      # Generic Timezone
      - GENERIC_TIMEZONE=Asia/Jakarta
      - TZ=Asia/Jakarta
      
    volumes:
      - $N8N_DATA_DIR:/home/node/.n8n
    
    # Resource limits for 1GB VPS
    deploy:
      resources:
        limits:
          memory: 400M
        reservations:
          memory: 200M
    
    # Health check
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:5678/healthz"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
EOF

# Create systemd service for docker-compose
log "Creating systemd service..."
cat > /etc/systemd/system/n8n-docker.service << EOF
[Unit]
Description=N8N Docker Container
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$DOCKER_COMPOSE_DIR
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

# Set up log rotation (minimal)
log "Setting up log rotation..."
cat > /etc/logrotate.d/n8n-docker << EOF
/var/lib/docker/containers/*/*-json.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
}
EOF

# Enable and start services
log "Starting N8N Docker container..."
systemctl daemon-reload
systemctl enable n8n-docker
systemctl start n8n-docker

# Wait for container to start
log "Waiting for N8N to initialize..."
sleep 30

# Check if container is running
if docker ps | grep -q "n8n"; then
    log "N8N Docker container started successfully"
else
    error "N8N Docker container failed to start. Check logs: docker logs n8n"
fi

# Memory optimization tweaks
log "Applying memory optimization..."

# Reduce system swappiness for better performance on 1GB VPS
echo "vm.swappiness=10" >> /etc/sysctl.conf
echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf
sysctl -p

# Create monitoring script (lightweight)
log "Setting up lightweight monitoring..."
cat > /usr/local/bin/n8n-docker-monitor.sh << 'EOF'
#!/bin/bash
LOG_FILE="/var/log/n8n/monitor.log"

# Check if container is running
if ! docker ps | grep -q "n8n"; then
    echo "$(date): N8N container is down, attempting restart" >> $LOG_FILE
    cd /opt/n8n && docker-compose up -d
    sleep 10
    
    # Check if restart was successful
    if docker ps | grep -q "n8n"; then
        echo "$(date): N8N container restart successful" >> $LOG_FILE
    else
        echo "$(date): N8N container restart failed" >> $LOG_FILE
    fi
fi

# Check memory usage
MEM_USAGE=$(docker stats --no-stream --format "{{.MemPerc}}" n8n 2>/dev/null | sed 's/%//')
if [ ! -z "$MEM_USAGE" ] && [ "$(echo "$MEM_USAGE > 80" | bc 2>/dev/null)" = "1" ]; then
    echo "$(date): High memory usage: ${MEM_USAGE}%" >> $LOG_FILE
fi
EOF

chmod +x /usr/local/bin/n8n-docker-monitor.sh

# Add monitoring to crontab (every 10 minutes)
(crontab -l 2>/dev/null; echo "*/10 * * * * /usr/local/bin/n8n-docker-monitor.sh") | crontab -

# Create useful management scripts
log "Creating management scripts..."

# Start script
cat > /usr/local/bin/n8n-start << 'EOF'
#!/bin/bash
cd /opt/n8n && docker-compose up -d
EOF
chmod +x /usr/local/bin/n8n-start

# Stop script
cat > /usr/local/bin/n8n-stop << 'EOF'
#!/bin/bash
cd /opt/n8n && docker-compose down
EOF
chmod +x /usr/local/bin/n8n-stop

# Restart script
cat > /usr/local/bin/n8n-restart << 'EOF'
#!/bin/bash
cd /opt/n8n && docker-compose restart
EOF
chmod +x /usr/local/bin/n8n-restart

# Logs script
cat > /usr/local/bin/n8n-logs << 'EOF'
#!/bin/bash
docker logs -f n8n
EOF
chmod +x /usr/local/bin/n8n-logs

# Status script
cat > /usr/local/bin/n8n-status << 'EOF'
#!/bin/bash
echo "=== N8N Container Status ==="
docker ps | grep n8n
echo ""
echo "=== N8N Container Stats ==="
docker stats --no-stream n8n
echo ""
echo "=== System Memory ==="
free -h
EOF
chmod +x /usr/local/bin/n8n-status

# Get server IP
SERVER_IP=$(curl -s ifconfig.me)

# Final system info
FINAL_MEM=$(free -m | awk 'NR==2{printf "%.0f", $3}')
CONTAINER_MEM=$(docker stats --no-stream --format "{{.MemUsage}}" n8n 2>/dev/null || echo "N/A")

# Display installation summary
echo
log "============================================="
log "N8N DOCKER INSTALLATION COMPLETED!"
log "============================================="
echo
log "N8N Configuration:"
log "  🌐 URL: http://$SERVER_IP:$N8N_PORT"
log "  🔌 Port: $N8N_PORT"
log "  🐳 Container: n8n"
log "  💾 Data Dir: $N8N_DATA_DIR"
echo
log "System Resources:"
log "  📊 Total RAM: ${TOTAL_MEM}MB"
log "  🔥 Used RAM: ${FINAL_MEM}MB"
log "  🐳 N8N Memory: $CONTAINER_MEM"
echo
log "Security Features:"
log "  ✓ UFW Firewall active"
log "  ✓ Fail2Ban protection"
log "  ✓ Auto security updates"
log "  ✓ Container isolation"
echo
log "Authentication:"
log "  👤 Username: $N8N_USER"
log "  🔑 Password: $N8N_PASSWORD"
echo
log "Management Commands:"
log "  ▶️  Start: n8n-start"
log "  ⏹️  Stop: n8n-stop"
log "  🔄 Restart: n8n-restart"
log "  📋 Status: n8n-status"
log "  📝 Logs: n8n-logs"
echo
log "Docker Commands:"
log "  Status: docker ps"
log "  Logs: docker logs n8n"
log "  Stats: docker stats n8n"
echo
warn "IMPORTANT NOTES FOR 1GB VPS:"
warn "• Save your credentials: $N8N_USER / $N8N_PASSWORD"
warn "• Monitor memory usage with: n8n-status"
warn "• N8N limited to ~400MB RAM usage"
warn "• Avoid running complex workflows simultaneously"
echo
log "🎉 Installation completed successfully!"
log "🌐 Access N8N at: http://$SERVER_IP:$N8N_PORT"
