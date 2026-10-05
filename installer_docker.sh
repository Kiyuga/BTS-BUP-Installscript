#!/usr/bin/env bash
set -euo pipefail

# Check if node is installed
if ! command -v node >/dev/null 2>&1; then

# If not, install it
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  \. "$HOME/.nvm/nvm.sh"
  nvm install 18
fi

# Use NVM when available; otherwise use the system Node.js installation.
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1090
    source "$NVM_DIR/nvm.sh"
fi

BTS_REPO="https://github.com/tlehr/bts.git"
BTS_BRANCH="feat/bupws_v2"
BUP_REPO="https://github.com/tlehr/bup.git"
BUP_BRANCH="feat/bupws_v2"

# Install BTS to home
cd ~
if [ ! -d "bts/.git" ]; then
    rm -rf bts
    git clone --branch "$BTS_BRANCH" --single-branch "$BTS_REPO" bts
fi

cd bts
git fetch origin "$BTS_BRANCH"
git checkout "$BTS_BRANCH"
git reset --hard "origin/$BTS_BRANCH"
make deps

# Install BUP to home
cd ~

if [ ! -d "bup/.git" ]; then
    rm -rf bup
    git clone --branch "$BUP_BRANCH" --single-branch "$BUP_REPO" bup
fi

cd bup
git fetch origin "$BUP_BRANCH"
git checkout "$BUP_BRANCH"
git reset --hard "origin/$BUP_BRANCH"
make deps

# Use Development BUP in BTS
cd ~/bts || exit 1

cat > config.json <<'EOF'
{
  "port": 4000,
  "bup_location": "static/bup/dev",
  "bup_index": "bup.html",
  "report_errors": true,
  "enable_https": false
}
EOF

# Create or refresh the development BUP symlink
ln -sfn ~/bup ~/bts/static/bup/dev

# use a compatible Node version when NVM is available
if command -v nvm >/dev/null 2>&1; then
    nvm install 22.18.0
    node_path="$(which node)"
else
    node_path="$(command -v node)"
fi

# copy used node version into service template
cat > "$HOME/bts/div/bts.service.template" <<EOF
[Unit]
Description=bts

[Service]
ExecStart=${node_path} BTS_ROOT_DIR/bts/bts.js
Type=simple
WorkingDirectory=BTS_ROOT_DIR
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Install as a service only on a host system.
if [ "${CONTAINER:-0}" != "1" ] && command -v sudo >/dev/null 2>&1; then
    cd ~/bts
    sudo make install-service
fi

exit 0
