#!/bin/bash
set -e

echo "========================================"
echo "  OpenCode + 9Router Auto Setup"
echo "========================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()  { echo -e "${GREEN}[OK]${NC} $1"; }
info(){ echo -e "${YELLOW}[!]${NC} $1"; }

# --- Step 1: Install Docker ---
if command -v docker &>/dev/null; then
    ok "Docker already installed"
else
    info "Installing Docker..."
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker $USER
    ok "Docker installed"
fi

# --- Step 2: Run 9Router ---
info "Setting up 9Router..."
mkdir -p ~/opencode-stack
cat > ~/opencode-stack/docker-compose.yml << 'DOCKERFILE'
services:
  9router:
    image: decolua/9router:latest
    container_name: 9router
    restart: unless-stopped
    ports:
      - "20128:20128"
    volumes:
      - 9router-data:/root/.9router
networks: {}
volumes:
  9router-data:
DOCKERFILE

cd ~/opencode-stack
sudo docker compose up -d 9router 2>/dev/null
ok "9Router running on port 20128"

# --- Step 3: Install OpenCode ---
if [ -f ~/.opencode/bin/opencode ]; then
    ok "OpenCode already installed ($(~/.opencode/bin/opencode --version))"
else
    info "Installing OpenCode..."
    curl -fsSL https://opencode.ai/install | bash
    ok "OpenCode installed"
fi

# --- Step 4: Add to PATH ---
if ! grep -q "opencode/bin" ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/.opencode/bin:$PATH"' >> ~/.bashrc
fi
echo 'export PATH="$HOME/.opencode/bin:$PATH"' | sudo tee /etc/profile.d/opencode.sh >/dev/null
sudo chmod +x /etc/profile.d/opencode.sh
export PATH="$HOME/.opencode/bin:$PATH"
ok "OpenCode added to PATH"

# --- Step 5: Configure 9Router provider ---
mkdir -p ~/.config/opencode ~/.local/share/opencode

# Write / update config files
python3 << 'PYEOF'
import json, os

h = os.path.expanduser

# Only write auth if not exists
auth_path = h('~/.local/share/opencode/auth.json')
os.makedirs(os.path.dirname(auth_path), exist_ok=True)

if os.path.exists(auth_path):
    print("  auth.json exists, keeping it")
else:
    auth = {'9r': {'type': 'api', 'key': 'GET_FROM_DASHBOARD'}}
    with open(auth_path, 'w') as f:
        json.dump(auth, f, indent=2)
    print("  auth.json created. Get API key from 9Router dashboard!")

# Always write config
cfg = {
    'disabled_providers': [],
    'provider': {
        '9r': {
            'name': '9r',
            'npm': '@ai-sdk/openai-compatible',
            'options': {'baseURL': 'http://localhost:20128/v1'},
            'models': {
                'mmf/mimo-auto': {'name': 'mmf/mimo-auto'}
            }
        }
    }
}
cfg_path = h('~/.config/opencode/opencode.jsonc')
os.makedirs(os.path.dirname(cfg_path), exist_ok=True)
with open(cfg_path, 'w') as f:
    json.dump(cfg, f, indent=2)
print("  config written")
PYEOF
ok "OpenCode configured to use 9Router"

# Get VPS IP
VPS_IP=$(curl -s -4 ifconfig.me 2>/dev/null || echo "YOUR_VPS_IP")

# --- Summary ---
echo ""
echo "========================================"
echo "  SETUP HOÀN TẤT!"
echo "========================================"
echo ""
echo "  1. Mở browser: http://${VPS_IP}:20128"
echo "     → Dashboard 9Router → Thêm API keys providers"
echo "     → Copy API key (dạng sk-xxx...)"
echo ""
echo "  2. Nếu cần cập nhật API key:"
echo "     nano ~/.local/share/opencode/auth.json"
echo "     Sửa 'GET_FROM_DASHBOARD' thành key thật"
echo ""
echo "  3. Trong terminal VSCode, chạy:"
echo "     opencode -m 9r/mmf/mimo-auto"
echo ""
echo "  Nếu báo 'command not found':"
echo "     source ~/.bashrc"
echo "     # hoặc dùng: ~/.opencode/bin/opencode"
echo ""
echo "========================================"

# Clean up
rm -f ~/setup.sh
