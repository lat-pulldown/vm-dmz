#!/usr/bin/env bash
set -e

echo "[+] Starting CALDERA DMZ setup (Final - Python Config Fix)"

########################################
# 0. System dependencies
########################################
echo "[+] Installing system dependencies"
sudo apt update
sudo apt install -y git python3-pip python3-venv wget curl unzip

########################################
# 1. Clone CALDERA (recursive)
########################################
echo "[+] Cloning CALDERA repository"
if [ -d "caldera" ]; then
    echo "    (Caldera directory already exists, skipping clone)"
else
    git clone https://github.com/mitre/caldera.git --recursive
fi

cd caldera

########################################
# 2. Python virtual environment
########################################
echo "[+] Creating Python virtual environment"
if [ ! -d "caldera-env" ]; then
    python3 -m venv caldera-env
fi

source caldera-env/bin/activate

########################################
# 3. Install Python requirements
########################################
echo "[+] Installing Python requirements (this may take a while)"
pip3 install -r requirements.txt

########################################
# 4. Install Modbus plugin
########################################
echo "[+] Installing Modbus plugin"
mkdir -p plugins
cd plugins
if [ ! -d "modbus" ]; then
    git clone https://github.com/mitre/modbus.git
else
    echo "    (Modbus plugin already exists)"
fi
cd ..

########################################
# 5. Automated Configuration (Python Method)
########################################
echo "[+] Configuring conf/local.yml to include 'modbus' plugin"

# Create local.yml from default.yml if missing
if [ ! -f conf/local.yml ]; then
    echo "    (Creating local.yml from default.yml)"
    cp conf/default.yml conf/local.yml
fi

# Use Python to safely add 'modbus' to the YAML list. 
# This avoids indentation errors caused by sed.
python3 -c "
import yaml
try:
    with open('conf/local.yml', 'r') as f:
        data = yaml.safe_load(f)
    
    if 'plugins' in data and 'modbus' not in data['plugins']:
        data['plugins'].append('modbus')
        print('    (Added modbus to plugins list)')
        
        with open('conf/local.yml', 'w') as f:
            yaml.dump(data, f, default_flow_style=False)
            
    else:
        print('    (Modbus already present or plugins key missing)')
except Exception as e:
    print(f'    (Error updating YAML: {e})')
    exit(1)
"

########################################
# 6. Node.js 20 installation
########################################
echo "[+] Installing Node.js 20.x"
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "    (Node.js is already installed)"
fi

########################################
# 7. Install Go 1.21 (Architecture Aware)
########################################
echo "[+] Checking/Installing Go 1.21"

ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ]; then
    GO_ARCH="arm64"
else
    GO_ARCH="amd64"
fi

if ! command -v go &> /dev/null; then
    echo "    Downloading Go for linux-$GO_ARCH..."
    wget -q "https://go.dev/dl/go1.21.6.linux-${GO_ARCH}.tar.gz"
    sudo tar -C /usr/local -xzf "go1.21.6.linux-${GO_ARCH}.tar.gz"
    rm "go1.21.6.linux-${GO_ARCH}.tar.gz"
    export PATH=$PATH:/usr/local/go/bin
else
    echo "    (Go is already installed)"
fi

########################################
# 8. Setup Persistence (.profile)
########################################
echo "[+] Adding Go and Venv paths to .profile"
if ! grep -q "/usr/local/go/bin" ~/.profile; then
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
fi

########################################
# 9. Build and Launch CALDERA
########################################
echo "======================================================"
echo "Setup Complete!"
echo "Starting CALDERA Build process..."
echo "1. The server will start building the UI (Magma)."
echo "2. Once you see log lines like 'All systems ready', it is running."
echo "3. Access at: http://<VM_IP>:8888"
echo "4. Login:     admin (or red) / (password in conf/local.yml)"
echo "======================================================"
sleep 3

python3 server.py --build
