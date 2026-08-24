# README

Sistema de juiz automático da 7ª Maratona de Programação do curso de Sistemas de
Informação da UniRios. Leia o `CLAUDE.md` e o `docs/ROADMAP.md` antes de mexer no código.

No macOS e no Linux, use `bin/setup` e depois `bin/dev`.

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
Com o backend Hyper-V do Docker Desktop, isso exige compartilhar o drive `C:` em
*Settings > Resources > File Sharing* - sem isso o Docker recusa o mount com
"path is not shared from the host" e toda submissão fica pendente para sempre.
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
bundle exec rails test
```

### Por que a fila roda em modo `async`

O supervisor do Solid Queue cria os workers com `fork`, que não existe no Ruby do Windows.
O `Procfile.dev.windows` sobe o supervisor em `mode: :async`, que roda workers e
dispatchers em threads no mesmo processo. Para ~15 equipes é folgado.
