# osTicket Docker Deployment Guide

This guide explains how to migrate your local osTicket configuration, accounts, and data to your production server.

## 📋 Prerequisites
* **Local Machine:** Docker Desktop installed and running.
* **Production Server:** Linux (Ubuntu recommended) with Docker and Docker Compose installed.
* **Tools:** SFTP/SCP client (FileZilla, Terminal, or WinSCP).

---

## 🛠 Phase 1: Local Preparation
Before moving anything, we need to capture your current setup (accounts, departments, and settings).

### 1. Export the Database
Run this command in your local terminal (Powershell or CMD) while your containers are running:
```powershell
docker exec osticket_db mysqldump -u osticket_user -posticket_pass osticket > production_ready.sql
```

### 2. Package the Project
Zip the entire `osTicket` project directory. Ensure the following files are included:
* `upload/` (Entire folder)
* `Dockerfile`
* `docker-compose.yml`
* `entrypoint.sh`
* `production_ready.sql` (The backup you just made)

---

## 🚀 Phase 2: Production Server Deployment

### 1. Transfer the Files
Upload the zip file to your server (e.g., to `/home/admin/osticket`).

### 2. Extract and Prepare
On your server terminal:
```bash
unzip osticket.zip
cd osticket
```

### 3. Start the Containers
Build and launch the production environment:
```bash
docker-compose up -d --build
```

### 4. Restore the Data
Once the containers are up and "Healthy" (check with `docker ps`), import your backup:
```bash
docker exec -i osticket_db mysql -u osticket_user -posticket_pass osticket < production_ready.sql
```

---

## 🔐 Phase 3: Post-Deployment Configuration

### 1. Update Helpdesk URL
Log in to your production osTicket instance and go to:
**Admin Panel** > **Settings** > **System**
* Update **Helpdesk URL** from `http://localhost:8081` to your actual domain (e.g., `https://support.yourcompany.com`).

### 2. Security hardening
Update your `docker-compose.yml` on the server to use stronger passwords:
* `MYSQL_ROOT_PASSWORD`
* `MYSQL_PASSWORD`
* Ensure `ports` is configured correctly (e.g., if using a Reverse Proxy, you might change `8081:80` to `127.0.0.1:8081:80`).

### 3. SSL (Recommended)
Use **Nginx Proxy Manager** or **Traefik** as a reverse proxy to provide HTTPS/SSL support for your production instance.

---

## 📁 File Structure Reference
Your project directory should look like this on the server:
```text
osticket/
├── docker-compose.yml
├── Dockerfile
├── entrypoint.sh
├── production_ready.sql
└── upload/
    ├── include/
    │   └── ost-config.php  <-- (Generated automatically)
    └── ... (All other PHP files)
```
