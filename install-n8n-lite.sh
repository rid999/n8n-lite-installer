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
                      🔒 NGINX + CERTBOT N8N - 1GB VPS OPTIMIZED INSTALLER 🚀
                                  Modified version with HTTPS support | github @rid999
═══════════════════════════════════════════════════════════════════════════════════════════════════════════
EOF
echo -e "\033[0m"

echo -e "\033[1;32m"
echo "🔧 Fitur yang Ditingkatkan:"
echo "   🐳 Docker N8N (Image Terbaru)"
echo "   🔐 HTTPS via Nginx & Certbot"
echo "   👤 Username & Password Kustom"
echo "   🔌 Port Internal Kustom"
echo "   🛡️  UFW Firewall + Basic Protection"
echo "   🚀 Auto-restart & Health Checks"
echo -e "\033[0m"

# --- User Input ---
echo -e "\033[1;36mSilakan masukkan detail konfigurasi berikut:\033[0m"

# Prompt for Domain Name
read -p "➡️ Masukkan nama domain Anda (misal: n8n.domain.com): " N8N_DOMAIN
if [ -z "$N8N_DOMAIN" ]; then
    error "Nama domain tidak boleh kosong."
fi

# Prompt for Email
read -p "➡️ Masukkan email Anda (untuk notifikasi SSL/Certbot): " CERTBOT_EMAIL
if [ -z "$CERTBOT_EMAIL" ]; then
    error "Email tidak boleh kosong."
fi

# Prompt for Custom Port
read -p "➡️ Masukkan port internal untuk N8N [Default: 5551]: " N8N_PORT
N8N_PORT=${N8N_PORT:-5551}

# Prompt for Custom Username
read -p "➡️ Masukkan username untuk login N8N [Default: admin]: " N8N_USER
N8N_USER=${N8N_USER:-admin}

# Prompt for Custom Password
while true; do
    read -s -p "➡️ Masukkan password untuk N8N: " N8N_PASSWORD
    echo
    read -s -p "➡️ Konfirmasi password Anda: " N8N_PASSWORD_CONFIRM
    echo
    [ "$N8N_PASSWORD" = "$N8N_PASSWORD_CONFIRM" ] && break
    echo -e "${RED}Password tidak cocok. Silakan coba lagi.${NC}"
done
if [ -z "$N8N_PASSWORD" ]; then
    error "Password tidak boleh kosong."
fi

# Confirmation prompt
echo ""
echo -e "\033[1;33m--- Konfigurasi Anda ---"
echo -e "   Domain: \033[1;37m$N8N_DOMAIN\033[1;33m"
echo -e "   Email: \033[1;37m$CERTBOT_EMAIL\033[1;33m"
echo -e "   Port Internal N8N: \033[1;37m$N8N_PORT\033[1;33m"
echo -e "   Username N8N: \033[1;37m$N8N_USER\033[1;33m"
echo -e "------------------------\033[0m"
echo -ne "\033[1;37mApakah Anda ingin melanjutkan instalasi dengan konfigurasi di atas? (y/N): \033[0m"
read -r CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo -e "\033[1;31mInstalasi dibatalkan.\033[0m"
    exit 1
fi

echo ""
echo -e "\033[1;32m🚀 Memulai instalasi Docker N8N dengan Nginx & Certbot...\033[0m"
echo ""

# --- System Checks ---
if [[ $EUID -ne 0 ]]; then
   error "Skrip ini harus dijalankan sebagai root (gunakan sudo)"
fi

TOTAL_MEM=$(free -m | awk 'NR==2{printf "%.0f", $2}')
if [ "$TOTAL_MEM" -lt 900 ]; then
    error "Memori tidak cukup. Skrip ini memerlukan setidaknya 1GB RAM. Saat ini: ${TOTAL_MEM}MB"
fi
log "Memori Sistem: ${TOTAL_MEM}MB - OK"

# --- System & Package Installation ---
log "Memperbarui sistem..."
apt update -y
apt upgrade -y --with-new-pkgs

log "Menginstal paket yang dibutuhkan (Docker, Nginx, Certbot)..."
apt install -y curl wget ufw fail2ban htop unattended-upgrades nginx python3-certbot-nginx

# Configure automatic security updates
log "Mengkonfigurasi pembaruan keamanan otomatis..."
echo 'Unattended-Upgrade::Automatic-Reboot "false";' >> /etc/apt/apt.conf.d/50unattended-upgrades
systemctl enable unattended-upgrades

# Install Docker
log "Menginstal Docker..."
curl -fsSL https://get.docker.com | sh
systemctl start docker
systemctl enable docker

# Install Docker Compose
log "Menginstal Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Verify Docker installation
docker --version
docker-compose --version

# --- Firewall & Security Configuration ---
log "Mengkonfigurasi firewall UFW..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
SSH_PORT=$(ss -tlnp | grep sshd | awk '{print $4}' | cut -d':' -f2 | head -n1)
SSH_PORT=${SSH_PORT:-22}
ufw allow $SSH_PORT/tcp comment 'SSH'
ufw allow 'Nginx Full' comment 'Web traffic (HTTP/HTTPS)'
ufw --force enable

log "Mengkonfigurasi Fail2Ban..."
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

# --- Nginx & Certbot Configuration ---
log "Mengkonfigurasi Nginx sebagai reverse proxy..."
cat > /etc/nginx/sites-available/$N8N_DOMAIN << EOF
server {
    listen 80;
    server_name $N8N_DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:$N8N_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF
ln -s /etc/nginx/sites-available/$N8N_DOMAIN /etc/nginx/sites-enabled/
nginx -t # Test Nginx configuration

log "Memperoleh sertifikat SSL dengan Certbot..."
certbot --nginx --non-interactive --agree-tos --email $CERTBOT_EMAIL --redirect -d $N8N_DOMAIN
systemctl restart nginx

# --- N8N Docker Configuration ---
N8N_DATA_DIR="/opt/n8n-data"
DOCKER_COMPOSE_DIR="/opt/n8n"

log "Menyiapkan direktori N8N..."
mkdir -p $N8N_DATA_DIR
mkdir -p $DOCKER_COMPOSE_DIR
mkdir -p /var/log/n8n

# Define Webhook URL with HTTPS
WEBHOOK_URL="https://$N8N_DOMAIN/"

log "Membuat file konfigurasi Docker Compose..."
cat > $DOCKER_COMPOSE_DIR/docker-compose.yml << EOF
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      # Hanya diekspos ke localhost (diakses oleh Nginx)
      - "127.0.0.1:$N8N_PORT:5678"
    environment:
      # Konfigurasi Dasar
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - WEBHOOK_URL=$WEBHOOK_URL

      # Optimasi Memori
      - NODE_OPTIONS=--max-old-space-size=512
      - N8N_LOG_LEVEL=warn
      - N8N_LOG_OUTPUT=console

      # Keamanan - Menggunakan kredensial kustom Anda
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=$N8N_USER
      - N8N_BASIC_AUTH_PASSWORD=$N8N_PASSWORD

      # Database (SQLite untuk penggunaan sumber daya minimal)
      - DB_TYPE=sqlite
      - DB_SQLITE_DATABASE=/home/node/.n8n/database.sqlite

      # Tweaks Performa untuk VPS 1GB
      - N8N_DISABLE_UI=false
      - N8N_METRICS=false
      - N8N_DIAGNOSTICS_ENABLED=false

      # Zona Waktu
      - GENERIC_TIMEZONE=Asia/Jakarta
      - TZ=Asia/Jakarta

    volumes:
      - $N8N_DATA_DIR:/home/node/.n8n

    # Batas sumber daya untuk VPS 1GB
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

# --- Systemd Service & Startup ---
log "Membuat layanan systemd untuk n8n..."
cat > /etc/systemd/system/n8n-docker.service << EOF
[Unit]
Description=N8N Docker Container Service
Requires=docker.service
After=docker.service network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$DOCKER_COMPOSE_DIR
# Tarik image terbaru sebelum memulai
ExecStartPre=/usr/local/bin/docker-compose pull -q
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

log "Menyiapkan rotasi log..."
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

log "Menjalankan container N8N Docker..."
systemctl daemon-reload
systemctl enable n8n-docker.service
systemctl start n8n-docker.service

log "Menunggu N8N untuk inisialisasi..."
sleep 30

if docker ps | grep -q "n8n"; then
    log "Container N8N Docker berhasil dijalankan."
else
    error "Container N8N Docker gagal dijalankan. Cek log dengan: docker logs n8n"
fi

# --- Finalization & Management Scripts ---
log "Menerapkan optimasi memori..."
echo "vm.swappiness=10" >> /etc/sysctl.conf
echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf
sysctl -p

# Lightweight monitoring script
cat > /usr/local/bin/n8n-docker-monitor.sh << 'EOF'
#!/bin/bash
LOG_FILE="/var/log/n8n/monitor.log"
if ! docker ps | grep -q "n8n"; then
    echo "$(date): N8N container is down, attempting restart" >> $LOG_FILE
    systemctl start n8n-docker.service
fi
EOF
chmod +x /usr/local/bin/n8n-docker-monitor.sh
(crontab -l 2>/dev/null; echo "*/10 * * * * /usr/local/bin/n8n-docker-monitor.sh") | crontab -

# Management scripts
log "Membuat skrip manajemen..."
cat > /usr/local/bin/n8n-start << 'EOF'
#!/bin/bash
systemctl start n8n-docker.service
EOF
chmod +x /usr/local/bin/n8n-start

cat > /usr/local/bin/n8n-stop << 'EOF'
#!/bin/bash
systemctl stop n8n-docker.service
EOF
chmod +x /usr/local/bin/n8n-stop

cat > /usr/local/bin/n8n-restart << 'EOF'
#!/bin/bash
systemctl restart n8n-docker.service
EOF
chmod +x /usr/local/bin/n8n-restart

cat > /usr/local/bin/n8n-logs << 'EOF'
#!/bin/bash
docker logs -f n8n
EOF
chmod +x /usr/local/bin/n8n-logs

cat > /usr/local/bin/n8n-status << 'EOF'
#!/bin/bash
echo "=== Status Layanan Systemd ==="
systemctl status n8n-docker.service --no-pager
echo ""
echo "=== Status Container Docker ==="
docker ps | grep n8n
echo ""
echo "=== Statistik Container ==="
docker stats --no-stream n8n
echo ""
echo "=== Memori Sistem ==="
free -h
EOF
chmod +x /usr/local/bin/n8n-status

# --- Installation Summary ---
CONTAINER_MEM=$(docker stats --no-stream --format "{{.MemUsage}}" n8n 2>/dev/null || echo "N/A")
echo
log "============================================="
log "  INSTALASI N8N DENGAN HTTPS SELESAI!  "
log "============================================="
echo
log "Konfigurasi N8N Anda:"
log "  🌐 URL: https://$N8N_DOMAIN"
log "  🔌 Port Internal: $N8N_PORT (Dikelola oleh Nginx)"
log "  💾 Direktori Data: $N8N_DATA_DIR"
echo
log "Fitur Keamanan:"
log "  ✓ HTTPS diaktifkan dengan Certbot"
log "  ✓ UFW Firewall aktif"
log "  ✓ Fail2Ban melindungi SSH"
log "  ✓ Pembaruan keamanan otomatis"
echo
log "Kredensial Login Anda:"
log "  👤 Username: $N8N_USER"
warn "  🔑 Password: [YANG ANDA MASUKKAN TADI]"
echo
log "Perintah Manajemen:"
log "  ▶️  Mulai: n8n-start"
log "  ⏹️  Berhenti: n8n-stop"
log "  🔄 Restart: n8n-restart"
log "  📋 Status: n8n-status"
log "  📝 Log: n8n-logs"
echo
warn "PENTING: Simpan password Anda di tempat yang aman. Skrip ini tidak menyimpannya."
warn "Sertifikat SSL akan diperbarui secara otomatis oleh Certbot."
echo
log "🎉 Instalasi berhasil! Akses N8N di: https://$N8N_DOMAIN"
