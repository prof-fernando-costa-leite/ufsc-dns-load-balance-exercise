#!/usr/bin/env sh
set -eu

wait_backend() {
  port="$1"
  name="$2"
  attempts=0
  while ! curl --fail --silent "http://127.0.0.1:${port}/health" >/dev/null 2>&1; do
    attempts=$((attempts + 1))
    if [ "$attempts" -ge 30 ]; then
      echo "Erro: ${name} não respondeu na porta ${port}."
      sudo systemctl --no-pager --full status "dns-lb-app@${name#app-}" || true
      exit 1
    fi
    sleep 1
  done
  echo "${name} pronta na porta ${port}."
}

case "${1:-help}" in
  start)
    sudo systemctl restart dns-lb-app@1 dns-lb-app@2 dns-lb-app@3
    wait_backend 8001 app-1
    wait_backend 8002 app-2
    wait_backend 8003 app-3
    sudo nginx -t
    sudo systemctl restart nginx
    curl --fail --silent http://127.0.0.1/status
    printf '\nLaboratório nativo publicado na porta 80.\n'
    ;;
  status)
    sudo systemctl --no-pager --full status dns-lb-app@1 dns-lb-app@2 dns-lb-app@3 nginx || true
    curl --fail --silent http://127.0.0.1/status
    printf '\n'
    ;;
  failure)
    sudo systemctl stop dns-lb-app@2
    echo "app-2 parada. Repita as amostras durante os próximos 10 segundos."
    ;;
  recover)
    sudo systemctl restart dns-lb-app@2
    wait_backend 8002 app-2
    sudo systemctl reload nginx
    echo "app-2 reiniciada e disponível no pool."
    ;;
  logs)
    sudo journalctl --no-pager -n 80 -u dns-lb-app@1 -u dns-lb-app@2 -u dns-lb-app@3
    sudo tail -n 80 /var/log/nginx/dns-lb-access.log /var/log/nginx/dns-lb-error.log
    ;;
  config)
    sudo nginx -t
    ;;
  down)
    sudo systemctl stop dns-lb-app@1 dns-lb-app@2 dns-lb-app@3 nginx
    echo "Backends e NGINX interrompidos."
    ;;
  *)
    echo "Uso: $0 {start|status|failure|recover|logs|config|down}"
    ;;
esac
