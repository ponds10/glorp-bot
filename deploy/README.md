# Oracle Cloud VM deployment (Always Free)

This folder contains a setup script and a systemd unit to run your Discord bot 24/7 on an Oracle Cloud Always Free VM.

## What this does

- Installs Node.js (v22 by default) and git
- Sets up your bot in `/opt/glorp-bot` by default
- Stores secrets in `/etc/glorp-bot.env`
- Runs the bot as a systemd service: `glorp-bot.service`

## Prerequisites

- An Oracle Cloud Free Tier account
- A VM (Ubuntu is recommended)
- Your Discord bot token

## 1) Create an Ubuntu VM

- Choose the Always Free ARM VM if available (Ampere A1), Ubuntu 22.04 LTS
- Allow inbound SSH (port 22)
- After creation, add an Ingress rule for outbound connections (default is open)

## 2) Connect via SSH

```bash
ssh ubuntu@<your_public_ip>
```

## 3) Run the setup script

Option A: Upload your repo first (e.g. via git clone), then run script pointing to existing directory.

```bash
# Example using exported variables
export DISCORD_TOKEN="<your-token>"
export BOT_DIR=/opt/glorp-bot

# If code is already on the server in $BOT_DIR, skip GIT_REPO
curl -fsSL https://raw.githubusercontent.com/<your-user>/<your-repo>/main/deploy/setup.sh | bash
```

Option B: Let the script clone the repo for you.

```bash
export DISCORD_TOKEN="<your-token>"
export GIT_REPO="https://github.com/<your-user>/<your-repo>.git"
export BOT_DIR=/opt/glorp-bot
curl -fsSL https://raw.githubusercontent.com/<your-user>/<your-repo>/main/deploy/setup.sh | bash
```

> The script writes `/etc/glorp-bot.env` with DISCORD_TOKEN and starts the `glorp-bot` service.

## 4) Manage the service

```bash
# Check status
sudo systemctl status glorp-bot

# Follow logs
sudo journalctl -u glorp-bot -f

# Restart after changes
sudo systemctl restart glorp-bot
```

## 5) Deploy updates

On the server:

```bash
cd /opt/glorp-bot
# If you cloned via GIT_REPO
git pull
npm ci || npm install
sudo systemctl restart glorp-bot
```

## Notes

- The bot reads the token from the `DISCORD_TOKEN` environment variable; `index.js` falls back to `config.json` for local dev.
- Keep your token secret; do not commit it.
- If you prefer PM2 instead of systemd, PM2 works too, but systemd is simpler on a VM.
