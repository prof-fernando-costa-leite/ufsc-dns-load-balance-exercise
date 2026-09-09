# Roteiro do aluno: prática de DNS e load balancer

## Resultado esperado

Ao final, você deverá explicar com evidências como o DNS conduz ao servidor, como a porta 80 recebe o HTTP, como o caminho seleciona uma política do NGINX e como o balanceador escolhe um backend.

Em cada experimento: faça uma previsão, guarde a saída, compare-a com o esperado e explique o mecanismo observado.

## 1. Ambiente e modalidade

```bash
hostname
systemd-detect-virt || true
```

- Resultado `lxc`: use o modo nativo.
- EC2 ou VM completa: use o modo Docker.

Para testar dentro do próprio servidor:

```bash
LAB_HOST=127.0.0.1
```

Para testar externamente, substitua pelo DNS público fornecido pelo professor.

## 2. Inicialização

Modo nativo em LXC:

```bash
chmod +x install-native.sh native-lab.sh
./install-native.sh
./native-lab.sh start
./native-lab.sh status
```

Modo Docker em EC2 ou VM:

```bash
chmod +x install-ec2.sh remote-lab.sh
./install-ec2.sh
./remote-lab.sh start
./remote-lab.sh status
```

Use `native-lab.sh` ou `remote-lab.sh` nos comandos seguintes, conforme a modalidade escolhida.

## 3. DNS público

No computador do laboratório:

```bash
dig DNS_PUBLICO A
```

Alternativas:

```bash
nslookup DNS_PUBLICO
```

```powershell
Resolve-DnsName DNS_PUBLICO -Type A
```

Registre endereço, TTL quando disponível e servidor DNS consultado. Verifique se a resposta contém algum caminho HTTP ou nome de backend.

## 4. Evidências HTTP

```bash
curl -i "http://${LAB_HOST}/rr/catalogo/42"
```

Localize:

- `X-LB-Policy`: política selecionada pelo caminho;
- `X-LB-Upstream`: endereço interno escolhido pelo NGINX;
- `X-Backend-Instance`: processo que executou a requisição.

## 5. Round-robin

Preveja a distribuição de 12 requisições e execute:

```bash
for i in $(seq 1 12); do
  curl -s -D - -o /dev/null "http://${LAB_HOST}/rr/catalogo/42" |
    grep -i X-Backend-Instance
done | sort | uniq -c
```

Com os backends saudáveis e sem tráfego concorrente, espere `4/4/4`. Qualquer acesso à rota `/rr/` também avança o estado desse pool.

## 6. Weighted round-robin

O pool usa pesos `3:1:1`. Converta a proporção em uma previsão para 25 requisições e execute:

```bash
for i in $(seq 1 25); do
  curl -s -D - -o /dev/null "http://${LAB_HOST}/weighted/catalogo/42" |
    grep -i X-Backend-Instance
done | sort | uniq -c
```

Sem interferência, espere `app-1=15`, `app-2=5` e `app-3=5`. A ordem não precisa apresentar três respostas consecutivas de `app-1`.

## 7. Least connections

Com pedidos rápidos, as conexões terminam antes da seleção seguinte e o comportamento pode se parecer com round-robin. Mantenha duas requisições lentas em andamento:

```bash
curl -s "http://${LAB_HOST}/least/slow?ms=4000" &
curl -s "http://${LAB_HOST}/least/slow?ms=4000" &

for i in $(seq 1 8); do
  curl -s -D - -o /dev/null "http://${LAB_HOST}/least/catalogo/42" |
    grep -i X-Backend-Instance
done

wait
```

Explique a sequência considerando as conexões ativas no instante de cada decisão. Em caso de empate, o NGINX alterna entre os destinos empatados.

## 8. Falha e recuperação

Interrompa `app-2`:

```bash
./native-lab.sh failure
```

No modo Docker, troque por `./remote-lab.sh failure`. Depois execute:

```bash
for i in $(seq 1 9); do
  curl -s -D - -o /dev/null "http://${LAB_HOST}/rr/catalogo/42" |
    grep -i X-Backend-Instance
done
```

Verifique se `app-2` desapareceu e se o cliente continuou recebendo respostas. Consulte os logs:

```bash
./native-lab.sh logs
```

Restaure com `./native-lab.sh recover`. No modo Docker, use os comandos equivalentes de `remote-lab.sh`.

## 9. Encerramento

```bash
./native-lab.sh down
```

No modo Docker, use `./remote-lab.sh down`. Siga a orientação do professor para interromper ou encerrar a máquina.
