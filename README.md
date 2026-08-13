# README

Sistema de juiz automático da 7ª Maratona de Programação do curso de Sistemas de
Informação da UniRios. Leia o `CLAUDE.md` e o `docs/ROADMAP.md` antes de mexer no código.

No macOS e no Linux, use `bin/setup` e depois `bin/dev`.

## Rodando no Windows

`bin/dev` é um script `sh` e não roda no PowerShell/cmd. Além disso, o Windows ignora a
linha `#!/usr/bin/env ruby` dos scripts em `bin/`, então cada processo precisa ser chamado
com `ruby` na frente — é exatamente isso que o `Procfile.dev.windows` faz.

### Pré-requisitos

- **Ruby 4.0.3** via [RubyInstaller](https://rubyinstaller.org/) (escolha a versão
  *with Devkit*, necessária para compilar o `mysql2`).
- **MySQL** rodando em `127.0.0.1:3306`, usuário `root`, senha `12345`
  (use `DB_HOST` para apontar para outro host).
- **Docker Desktop** ligado, com a imagem `python:3.12-slim` já baixada — o julgamento roda
  o código submetido em containers descartáveis.

### Preparando

```powershell
bundle install
ruby bin/setup --skip-server
```

### Rodando

```powershell
foreman start -f Procfile.dev.windows
```

A aplicação sobe em <http://localhost:3001>. Se o `foreman` não estiver instalado:

```powershell
gem install foreman
```

### Testes

```powershell
ruby bin/rails test
```
