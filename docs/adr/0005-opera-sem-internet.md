# O sistema roda numa máquina do laboratório e não depende de internet

A Maratona acontece num laboratório fechado com os Alunos na mesma rede local, acessando o
servidor por IP interno. O sistema precisa funcionar com a internet caída, porque a rede
da faculdade cair no dia do evento é um risco real e o evento não pode parar.

## Consequências

**Nenhum asset pode vir de CDN.** O editor de código, a fonte, o CSS — tudo servido
localmente. Um `<script src="https://cdn...">` funciona perfeitamente em desenvolvimento e
quebra a Maratona inteira no dia, que é o pior modo de falha possível: invisível até
importar.

Isso vale também para as imagens de contêiner do executor: elas precisam estar presentes
na máquina antes do evento, não baixadas sob demanda.
