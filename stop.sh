#!/bin/bash
# Stop services

echo "Stopping..."

echo "Stopping Conpot..."
if [ -d "/home/ubuntu/conpot" ]; then
    cd /home/ubuntu/conpot && sudo docker compose down
else
    echo "Warning: Conpot directory not found."
fi

echo "Stopping Thingsboard..."
if [ -d "/home/ubuntu/thingsboard" ]; then
    cd /home/ubuntu/thingsboard && sudo docker compose down
else
    echo "Warning: ThingsBoard directory not found."
fi

# 3. Stop Caldera (Python Process)
echo "Stopping Caldera..."
pkill -f server.py || echo "Caldera was not running."

# 4. Stop pottotb.py
echo "Stopping pottotb.py..."
pkill -f pottotb.py || echo "pottotb.py was not running."

echo "Shutdown Successful"
