#!/usr/bin/env sh
set -eu

if command -v apt-get >/dev/null 2>&1; then
  if sudo docker run --rm hello-world >/dev/null 2>&1 && sudo docker compose version >/dev/null 2>&1; then
    echo "Docker e Docker Compose já estão funcionais."
    exit 0
  fi

  echo "Instalando o Docker Engine pelo repositório oficial..."
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl unzip

  # Os pacotes da distribuição podem fornecer combinações incompatíveis de
  # Docker, containerd e runc. A documentação oficial recomenda removê-los
  # antes de instalar docker-ce e containerd.io. Os dados em /var/lib/docker
  # não são apagados por esta operação.
  sudo apt-get remove -y docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc || true

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
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y docker curl unzip
  sudo systemctl enable --now docker
  if ! sudo docker compose version >/dev/null 2>&1; then
    echo "O plugin Docker Compose não está disponível nesta imagem."
    echo "Use a imagem Ubuntu indicada pelo professor ou instale o plugin aprovado pela instituição."
    exit 1
  fi
else
  echo "Distribuição não reconhecida. Instale Docker Engine e o plugin Compose conforme a imagem usada."
  exit 1
fi

sudo systemctl enable --now docker
sudo usermod -aG docker "$(id -un)"

sudo docker run --rm hello-world >/dev/null
sudo docker compose version

echo "Instalação concluída e validada. O laboratório também funciona com sudo antes de um novo login."
