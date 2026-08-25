# O processo de jobs no host Windows não depende de pipe nem de autoload

O juiz redireciona a saída do `docker run` para **arquivo**, nunca para pipe, e o
`ActiveJob::Arguments` é carregado no boot, antes de qualquer thread de worker existir.

As duas decisões existem pela mesma razão: no host Windows do laboratório, o processo de
jobs é o único ponto do sistema onde uma falha não aparece. Ele não tem tela, não devolve
erro para ninguém, e a Equipe vê apenas "Na fila, ainda sendo julgada" — para sempre.

## O pipe

O `Open3.capture3` lê a saída do `docker` até o fim do pipe. No Windows, esse fim nunca
chegou: o contêiner rodou, escreveu os três Casos de Teste em `/out` e terminou, e mesmo
assim a leitura ficou pendurada — o runtime do Docker Desktop deixa o pipe aberto num
processo auxiliar que sobrevive ao contêiner. Pior: a leitura bloqueada travou o processo
inteiro, inclusive a thread de heartbeat, e o Solid Queue acabou marcando o próprio
processo como morto (`ProcessPrunedError`) com a Submissão presa dentro dele.

Com `Process.spawn(..., out:, err:)` não há pipe: o `docker` escreve em dois arquivos
dentro do diretório temporário que já é descartado no fim do julgamento, e o processo pai
espera apenas o fim do processo filho. O que o `docker` imprimiu continua chegando ao
Veredicto — é dele que sai a mensagem quando o contêiner não deixa rastro.

## O autoload

`ActiveJob::Arguments` é carregado sob demanda, e o arquivo define os métodos privados
depois de constantes que disparam um segundo autoload. Uma thread que referencia o módulo
enquanto outra ainda o está carregando enxerga um módulo pela metade: `deserialize`
existe, `deserialize_argument` ainda não. O worker em `mode: :async` tem três threads e
julga a primeira Submissão logo depois de subir, que é exatamente a janela.

O sintoma é um `ActiveJob::DeserializationError` que não fala de julgamento nenhum, num
Job que nunca chegou a rodar. Carregar a constante no boot fecha a janela: quando as
threads existem, o módulo já está inteiro.

## Consequências

Nada disso aparece no macOS ou no Linux, e nada disso é visível em teste unitário — o
`test/judge_test.rb` sempre passou. O que revela as duas falhas é o `maratona:doctor`:
`Queue processes` acusa o heartbeat parado, `Failed jobs` mostra a exceção, e
`Pending submissions` conta as Equipes esperando.
