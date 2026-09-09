#!/usr/bin/env sh
set -eu

LAB_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$LAB_DIR"
LAB_HTTP_PORT=${LAB_HTTP_PORT:-80}

if docker info >/dev/null 2>&1; then
  DOCKER="docker"
else
  DOCKER="sudo docker"
fi

COMPOSE="$DOCKER compose -f docker-compose.remote.yml"

case "${1:-help}" in
  start)
    $COMPOSE up -d
    echo "Laboratório publicado na porta ${LAB_HTTP_PORT}."
    ;;
  status)
    $COMPOSE ps
    curl --fail --silent "http://127.0.0.1:${LAB_HTTP_PORT}/status"
    printf '\n'
    ;;
  failure)
    $COMPOSE stop app2
    echo "app-2 parada. A turma pode repetir as amostras por até 10 segundos."
    ;;
  recover)
    $COMPOSE start app2
    echo "app-2 reiniciada. Aguarde o healthcheck antes da próxima rodada."
    ;;
  logs)
    $COMPOSE logs --tail=100 load-balancer app1 app2 app3
    ;;
  down)
    $COMPOSE down
    ;;
  config)
    $COMPOSE config --quiet
    echo "Configuração do Compose válida."
    ;;
  *)
    echo "Uso: $0 {start|status|failure|recover|logs|config|down}"
    ;;
esac
