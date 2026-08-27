# README

Sistema de juiz automático da 7ª Maratona de Programação do curso de Sistemas de
Informação da UniRios. Leia o `CLAUDE.md` e o `docs/ROADMAP.md` antes de mexer no código.

No macOS e no Linux, use `bin/setup` e depois `bin/dev`.

## Populando o banco com os problemas

Os 10 problemas da prova moram em `db/seeds.rb` - enunciado, solução de referência e as
entradas dos casos de teste.
A saída esperada de cada caso não está no arquivo: ela nasce de rodar a solução de
referência em container (ADR-0003), então o seed exige o Docker ligado e a imagem
`python:3.12-slim` presente.

No macOS e no Linux:

```bash
bin/rails db:seed
```

No Windows:

```powershell
bundle exec rails db:seed
```

O seed é idempotente: rodar de novo não duplica nada, só cria o que falta.
Além dos problemas, ele cria as duas comissões (`staff01`, `staff02`) e as 15 equipes
(`equipe01` a `equipe15`), todas com a senha `12345` - defina `SEED_PASSWORD` para trocar.

Duas pegadinhas:

- O `db:prepare` só roda o seed quando cria o banco pela primeira vez.
  Num banco que já existe, rode `db:seed` explicitamente.
- Se algum problema foi cadastrado à mão pelo painel, o seed para com
  "Position já está em uso" - apague o problema manual pelo painel e rode de novo.

## Rodando no Windows

Nada de `bin/` no Windows: `bin/dev` é um script `sh`, e o PowerShell/cmd ignora a linha
`#!/usr/bin/env ruby` do resto dos binstubs. O `Procfile.dev.windows` chama tudo por
`bundle exec`, sem passar por `bin/`.

### Pré-requisitos

- **Ruby 4.0.6** via [RubyInstaller](https://rubyinstaller.org/) (escolha a versão
  *with Devkit*, necessária para compilar o `mysql2`).
- **MySQL** rodando em `127.0.0.1:3306`, usuário `root`, senha `12345`
  (use `DB_HOST` para apontar para outro host).
- **Docker Desktop** ligado, com a imagem `python:3.12-slim` já baixada — o julgamento roda
  o código submetido em containers descartáveis.

### Containers

O app não roda em container - nem o servidor web, nem os jobs em segundo plano.
O Docker serve só para o juiz: cada submissão executa num container descartável da imagem
`python:3.12-slim`, sem rede e com limites de CPU, memória e tempo (ADR-0004).

Baixe a imagem antes de preparar o banco - as saídas esperadas dos casos de teste nascem
de rodar a solução de referência em container (ADR-0003), então o seed exige Docker:

```powershell
docker pull python:3.12-slim
```

Se preferir o MySQL em container em vez de instalado na máquina:

```powershell
docker run -d --name maratona-mysql --restart unless-stopped `
  -e MYSQL_ROOT_PASSWORD=12345 -p 3306:3306 `
  -v maratona-mysql-data:/var/lib/mysql mysql:8
```

Use MySQL 8: a collation padrão `utf8mb4_0900_ai_ci` é a que o projeto assume (ADR-0003).

O juiz monta diretórios temporários de `C:\Users\...\AppData\Local\Temp` dentro do
container.
Sem o WSL 2 instalado, o Docker Desktop sobe a própria VM e começa sem nenhum diretório
compartilhado: é preciso adicionar `C:\Users` (e a pasta do projeto) em
*Settings > Resources > File Sharing* e reiniciar o Docker Desktop. Sem isso o Docker
recusa o mount com "path is not shared from the host" - toda submissão fica pendente para
sempre e nenhum caso de teste chega a ser cadastrado, porque a saída esperada também nasce
de um container (ADR-0003).
Com o backend WSL 2 (*Settings > General > Use the WSL 2 based engine*), funciona sem
configuração.
Depois de qualquer suspeita, rode `bundle exec rails maratona:doctor` - ele testa a
fila, o Docker, o bind mount e um julgamento real de ponta a ponta.

### Preparando

```powershell
gem install foreman
bundle install
bundle exec rails db:prepare
```

### Rodando

```powershell
foreman start -f Procfile.dev.windows
```

A aplicação sobe em <http://localhost:3001>.

Se o `foreman` der problema, abra três terminais e rode uma linha do
`Procfile.dev.windows` em cada um — é o mesmo efeito.

### Acesso das equipes

As equipes não instalam nada: acessam pelo navegador a máquina que roda o app, em
`http://<ip-da-maquina>:3001`.
O servidor já escuta em todas as interfaces (`-b 0.0.0.0` no `Procfile.dev.windows`).
Na primeira execução, libere a porta 3001 no Firewall do Windows quando ele perguntar -
sem isso, só a própria máquina alcança o app.
Descubra o IP da máquina com `ipconfig` (campo "Endereço IPv4").

### Testes

```powershell
$env:PARALLEL_WORKERS="1"; bundle exec rails test
```

O `PARALLEL_WORKERS=1` não é opcional aqui: o runner paralelo do Rails cria os processos
com `fork`, que não existe no Ruby do Windows - a mesma razão pela qual a fila roda em
modo `async`.

### Por que a fila roda em modo `async`

O supervisor do Solid Queue cria os workers com `fork`, que não existe no Ruby do Windows.
O `Procfile.dev.windows` sobe o supervisor em `mode: :async`, que roda workers e
dispatchers em threads no mesmo processo. Para ~15 equipes é folgado.
