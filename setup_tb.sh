#!/usr/bin/env bash
set -e

echo "[+] Starting ThingsBoard CE DMZ setup"

########################################
# 0. System update
########################################
echo "[+] Updating system"
sudo apt update && sudo apt upgrade -y

########################################
# 1. Install Docker & docker-compose
########################################
echo "[+] Installing Docker"
sudo apt install -y docker.io docker-compose

sudo systemctl enable docker
sudo systemctl start docker

# Add user to group for FUTURE sessions
sudo usermod -aG docker $USER

echo "[!] Docker group updated. (Re-login required for future non-sudo commands)"
sleep 2

########################################
# 2. Create ThingsBoard directory
########################################
echo "[+] Creating workspace"
mkdir -p ~/thingsboard
mkdir -p ~/thingsboard/tb-data
mkdir -p ~/thingsboard/tb-logs
cd ~/thingsboard

# Fix permissions so the container (UID 799) can write to these folders
sudo chown -R 799:799 ~/thingsboard/tb-data
sudo chown -R 799:799 ~/thingsboard/tb-logs

########################################
# 3. Write docker-compose.yml (ARM64/AMD64 compatible)
########################################
echo "[+] Writing docker-compose.yml"

cat << 'EOF' > docker-compose.yml
version: "3.8"

services:
  postgres:
    restart: always
    image: "postgres:16"
    ports:
      - "5432"
    environment:
      POSTGRES_DB: thingsboard
      POSTGRES_USER: thingsboard
      POSTGRES_PASSWORD: thingsboard_password
    volumes:
      - postgres-data:/var/lib/postgresql/data

  thingsboard-ce:
    restart: always
    # "latest" tag supports both AMD64 and ARM64 (Apple Silicon) better than specific versions
    image: "thingsboard/tb-node:latest"
    ports:
      - "8080:8080"
      - "7070:7070"
      - "1883:1883"
      - "8883:8883"
      - "5683-5688:5683-5688/udp"
    environment:
      TB_SERVICE_ID: tb-ce-node
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/thingsboard
      SPRING_DATASOURCE_USERNAME: thingsboard
      SPRING_DATASOURCE_PASSWORD: thingsboard_password
      TB_QUEUE_TYPE: in-memory
    volumes:
      - ./tb-data:/data
      - ./tb-logs:/var/log/thingsboard
    depends_on:
      - postgres

volumes:
  postgres-data:
    name: tb-postgres-data
    driver: local
EOF

########################################
# 4. Database Initialization
########################################
echo "[+] Starting Postgres for initialization..."
sudo docker-compose up -d postgres

echo "[+] Waiting 10s for Postgres to be ready..."
sleep 10

echo "[+] Running ThingsBoard Installation Script..."
# Running as 'root' inside container to bypass permission/su issues
# Using full path to install.sh (it moved in newer images)
sudo docker-compose run --rm --user root --entrypoint /bin/bash thingsboard-ce -c "/usr/share/thingsboard/bin/install/install.sh --loadDemo"

########################################
# 5. Start ThingsBoard Service
########################################
echo "[+] Starting ThingsBoard Node..."
sudo docker-compose up -d thingsboard-ce

########################################
# 6. Verification
########################################
echo "[+] Verifying containers"
sudo docker ps

echo "[+] Waiting for ThingsBoard UI to launch (approx 60s)..."
sleep 5

echo "----------------------------------------------------"
echo "Setup Complete!"
echo "Access UI: http://<VM_IP>:8080"
echo "System Admin: sysadmin@thingsboard.org / sysadmin"
echo "Tenant Admin: tenant@thingsboard.org / tenant"
echo "----------------------------------------------------"
