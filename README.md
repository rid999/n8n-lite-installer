# n8n-lite-installer

One-click lightweight installer for [n8n](https://n8n.io) on low-spec VPS (1GB RAM).  
Ideal for personal automation, micro-SaaS, or private workflows with minimal infrastructure.

---

## 🚀 Features

- Installs Docker + Docker Compose  
- Sets up secure n8n instance with Basic Auth  
- Uses environment variables (`.env`) for timezone and credentials  
- Runs via Docker Compose with memory limit (768MB)  
- Ready in 1 minute — no technical overhead  

---

## 📦 Requirements

- Ubuntu 20.04 / 22.04 VPS  
- Min. 1 vCPU, 1GB RAM, 10GB storage  

---

## 🛠️ Install in One Command

```bash
bash <(curl -s https://raw.githubusercontent.com/rid999/n8n-lite-installer/main/install-n8n-lite.sh)



