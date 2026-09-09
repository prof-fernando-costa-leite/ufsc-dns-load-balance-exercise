# Entrega da prática: DNS e load balancer

**Nome:** __________________________________  **Turma:** __________

**Servidor:** ______________________________  **Data:** ___________

**Modalidade:** [ ] Nativa em LXC  [ ] Docker em EC2 ou VM

Anexe as saídas solicitadas. Diferenças entre previsão e observação devem ser explicadas, não apagadas.

## 1. Ambiente

**Saídas de `hostname` e `systemd-detect-virt`:**

```text

```

Qual modalidade foi utilizada? Explique a escolha.


## 2. DNS

**Hostname público consultado:**

**Endereço retornado:**

**TTL, quando disponível:**

**Servidor DNS consultado:**

**Saída relevante da consulta:**

```text

```

1. A resposta contém `/rr/`, `/weighted/` ou `/least/`?
2. A resposta informa qual backend atenderá a requisição?
3. Explique onde termina a decisão do DNS e onde começam as decisões do NGINX.


## 3. Evidências HTTP

**Cabeçalhos recebidos em `/rr/catalogo/42`:**

```text

```

Explique o que cada cabeçalho comprova:

- `X-LB-Policy`:
- `X-LB-Upstream`:
- `X-Backend-Instance`:

Complete:

```text
hostname -> endereço __________ -> porta ____ -> NGINX -> política __________ -> backend __________
```

## 4. Round-robin

| Instância | Quantidade prevista | Quantidade observada |
|---|---:|---:|
| app-1 | | |
| app-2 | | |
| app-3 | | |

**Saída recebida:**

```text

```

1. A saída confere com sua previsão?
2. Ela confere com o comportamento esperado do round-robin?
3. Se houve diferença, existiam backends inicializando, falhas ou outras requisições usando `/rr/`?
4. Explique a relação entre a sequência observada e o algoritmo.


## 5. Weighted round-robin

Pesos configurados: `app-1=3`, `app-2=1`, `app-3=1`.

| Instância | Quantidade prevista | Quantidade observada |
|---|---:|---:|
| app-1 | | |
| app-2 | | |
| app-3 | | |

**Saída recebida:**

```text

```

1. A saída confere com a proporção `3:1:1`?
2. Qual porcentagem aproximada dos pedidos foi atendida por `app-1`?
3. A ordem precisa apresentar três respostas consecutivas de `app-1`? Explique.
4. Se o resultado não foi `15/5/5`, apresente uma hipótese verificável.


## 6. Least connections

**Previsão antes das requisições lentas:**


**Sequência recebida para os oito pedidos rápidos:**

```text

```

1. Quais backends receberam as requisições lentas?
2. Quais backends receberam mais pedidos rápidos?
3. A saída confere com sua previsão?
4. Por que pedidos rápidos, sem conexões ocupadas, podem produzir uma sequência parecida com round-robin?
5. Em que momento o NGINX mede a quantidade de conexões?


## 7. Falha de app-2

**Saída das nove requisições após interromper `app-2`:**

```text

```

1. `app-2` apareceu nas respostas úteis?
2. O cliente recebeu algum erro? Informe o status HTTP observado.
3. Como o NGINX reagiu à indisponibilidade?
4. Por que o registro DNS permaneceu igual?
5. Cole uma linha de log que sustente sua explicação.

**Evidência de recuperação de `app-2`:**

```text

```

## 8. Síntese

Complete com frases tecnicamente precisas:

1. O DNS forneceu...
2. A porta 80 identificou...
3. O caminho HTTP selecionou...
4. O load balancer escolheu...

## 9. Encerramento

**Comando utilizado:** __________________________________________

**Situação final da máquina:** [ ] laboratório parado  [ ] máquina interrompida  [ ] máquina encerrada
