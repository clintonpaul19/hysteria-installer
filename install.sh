cat > install.sh <<'EOF'
#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "Run this script as root."
    exit 1
fi

echo "=== Hysteria 2 Auto Installer ==="

read -rp "Domain: " DOMAIN
read -rp "Email: " EMAIL
read -rsp "Password: " PASSWORD
echo

echo "[1/8] Updating packages..."
apt update
apt install -y curl certbot qrencode

echo "[2/8] Installing Hysteria..."
bash <(curl -fsSL https://get.hy2.sh/)

echo "[3/8] Disabling systemd-resolved..."
systemctl stop systemd-resolved || true
systemctl disable systemd-resolved || true
systemctl mask systemd-resolved || true

rm -f /etc/resolv.conf
cat >/etc/resolv.conf <<RESOLV
nameserver 1.1.1.1
nameserver 8.8.8.8
RESOLV

echo "[4/8] Requesting Let's Encrypt certificate..."
certbot certonly \
  --standalone \
  --non-interactive \
  --agree-tos \
  --email "$EMAIL" \
  -d "$DOMAIN"

echo "[5/8] Creating Hysteria configuration..."
mkdir -p /etc/hysteria

cat >/etc/hysteria/config.yaml <<CONFIG
listen: :53

tls:
  cert: /etc/letsencrypt/live/$DOMAIN/fullchain.pem
  key: /etc/letsencrypt/live/$DOMAIN/privkey.pem

auth:
  type: password
  password: $PASSWORD

masquerade:
  type: proxy
  proxy:
    url: https://www.cloudflare.com
CONFIG

echo "[6/8] Updating service..."

SERVICE="/etc/systemd/system/hysteria-server.service"

if grep -q '^User=' "$SERVICE"; then
    sed -i 's/^User=.*/User=root/' "$SERVICE"
fi

systemctl daemon-reload

echo "[7/8] Starting Hysteria..."
systemctl enable hysteria-server
systemctl restart hysteria-server

echo "[8/8] Verifying..."

if ! ss -lunp | grep -q ":53"; then
    echo
    echo "Hysteria failed to start."
    systemctl status hysteria-server --no-pager
    exit 1
fi

SERVER="$DOMAIN"
PORT="53"
SNI="$DOMAIN"

URI="hysteria2://$PASSWORD@$SERVER:$PORT/?sni=$SNI&insecure=0#$SERVER"

echo
echo "==============================================="
echo "      HYSTERIA 2 INSTALLED SUCCESSFULLY"
echo "==============================================="
echo
echo "Server   : $SERVER"
echo "Port     : $PORT"
echo "Password : $PASSWORD"
echo "SNI      : $SNI"
echo
echo "Import URI:"
echo
echo "$URI"
echo
echo "QR Code:"
qrencode -t ANSIUTF8 "$URI"
echo
echo "Listening Ports:"
ss -lunp | grep :53
echo
echo "Done!"
EOF

chmod +x install.sh
./install.sh
