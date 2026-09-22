# Linux Web & Game Development Setup Script 🚀

Script automatizado, modular e idempotente em Bash para instalação e preparação de um ambiente de desenvolvimento profissional no Linux (Ubuntu / Debian / derivados), **focado exclusivamente em Desenvolvimento Web e Desenvolvimento de Jogos (Game Dev)**.

---

## 📌 Visão Geral dos Componentes

| Categoria | Ferramentas & Tecnologias Incluídas |
| :--- | :--- |
| **Terminal & Shell** | **Zsh** (Shell Padrão), **Oh My Zsh**, **Tema Spaceship ZSH**, **Plugins**: `git`, `python`, `virtualenv`, `z`, `zsh-autosuggestions`, `zsh-syntax-highlighting` |
| **Game Dev** | **Godot Engine 4** (Stable), **Tiled Map Editor** (Mapas 2D), **OpenJDK 17** + **ADB** (Android Export SDK) |
| **Web Dev** | **Node.js LTS** (via NVM), **Yarn**, **pnpm**, **Docker CE & Docker Compose V2**, **PostgreSQL Client** (`psql`), **SQLite3**, **Postman**, **DBeaver CE** |
| **Containers Stack** | **PostgreSQL 16**, **Redis 7**, **Mailpit** (Web UI Email Testing), **Portainer CE**, **MinIO S3 Storage** |
| **IDE & Editor** | **VS Code** + Extensões mapeadas (Web, Game Dev, IA, DevOps, Temas, Ícones, Diagramas) |
| **Assistentes de IA** | **Claude CLI** (`@anthropic-ai/claude-code`), **Antigravity 2.0** (Ambiente, Aliases, CLI wrapper) |
| **Servidores MCP** | `postgres`, `puppeteer`, `figma`, `obsidian-rag` (Configurados para Claude & Antigravity) |
| **Plugins & Skills** | `chrome-devtools-plugin` (A11y, LCP, Memory Leak), `android-cli-plugin` (Android SDK & AVDs) |
| **Controle de Versão** | **GitHub SSH** (`id_ed25519`), **GitLab SSH** (`id_ed25519_gitlab`), **GitHub CLI (`gh`)** |
| **Auto-Cloning** | Clonagem automatizada dos repositórios ativos de Trabalho (Rimatur/Inovando), Pessoais, IA e Jogos |
| **Documentação** | **Obsidian** (Game Design Docs & Arquitetura de Sistemas) |

---

## 💻 Terminal & Shell (Zsh + Oh My Zsh + Tema Spaceship)

O script instala e configura o seu ambiente de terminal exatamente como você utiliza:

- **Shell**: **Zsh** definido como shell padrão do usuário (`chsh -s $(which zsh)`).
- **Framework**: **Oh My Zsh** (`~/.oh-my-zsh`).
- **Tema**: **Spaceship ZSH Theme** (`ZSH_THEME="spaceship"`).
- **Plugins Ativados**:
  - `git`: Atalhos e status de git no prompt.
  - `python` & `virtualenv`: Exibição de ambiente virtual ativo.
  - `z`: Navegação rápida por histórico de diretórios (`z pasta`).
  - `zsh-autosuggestions`: Sugestões automáticas ao digitar comandos.
  - `zsh-syntax-highlighting`: Destaque de sintaxe no terminal para comandos válidos/inválidos.
- **Fontes**: `fonts-powerline` para ícones do tema no terminal.

---

## 🐳 Stack de Containers Docker (`docker-compose.yml`)

O script configura uma stack de desenvolvimento local com os containers pré-configurados em `~/.docker-dev-stack/docker-compose.yml`:

- **PostgreSQL 16**: `localhost:5432` (Usuário: `postgres`, Senha: `postgres`, BD: `dev_db`)
- **Redis 7**: `localhost:6379`
- **Mailpit (Web Mail Testing)**: `http://localhost:8025` (Porta SMTP: `1025`)
- **Portainer CE (Gestão do Docker)**: `http://localhost:9000`
- **MinIO (Armazenamento S3 Local)**: `http://localhost:9001` (User: `minioadmin`, Pass: `minioadmin`)

### Atalhos no Terminal:
- `dev-stack-up`: Inicia todos os containers em segundo plano.
- `dev-stack-down`: Para todos os containers.
- `dev-stack-ps`: Lista o status dos containers.
- `dev-stack-logs`: Exibe os logs unificados.

---

## 📂 Clonagem Automática de Repositórios (`clone_repos.sh`)

Script idempotente para clonar e manter atualizados os seus repositórios ativos de trabalho e pessoais nas suas estruturas originais:

### Catalogação de Repositórios:
1. **Trabalho (Rimatur & Inovando - GitLab / GitHub)**:
   - `git@git.inovan.do:rimatur/api-portal-rimatur.git` -> `~/Projects/Rimatur/api-portal-rimatur`
   - `git@git.inovan.do:rimatur/next-portal-rimatur.git` -> `~/Projects/Rimatur/next-portal-rimatur`
   - `git@git.inovan.do:inovando/lowcode/front-low-code.git` -> `~/Inovando/LowCode/front-low-code`
   - `git@git.inovan.do:inovando/lowcode/adonis-low-code.git` -> `~/Inovando/LowCode/adonis-low-code`
   - `git@git.inovan.do:inovando/langfuse-client-sh.git` -> `~/Projects/langfuse-client-sh`
   - `git@github.com:inovando/adonis-crud.git` -> `~/Inovando/adonis-crud-packege/adonis-crud`
   - `git@github.com:inovando/obsidian-rag-tools.git` -> `~/Projects/local_rag_obisidian_project`

2. **Pessoais & IA (GitHub)**:
   - `git@github.com:jeanc-alves/finanace-hub-app.git` -> `~/Projects/IA/finance-hub-app`
   - `git@github.com:jeanc-alves/finance-hub-backend.git` -> `~/Projects/IA/finance-hub-backend`
   - `git@github.com:jeanc-alves/NestApi.git` -> `~/Projects/NestApi/nest-api`
   - `git@github.com:jeanc-alves/rentx.git` -> `~/Inovando/rentx`
   - `git@github.com:Jean1dev/mba-ia.git` -> `~/MeuVaultRAG/mba-ia`
   - `git@github.com:jeanc-alves/my-setup-bash.git` -> `~/Projects/my-setup-bash`

3. **Desenvolvimento de Jogos**:
   - `git@github.com:otland/forgottenserver.git` -> `~/Projects/games/forgottenserver`
   - `git@github.com:otland/otclient.git` -> `~/Projects/games/otclient`

---

## 🔑 Configuração de Chaves SSH (GitHub & GitLab)

Chaves SSH Ed25519 independentes para projetos pessoais e profissionais:
- **GitHub (Pessoal / Open Source)**: `~/.ssh/id_ed25519`
- **GitLab (Trabalho / Empresa)**: `~/.ssh/id_ed25519_gitlab`

---

## 🤖 Mapeamento de Servidores MCP & Plugins de IA

- **Servidores MCP (`~/.claude/mcp.json` e `~/.antigravity/mcp.json`)**: `postgres`, `puppeteer`, `figma`, `obsidian-rag`.
- **Plugins & Skills (`~/.antigravity/plugins/plugins.json`)**: `chrome-devtools-plugin`, `android-cli-plugin`.

---

## 🧩 Extensões Mapeadas do VS Code

Extensões essenciais para IA, Web, Game Dev, DevOps, Temas e Diagramas (`geequlim.godot-tools`, `anthropic.claude-code`, `ms-azuretools.vscode-docker`, `dbaeumer.vscode-eslint`, `esbenp.prettier-vscode`, `eamodio.gitlens`, `dracula-theme.theme-dracula`, `PKief.material-icon-theme`).

---

## 💻 Como Usar

### 1. Dar Permissão de Execução
```bash
chmod +x setup.sh clone_repos.sh setup_docker_stack.sh
```

### 2. Modo Interativo (Menu Geral)
```bash
./setup.sh
```

### 3. Instalação Completa Automatizada
```bash
./setup.sh --all
```

### 4. Execução de Módulos Específicos
```bash
# Clonar todos os repositórios mapeados do seu ambiente
./setup.sh --clone
# Ou diretamente:
./clone_repos.sh --all

# Configurar e baixar a stack de containers Docker
./setup.sh --docker-stack
# Ou diretamente:
./setup_docker_stack.sh

# Instalar a stack de jogos (Godot 4, Tiled, OpenJDK Android)
./setup.sh --gamedev

# Instalar a stack Web (Docker, Node, Postgres, Postman, DBeaver)
./setup.sh --web

# Configurar Servidores MCP e Plugins (Claude & Antigravity)
./setup.sh --mcp

# Configurar Chaves SSH (GitHub & GitLab)
./setup.sh --ssh

# Instalar VS Code e extensões mapeadas
./setup.sh --vscode
```
