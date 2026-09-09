#!/usr/bin/env sh
set -eu

if ! command -v apt-get >/dev/null 2>&1; then
  echo "Este reparo atende Ubuntu. Use a documentação oficial correspondente à sua distribuição."
  exit 1
fi

echo "Parando o Docker instalado pelos pacotes do Ubuntu..."
sudo systemctl stop docker docker.socket containerd 2>/dev/null || true

echo "Removendo pacotes conflitantes sem apagar /var/lib/docker..."
sudo apt-get update
sudo apt-get remove -y docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc || true
sudo apt-get install -y ca-certificates curl

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

. /etc/os-release
ARCH=$(dpkg --print-architecture)
printf '%s\n' \
  "Types: deb" \
  "URIs: https://download.docker.com/linux/ubuntu" \
  "Suites: ${VERSION_CODENAME}" \
  "Components: stable" \
  "Architectures: ${ARCH}" \
  "Signed-By: /etc/apt/keyrings/docker.asc" \
  | sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker "$(id -un)"

echo "Versões instaladas:"
sudo docker version
sudo docker compose version
sudo docker run --rm hello-world >/dev/null
echo "Docker validado. Execute novamente: ./remote-lab.sh start"
