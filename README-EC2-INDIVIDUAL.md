# Laboratório individual em EC2

Cada estudante executa este laboratório na própria EC2. Docker roda no servidor, não no computador do laboratório. A aplicação publica apenas HTTP na porta 80; `app-1`, `app-2` e `app-3` permanecem na rede interna do Docker.

## Antes de começar

- EC2 com IPv4 público e DNS público;
- SSH liberado somente para a rede do laboratório;
- HTTP/80 liberado para a rede que fará os testes;
- usuário com `sudo`;
- pasta do laboratório copiada para a instância.

## Instalação guiada

```bash
chmod +x install-ec2.sh remote-lab.sh
./install-ec2.sh
./remote-lab.sh start
./remote-lab.sh status
```

Acesse `http://DNS-PUBLICO-DA-EC2/`.

## Experimentos

```text
http://DNS-PUBLICO/rr/catalogo/42
http://DNS-PUBLICO/weighted/catalogo/42
http://DNS-PUBLICO/least/catalogo/42
```

```bash
./remote-lab.sh failure
./remote-lab.sh logs
./remote-lab.sh recover
```

Cada aluno controla somente a sua instância. As contagens não recebem tráfego dos colegas.

## Diagnóstico por camada

```bash
# serviço local
curl -i http://127.0.0.1/status

# contêineres
./remote-lab.sh status

# configuração do Compose
./remote-lab.sh config

# logs recentes
./remote-lab.sh logs
```

Se o teste local funcionar e o navegador externo não, investigue o grupo de segurança, o endereço público e o firewall da instância. Se o nome não resolver, teste o IPv4 público para separar DNS de HTTP.

## Encerramento

```bash
./remote-lab.sh down
```

Depois siga a orientação do professor para interromper ou encerrar a EC2 e evitar custos desnecessários.

