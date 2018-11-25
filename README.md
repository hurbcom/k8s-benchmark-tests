# k8s-benchmark-test
Estudo de comportamento de aplicações no k8s

Cada tópico importante é adicionado na [wiki](https://github.com/hurbcom/k8s-benchmark-tests/wiki/home)



## Multiplas threads dentro de um container ou 1 thread só quando há autoscaling?
- [ ] múltiplas threads
- [ ] 1 thread


## Comportamento de request/limit das aplicações (kubernetes 1.x)
- [X] request e limit de memória: **precisam ser iguais (não há autoscaling) para aplicações críticas**
- [X] número mágico de limit de cpu para aplicações matemáticas, científicas ou IAs: **Acima de 1000m e abaixo de (número de cores da máquina mãe)x1000m**
- [ ] Número mágico de limit de cpu
- [ ] Número mágico de request de cpu
