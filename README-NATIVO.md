# Execução nativa em Ubuntu dentro de LXC

Use esta modalidade nos servidores institucionais identificados como LXC. Ela não depende de Docker.

## Arquitetura

```text
HTTP/80 -> NGINX
             |-- round-robin ------> 127.0.0.1:8001, 8002 e 8003
             |-- pesos 3:1:1 ------> 127.0.0.1:8001, 8002 e 8003
             `-- least connections -> 127.0.0.1:8001, 8002 e 8003
```

Os três backends executam como serviços `systemd`. Somente o NGINX fica exposto na porta 80.

## Instalação

```bash
chmod +x install-native.sh native-lab.sh
./install-native.sh
./native-lab.sh start
```

Valide:

```bash
./native-lab.sh status
curl -i http://127.0.0.1/status
curl -i http://127.0.0.1/rr/catalogo/42
```

Depois abra `http://DNS-PUBLICO/` no computador do laboratório.

## Experimentos

```bash
./native-lab.sh failure
./native-lab.sh logs
./native-lab.sh recover
./native-lab.sh status
```

O comando `failure` interrompe apenas `app-2`. O NGINX continua usando `app-1` e `app-3`.

## Encerramento

```bash
./native-lab.sh down
```

O instalador altera a configuração do NGINX da máquina e desativa o site padrão. Use uma instância dedicada ao laboratório.
