#!/usr/bin/env bash
set -euo pipefail

# This script provisions an Ubuntu VM for running the Discord bot via systemd
# Usage: curl -fsSL https://raw.githubusercontent.com/your/repo/main/deploy/setup.sh | bash -s -- DISCORD_TOKEN=... BOT_DIR=/opt/glorp-bot

# Defaults
: "${BOT_DIR:=/opt/glorp-bot}"
: "${NODE_VERSION:=22}"

if [[ -z "${DISCORD_TOKEN:-}" ]]; then
  echo "ERROR: DISCORD_TOKEN is required. Export it or pass DISCORD_TOKEN=... before running." >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "[1/7] Updating packages"
sudo apt-get update -y
sudo apt-get upgrade -y

echo "[2/7] Installing Node.js and git"
if ! command -v node >/dev/null 2>&1; then
  curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi
sudo apt-get install -y git

echo "[3/7] Creating bot directory ${BOT_DIR}"
sudo mkdir -p "${BOT_DIR}"
sudo chown -R "$USER":"$USER" "${BOT_DIR}"

if [[ -z "${GIT_REPO:-}" ]]; then
  echo "No GIT_REPO provided; assuming code uploaded to ${BOT_DIR}. If not, set GIT_REPO and re-run." >&2
else
  echo "[4/7] Cloning repo ${GIT_REPO}"
  if [[ -d "${BOT_DIR}/.git" ]]; then
    git -C "${BOT_DIR}" fetch --all --prune
    git -C "${BOT_DIR}" checkout -f main
    git -C "${BOT_DIR}" reset --hard origin/main
  else
    git clone --depth 1 "${GIT_REPO}" "${BOT_DIR}"
  fi
fi

cd "${BOT_DIR}"

echo "[5/7] Installing dependencies"
npm ci || npm install

echo "[6/7] Creating environment file"
cat <<EOF | sudo tee /etc/glorp-bot.env >/dev/null
DISCORD_TOKEN=${DISCORD_TOKEN}
NODE_ENV=production
EOF
sudo chmod 600 /etc/glorp-bot.env

echo "[7/7] Installing systemd service"
SERVICE_FILE=/etc/systemd/system/glorp-bot.service
sudo bash -c "cat > ${SERVICE_FILE}" <<SYSTEMD
[Unit]
Description=Glorp Discord Bot
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
EnvironmentFile=/etc/glorp-bot.env
WorkingDirectory=${BOT_DIR}
ExecStart=/usr/bin/node index.js
Restart=always
RestartSec=5
# Limit resources a bit
MemoryMax=300M

# Ensure logs go to journalctl
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SYSTEMD

sudo systemctl daemon-reload
sudo systemctl enable glorp-bot.service
sudo systemctl restart glorp-bot.service

sleep 2
sudo systemctl --no-pager --full status glorp-bot.service || true

echo "Done. View logs with: sudo journalctl -u glorp-bot -f"
