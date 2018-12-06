# k8s-benchmark-test
Estudo de comportamento de aplicações no k8s

Cada tópico importante é adicionado na [wiki](https://github.com/hurbcom/k8s-benchmark-tests/wiki/home)



## Multiplas threads dentro de um container ou 1 thread só quando há autoscaling?
O ponto aqui é não é a taxa de requests mas sim o comportamento do container, lembrando que o uso de memória da aplicação é multiplicado pela quantidade de threads. Se for definido o  número de threads for 8 e o máximo de memória da aplicação for de 1GB, a aplicação tentará usar 8GB e se o limit configurado for de 1GB as threads vão ser killadas pois pasarrá de 1GB configurado.

- [ ] múltiplas threads -> logs: [local docker](https://github.com/hurbcom/k8s-benchmark-tests/wiki/stress-multi-thread#local) e [gce](https://github.com/hurbcom/k8s-benchmark-tests/wiki/stress-multi-thread#gce)
- [X] 1 thread -> logs: [local docker](https://github.com/hurbcom/k8s-benchmark-tests/wiki/stress-single-thread#local) e [gce](https://github.com/hurbcom/k8s-benchmark-tests/wiki/stress-single-thread#gce)


## Comportamento de request/limit das aplicações (kubernetes 1.x)
- [X] request e limit de memória: **precisam ser iguais (não há autoscaling) para aplicações críticas**
- [X] número mágico de limit de cpu para aplicações matemáticas, científicas ou IAs: **Acima de 1000m e abaixo de (número de cores da máquina mãe)x1000m**
- [X] Número mágico de limit de cpu: **depende da natureza da aplicação**
- [X] Número mágico de request de cpu:  **depende da natureza da aplicação**

## kubepodmetric
- [wiki](https://github.com/hurbcom/k8s-benchmark-tests/wiki/kubepodmetric)
