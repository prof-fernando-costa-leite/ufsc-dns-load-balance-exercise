#!/usr/bin/env sh
set -eu

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  echo "Docker e Docker Compose já estão disponíveis."
  exit 0
fi

if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y docker.io docker-compose-v2 curl unzip
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

echo "Instalação concluída. Este laboratório também funciona com sudo antes de um novo login."

