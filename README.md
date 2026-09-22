# Linux Web & Game Development Setup Script 🚀

Script automatizado, modular e idempotente em Bash para instalação e preparação de um ambiente de desenvolvimento profissional no Linux (Ubuntu / Debian / derivados), **focado exclusivamente em Desenvolvimento Web e Desenvolvimento de Jogos (Game Dev)**.

---

## 📌 Visão Geral dos Componentes

| Categoria | Ferramentas & Tecnologias Incluídas |
| :--- | :--- |
| **Game Dev** | **Godot Engine 4** (Stable), **Tiled Map Editor** (Mapas 2D), **OpenJDK 17** + **ADB** (Android Export SDK) |
| **Web Dev** | **Node.js LTS** (via NVM), **Yarn**, **pnpm**, **Docker CE & Docker Compose V2**, **PostgreSQL Client** (`psql`), **SQLite3**, **Postman**, **DBeaver CE** |
| **IDE & Editor** | **VS Code** + Extensões mapeadas (Web, Game Dev, IA, DevOps, Temas, Ícones, Diagramas) |
| **Assistentes de IA** | **Claude CLI** (`@anthropic-ai/claude-code`), **Antigravity 2.0** (Ambiente, Aliases, CLI wrapper) |
| **Servidores MCP** | `postgres`, `puppeteer`, `figma`, `obsidian-rag` (Configurados para Claude & Antigravity) |
| **Plugins & Skills** | `chrome-devtools-plugin` (A11y, LCP, Memory Leak), `android-cli-plugin` (Android SDK & AVDs) |
| **Controle de Versão** | **GitHub SSH** (`id_ed25519`), **GitLab SSH** (`id_ed25519_gitlab`), **GitHub CLI (`gh`)** |
| **Documentação** | **Obsidian** (Game Design Docs & Arquitetura de Sistemas) |

---

## 🔑 Configuração de Chaves SSH (GitHub & GitLab)

O script configura chaves SSH Ed25519 independentes para que você possa trabalhar facilmente em projetos pessoais e profissionais:

- **GitHub (Pessoal / Open Source)**: `~/.ssh/id_ed25519`
- **GitLab (Trabalho / Empresa)**: `~/.ssh/id_ed25519_gitlab`

As permissões do diretório `~/.ssh` (700) e do arquivo `~/.ssh/config` (600) são ajustadas automaticamente com as seguintes regras de Host:

```sshconfig
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    AddKeysToAgent yes

Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519_gitlab
    AddKeysToAgent yes
```

---

## 🤖 Mapeamento de Servidores MCP & Plugins de IA

### Servidores MCP (`~/.claude/mcp.json` e `~/.antigravity/mcp.json`)
- **`postgres`** (`@yawlabs/postgres-mcp`): Conexão e execução de queries em bancos PostgreSQL.
- **`puppeteer`** (`@modelcontextprotocol/server-puppeteer`): Automação de testes em navegadores headless.
- **`figma`** (`@modelcontextprotocol/server-figma`): Inspeção de design systems e assets no Figma.
- **`obsidian-rag`**: Pesquisa RAG e gerenciamento de notas no seu vault do Obsidian.

### Plugins & Skills (`~/.antigravity/plugins/plugins.json`)
- **`chrome-devtools-plugin`**: Skills `a11y-debugging`, `chrome-devtools`, `debug-optimize-lcp`, `memory-leak-debugging`, `troubleshooting`.
- **`android-cli-plugin`**: Skill `android-cli` para gerenciamento do SDK Android, emuladores (AVDs) e logs.

---

## 🧩 Extensões Mapeadas do VS Code

O script instala automaticamente as extensões essenciais para a sua stack:

- **Assistentes de IA**: `anthropic.claude-code`
- **Desenvolvimento de Jogos**: `geequlim.godot-tools`, `ms-python.python`
- **Desenvolvimento Web & Frontend**: `dbaeumer.vscode-eslint`, `esbenp.prettier-vscode`, `bradlc.vscode-tailwindcss`, `clinyong.vscode-css-modules`, `dsznajder.es7-react-js-snippets`, `willstakayama.vscode-nextjs-snippets`, `styled-components.vscode-styled-components`, `ritwickdey.liveserver`
- **DevOps & Ferramentas**: `ms-azuretools.vscode-docker`, `eamodio.gitlens`
- **Visualização & Diagramas**: `simonsiefke.svg-preview`, `mermaidchart.vscode-mermaid-chart`, `shd101wyy.markdown-preview-enhanced`, `naumovs.color-highlight`
- **Temas & Ícones**: `dracula-theme.theme-dracula`, `robbowen.synthwave-vscode`, `PKief.material-icon-theme`

---

## 💻 Como Usar

### 1. Dar Permissão de Execução
```bash
chmod +x setup.sh
```

### 2. Modo Interativo (Menu com Opções)
Execute o script sem parâmetros para abrir o menu interativo:
```bash
./setup.sh
```

### 3. Instalação Completa Automatizada
```bash
./setup.sh --all
```

### 4. Execução de Módulos Específicos
```bash
# Instalar apenas a stack de jogos (Godot 4, Tiled, OpenJDK Android)
./setup.sh --gamedev

# Instalar apenas a stack Web (Docker, Node, Postgres, Postman, DBeaver)
./setup.sh --web

# Configurar apenas Servidores MCP e Plugins (Claude & Antigravity)
./setup.sh --mcp

# Configurar apenas Chaves SSH (GitHub & GitLab)
./setup.sh --ssh

# Instalar apenas VS Code e extensões mapeadas
./setup.sh --vscode
```

### 5. Resumo de Flags CLI (`./setup.sh --help`)
- `--all`: Instala todo o ambiente (Web + Game Dev + MCPs + Plugins + SSH + VS Code)
- `--gamedev`: Instala ferramentas de jogos (Godot 4, Tiled, OpenJDK 17, ADB)
- `--web`: Instala ferramentas Web (Docker CE, Node LTS, Yarn, pnpm, Postgres, Postman, DBeaver)
- `--mcp`: Configura Servidores MCP (`postgres`, `puppeteer`, `figma`, `obsidian-rag`) e Plugins
- `--base`: Instala dependências base do sistema (Git, Python 3, Node LTS, C++)
- `--docker`: Instala Docker CE & Docker Compose V2
- `--ssh`: Gera e configura chaves SSH para GitHub e GitLab
- `--vscode`: Instala VS Code e todas as extensões mapeadas
- `--ai`: Instala Claude CLI, Antigravity 2.0, Obsidian e Servidores MCP

---

## 📋 Passos Pós-Instalação

1. **Recarregar Perfil do Shell**:
   ```bash
   source ~/.bashrc   # Ou source ~/.zshrc
   ```

2. **Adicionar Chaves SSH aos Perfis**:
   - **GitHub**: Copie o conteúdo de `cat ~/.ssh/id_ed25519.pub` e adicione em [https://github.com/settings/keys](https://github.com/settings/keys).
   - **GitLab**: Copie o conteúdo de `cat ~/.ssh/id_ed25519_gitlab.pub` e adicione em [https://gitlab.com/-/profile/keys](https://gitlab.com/-/profile/keys).

3. **Autenticar o Claude CLI**:
   ```bash
   export ANTHROPIC_API_KEY="seu_token_aqui"
   claude
   ```
