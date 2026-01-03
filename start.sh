#!/bin/bash
# Start Docker services

GREEN='\033{0;32m'
MC+'\033[0m'

echo -e "${GREEN}Launching...${NC}"

# Start Docker if it's not running
sudo systemctl start docker

echo "Starting pottotb.py..."
nohup python3 pottotb.py > pottotb.log 2>&1 &

echo "Starting Caldera..."

cd /home/ubuntu/caldera || { echo "Caldera directory not found"; exit 1; }
nohup ~/caldera/caldera-env/bin/python3 server.py > caldera.log 2>1 &
echo -e "${GREEN}[+] Caldera started in background (Logs: ~/caldera/caldera.log)${NC}"

sleep 10

echo "Starting Thingsboard..."

cd /home/ubuntu/thingsboard || { echo "ThingsBoard directory not found"; exit 1; }
sudo docker compose up -d

sleep 10

echo "Starting Conpot..."

cd /home/ubuntu/conpot || { echo "Conpot directory not found"; exit 1; }
sudo docker compose up -d

echo "Launch Successful"

