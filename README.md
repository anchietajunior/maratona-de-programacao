# README

Sistema de juiz automático da 7ª Maratona de Programação do curso de Sistemas de
Informação da UniRios. Leia o `CLAUDE.md` e o `docs/ROADMAP.md` antes de mexer no código.

No macOS e no Linux, use `bin/setup` e depois `bin/dev`.

## Rodando no Windows

Nada de `bin/` no Windows: `bin/dev` é um script `sh`, e o PowerShell/cmd ignora a linha
`#!/usr/bin/env ruby` do resto dos binstubs. O `Procfile.dev.windows` chama tudo por
`bundle exec`, sem passar por `bin/`.

### Pré-requisitos

- **Ruby 4.0.3** via [RubyInstaller](https://rubyinstaller.org/) (escolha a versão
  *with Devkit*, necessária para compilar o `mysql2`).
- **MySQL** rodando em `127.0.0.1:3306`, usuário `root`, senha `12345`
  (use `DB_HOST` para apontar para outro host).
- **Docker Desktop** ligado, com a imagem `python:3.12-slim` já baixada — o julgamento roda
  o código submetido em containers descartáveis.

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

### Testes

```powershell
bundle exec rails test
```

### Por que a fila roda em modo `async`

O supervisor do Solid Queue cria os workers com `fork`, que não existe no Ruby do Windows.
O `Procfile.dev.windows` sobe o supervisor em `mode: :async`, que roda workers e
dispatchers em threads no mesmo processo. Para ~15 equipes é folgado.
