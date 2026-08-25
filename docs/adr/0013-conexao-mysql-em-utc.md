# Toda conexão MySQL fala UTC, não a hora do relógio da máquina

O `config/database.yml` manda `time_zone: "+00:00"` em toda conexão. O app não confia na
zona de tempo do servidor MySQL, seja ele o do laboratório, o de um contêiner ou o da
máquina de quem desenvolve.

O MySQL vem com `time_zone = SYSTEM`, então `CURRENT_TIMESTAMP` nasce na hora local — no
Brasil, três horas atrás do que o Rails entende por agora. E há colunas cujo valor o banco
escreve sozinho: `sessions.last_active_at` tem `default: CURRENT_TIMESTAMP(6)`, e as
tabelas do Solid Queue fazem o mesmo nos registros que insere em lote.

O efeito é uma Sessão que **nasce expirada**: `Session.active` procura por
`last_active_at` dentro dos últimos 10 minutos, e o valor gravado pelo banco já está três
horas fora da janela. A Equipe entra e é tratada como ausente no request seguinte — e a
Sessão única por Equipe (Art. 21, [ADR-0009](./0009-sessao-unica-por-equipe.md)) deixa de
valer, porque nenhuma Sessão jamais consta como ativa.

Nada disso aparece onde o relógio da máquina já é UTC, que é como o defeito passou pelo
desenvolvimento e só se revelou no host do laboratório. Quatro testes o denunciam, todos
falando de Sessão; nenhum fala de fuso.

## Consequências

Mudar a configuração do servidor MySQL resolveria na máquina em que fosse mudada. A
diretiva na conexão resolve em qualquer máquina onde o app rode, que é o que importa numa
noite só, num laboratório que não é nosso.

O `Time.zone` do Rails continua UTC ([ADR-0008](./0008-relogio-relativo-ao-inicio-real.md)
conta o tempo do início real da Competição, não de horário de parede) e o que a Equipe lê
na tela continua sendo formatado na hora local.
