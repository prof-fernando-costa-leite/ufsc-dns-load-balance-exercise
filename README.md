# Laboratório DNS e Load Balancer

Este repositório oferece duas formas de executar a mesma prática. Escolha apenas uma delas em cada servidor.

## Servidor LXC da instituição: modo nativo

O Docker não consegue iniciar contêineres no LXC devido à política AppArmor aplicada pelo host. Nessa infraestrutura, execute NGINX e os três backends diretamente no sistema Ubuntu:

```bash
chmod +x install-native.sh native-lab.sh
./install-native.sh
./native-lab.sh start
./native-lab.sh status
```

Consulte [README-NATIVO.md](README-NATIVO.md) para a prática completa.

## EC2 ou VM completa: modo Docker

```bash
chmod +x install-ec2.sh remote-lab.sh
./install-ec2.sh
./remote-lab.sh start
./remote-lab.sh status
```

Consulte [README-EC2-INDIVIDUAL.md](README-EC2-INDIVIDUAL.md).

## Endereços da prática

As duas modalidades publicam a mesma interface em HTTP/80:

```text
http://HOST/rr/catalogo/42
http://HOST/weighted/catalogo/42
http://HOST/least/catalogo/42
```

Os comandos administrativos também são equivalentes: `start`, `status`, `failure`, `recover`, `logs`, `config` e `down`.
