#!/bin/bash

# n8n-lite-installer
# Maintained by: Ridwan Wahyu Hariyanto (https://github.com/rid999)
# Description: One-click installer for n8n on low-resource VPS (1GB RAM)
# OS Support: Ubuntu 20.04 / 22.04

set -e

echo "🔧 Starting n8n-lite installer..."

# === 1. Install Docker & Docker Compose ===
echo "📦 Installing Docker..."
apt update -y
apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg]   https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" |   tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update -y
apt install -y docker-ce docker-ce-cli containerd.io

echo "🐳 Installing Docker Compose..."
DOCKER_COMPOSE_VERSION=1.29.2
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)"   -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# === 2. Setup n8n folder ===
echo "📁 Setting up /opt/n8n directory..."
mkdir -p /opt/n8n && cd /opt/n8n

# === 3. Create .env ===
echo "📝 Creating .env..."
cat <<EOF > .env
# Basic Auth
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=admin123

# Timezone
GENERIC_TIMEZONE=Asia/Jakarta

# Memory limit (for SQLite)
NODE_OPTIONS=--max-old-space-size=768
EOF

# === 4. Create docker-compose.yml ===
echo "📝 Creating docker-compose.yml..."
cat <<EOF > docker-compose.yml
version: "3.8"

services:
  n8n:
    image: docker.n8n.io/n8nio/n8n
    restart: always
    ports:
      - "5678:5678"
    env_file:
      - .env
    volumes:
      - n8n_data:/home/node/.n8n

volumes:
  n8n_data:
EOF

# === 5. Start container ===
echo "🚀 Launching n8n..."
docker-compose up -d

echo "✅ n8n is now running at http://<your-server-ip>:5678"
echo "🔐 Login with: admin / admin123"
