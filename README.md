# Linux Development Environment Setup Script

Script automatizado e modular em Bash para instalação e preparação de ambiente de desenvolvimento completo em sistemas Linux (Ubuntu / Debian / derivados).

## 🚀 Componentes Instalados e Configurados

1. **Ferramentas Base de Desenvolvimento (`--base`)**:
   - `build-essential`, `curl`, `wget`, `git`, `unzip`, `zip`, `jq`, `gnupg`, `ca-certificates`.
   - Ambiente **Python 3** (`python3-pip`, `python3-venv`).
   - Ambiente **Node.js LTS** via NVM (Node Version Manager).

2. **Configuração de SSH e GitHub CLI (`--ssh`)**:
   - Geração automatizada de chave SSH `ed25519` em `~/.ssh/id_ed25519`.
   - Inicialização do `ssh-agent` e adição da chave.
   - Configuração do arquivo `~/.ssh/config` com permissões seguras (`600`).
   - Instalação e configuração do **GitHub CLI (`gh`)**.

3. **VS Code & Extensões (`--vscode`)**:
   - Adição do repositório oficial da Microsoft e instalação do `code`.
   - Instalação das extensões: `geequlim.godot-tools`, `ms-python.python`, `eamodio.gitlens`, `esbenp.prettier-vscode`, `dbaeumer.vscode-eslint`, `PKief.material-icon-theme`.

4. **Godot Engine 4 (`--godot`)**:
   - Download automatizado da versão estável mais recente do **Godot 4** (Linux 64-bit).
   - Instalação do binário em `~/.local/bin/godot`.
   - Criação de atalho de aplicativo para o menu do sistema (`~/.local/share/applications/godot.desktop`).
   - Integração com VS Code (`settings.json`) configurando o caminho do executável e porta LSP GDScript (`6005`).

5. **Claude CLI / Code (`--claude`)**:
   - Instalação global da CLI oficial `@anthropic-ai/claude-code` via npm.

6. **Ambiente Antigravity 2.0 (`--antigravity`)**:
   - Estruturação do diretório `~/.antigravity` (bin, config, plugins).
   - Criação e inclusão do script de ambiente `env.sh` no `~/.bashrc` / `~/.zshrc`.
   - Wrapper CLI executável `antigravity` e aliases como `ag`, `godot-dev` e `code-here`.

---

## 💻 Como Usar

### 1. Dar permissão de execução (se necessário)
```bash
chmod +x setup.sh
```

### 2. Modo Interativo (Menu com opções)
Execute o script sem argumentos para abrir o menu interativo:
```bash
./setup.sh
```

### 3. Instalação Completa (Silenciosa / Automatizada)
Para instalar todos os componentes de uma vez:
```bash
./setup.sh --all
```

### 4. Instalação de Módulos Específicos
Você pode combinar flags para instalar apenas o que precisa:
```bash
# Instalar apenas Godot 4 e VS Code
./setup.sh --godot --vscode

# Configurar apenas SSH do GitHub e Claude CLI
./setup.sh --ssh --claude
```

### 5. Ajuda e Parâmetros
```bash
./setup.sh --help
```

---

## 📋 Passos Pós-Instalação Recomendados

1. **Atualizar Sessão do Terminal**:
   ```bash
   source ~/.bashrc   # Ou source ~/.zshrc
   ```

2. **Vincular Chave SSH ao GitHub**:
   Execute o comando abaixo para visualizar sua chave pública e adicione-a em [https://github.com/settings/keys](https://github.com/settings/keys):
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
   Ou autentique-se via GitHub CLI:
   ```bash
   gh auth login
   ```

3. **Autenticar o Claude CLI**:
   Defina sua chave de API Anthropic:
   ```bash
   export ANTHROPIC_API_KEY="seu_token_aqui"
   ```
   E execute o comando:
   ```bash
   claude
   ```
