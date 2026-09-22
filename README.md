# Linux Web & Game Development Setup Script

Script automatizado e modular em Bash para instalação e preparação de um ambiente de desenvolvimento **focado exclusivamente em Desenvolvimento Web e Desenvolvimento de Jogos (Game Dev)** no Linux (Ubuntu / Debian).

## 🎮 Suíte de Desenvolvimento de Jogos (Game Dev)

- **Godot Engine 4 (Stable)**: Download do binário oficial de 64-bit instalado em `~/.local/bin/godot`, atalho `.desktop` no menu do sistema e integração do servidor de linguagem GDScript (LSP porta 6005) e executável no VS Code (`settings.json`).
- **Tiled Map Editor**: Editor de mapas e tilemaps 2D essencial para criação de níveis de jogos.
- **Android Export SDK**: Instalação do OpenJDK 17 (`openjdk-17-jdk`) e ADB (`android-tools-adb`) para compilar e testar jogos em dispositivos Android.

## 🌐 Suíte de Desenvolvimento Web

- **Node.js LTS, Yarn e pnpm**: Gerenciamento avançado de pacotes frontend e backend.
- **Docker CE & Docker Compose V2**: Containerização completa de serviços Web e bancos de dados.
- **PostgreSQL Client (`psql`) & SQLite3**: Utilitários de linha de comando para bancos de dados.
- **Postman**: Testes e desenvolvimento de APIs REST/GraphQL.
- **DBeaver CE**: Interface gráfica universal para gerenciamento de banco de dados.

## 🧠 Produtividade, IA & IDE

- **VS Code**: Com extensões pré-configuradas para Web e Jogos (`geequlim.godot-tools`, `ms-azuretools.vscode-docker`, `dbaeumer.vscode-eslint`, `esbenp.prettier-vscode`, `eamodio.gitlens`, `ms-python.python`).
- **Claude CLI**: CLI oficial do Claude (`@anthropic-ai/claude-code`).
- **Antigravity 2.0**: Ambiente `~/.antigravity`, CLI executável e aliases práticos (`ag`, `godot-dev`, `code-here`, `dcup`, `dcdown`).
- **Obsidian**: Gestão de conhecimento, Game Design Docs (GDD) e arquitetura de sistemas.
- **GitHub SSH & CLI (`gh`)**: Geração de chave `ed25519`, `~/.ssh/config` e autenticação rápida no GitHub.

---

## 💻 Como Usar

### 1. Dar permissão de execução
```bash
chmod +x setup.sh
```

### 2. Modo Interativo
Execute o script sem argumentos para abrir o menu interativo com opções para Web, Game Dev ou Completo:
```bash
./setup.sh
```

### 3. Instalação Completa (Web + Game Dev)
```bash
./setup.sh --all
```

### 4. Instalar Apenas Stack de Jogos
```bash
./setup.sh --gamedev
```

### 5. Instalar Apenas Stack Web
```bash
./setup.sh --web
```

### 6. Opções CLI Disponíveis
```bash
./setup.sh --help
```

- `--all`: Instala TODO o ambiente (Web + Game Dev)
- `--gamedev`: Instala apenas a stack de jogos (Godot 4, Tiled, Android Export SDK)
- `--web`: Instala apenas a stack Web (Docker, Node, Postgres, Postman, DBeaver)
- `--base`: Instala ferramentas base (Git, Node LTS, Python, Yarn, pnpm)
- `--docker`: Instala Docker CE e Docker Compose V2
- `--ssh`: Configura chave SSH e GitHub CLI
- `--vscode`: Instala VS Code e extensões Web/Game Dev
- `--ai`: Instala Claude CLI, Antigravity 2.0 e Obsidian
