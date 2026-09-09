#!/usr/bin/env sh
set -eu

LAB_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if ! command -v apt-get >/dev/null 2>&1; then
  echo "Este instalador nativo foi preparado para Ubuntu/Debian."
  exit 1
fi

echo "Instalando NGINX, Python e curl..."
sudo apt-get update
sudo apt-get install -y nginx python3 curl

echo "Copiando os arquivos do laboratório..."
sudo install -d /opt/dns-lb-lab/www
sudo install -m 0644 "$LAB_DIR/app/server.py" /opt/dns-lb-lab/server.py
sudo install -m 0644 "$LAB_DIR/www/index.html" /opt/dns-lb-lab/www/index.html
sudo install -m 0644 "$LAB_DIR/systemd/dns-lb-app@.service" /etc/systemd/system/dns-lb-app@.service
sudo install -m 0644 "$LAB_DIR/nginx/proxy-common.conf" /etc/nginx/dns-lb-proxy-common.conf
sudo install -m 0644 "$LAB_DIR/nginx/nginx.native.conf" /etc/nginx/sites-available/dns-lb-lab

if [ -L /etc/nginx/sites-enabled/default ]; then
  sudo unlink /etc/nginx/sites-enabled/default
fi
sudo ln -sfn /etc/nginx/sites-available/dns-lb-lab /etc/nginx/sites-enabled/dns-lb-lab

sudo systemctl daemon-reload
sudo systemctl enable dns-lb-app@1 dns-lb-app@2 dns-lb-app@3 nginx
sudo nginx -t

echo "Instalação nativa concluída. Execute: ./native-lab.sh start"
