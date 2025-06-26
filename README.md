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
- Minimum: 1 vCPU, 1GB RAM, 10GB storage  

---

## 🛠️ Install in One Command

```bash
bash <(curl -s https://raw.githubusercontent.com/rid999/n8n-lite-installer/main/install-n8n-lite.sh)
```

---

## ❗ Having Trouble Accessing n8n?

If you cannot access the n8n dashboard after installation (e.g. connection refused),  
your VPS provider may block direct Docker port exposure.

**Fix:** Install and use Nginx as a reverse proxy to forward traffic to the n8n container.

Example Nginx config:

```nginx
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

After saving the config, restart nginx:

```bash
nginx -t && systemctl reload nginx
```

Then visit: http://your-vps-ip

---

## 📂 Files

| File | Description |
|------|-------------|
| `install-n8n-lite.sh` | Main bash script |
| `.env` | Configuration for auth and timezone |
| `docker-compose.yml` | Docker setup for n8n (SQLite backend) |

---

## 🙌 Credits

Created and maintained by **Ridwan Wahyu Hariyanto**  
GitHub: [@rid999](https://github.com/rid999)  
Released under the [MIT License](LICENSE)

---

## 📌 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
