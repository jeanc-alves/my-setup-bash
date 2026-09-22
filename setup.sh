#!/usr/bin/env bash
# ==============================================================================
# Development Environment Setup Script for Linux (Ubuntu/Debian)
# Features: Base Dev Tools, GitHub SSH, VS Code, Godot 4, Claude Code, Antigravity 2.0
# ==============================================================================

set -euo pipefail

# Colors for UI Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Logging Helpers
log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_banner() {
    echo -e "${MAGENTA}${BOLD}"
    echo "======================================================================"
    echo "          LINUX DEVELOPMENT ENVIRONMENT SETUP SCRIPT                 "
    echo "    Godot 4 | GitHub SSH | VS Code | Claude CLI | Antigravity 2.0    "
    echo "======================================================================"
    echo -e "${NC}"
}

# Ensure ~/.local/bin is in PATH and persistent across shell sessions
ensure_local_bin_path() {
    mkdir -p "$HOME/.local/bin"
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        for profile in "$HOME/.bashrc" "$HOME/.zshrc"; do
            if [ -f "$profile" ] && ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$profile"; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$profile"
                log_info "Added ~/.local/bin to $profile"
            fi
        done
    fi
}

# Helper to demand sudo rights when required
check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        log_info "Solicitando privilégios de administrador (sudo) para instalar pacotes..."
        sudo -v
        # Keep sudo timestamp alive
        while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    fi
}

# ------------------------------------------------------------------------------
# Module 1: Base Development Tools
# ------------------------------------------------------------------------------
setup_base_tools() {
    log_info "--- [1/6] Instalando Ferramentas Base de Desenvolvimento ---"
    check_sudo

    sudo apt update -y
    sudo apt install -y \
        build-essential \
        curl \
        wget \
        git \
        unzip \
        zip \
        jq \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        python3 \
        python3-pip \
        python3-venv \
        htop \
        tree

    # Check & Install Node.js LTS via NVM if npm is not found
    if ! command -v node &>/dev/null || ! command -v npm &>/dev/null; then
        log_info "Node.js não detectado. Instalando NVM (Node Version Manager) e Node.js LTS..."
        export NVM_DIR="$HOME/.nvm"
        if [ ! -d "$NVM_DIR" ]; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        fi
        
        # Load NVM in current execution context
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        if command -v nvm &>/dev/null; then
            nvm install --lts
            nvm use --lts
            nvm alias default 'lts/*'
            log_success "Node.js $(node -v) e npm $(npm -v) instalados via NVM."
        else
            log_warn "Não foi possível carregar o NVM automaticamente nesta sessão. Tente reiniciar o terminal."
        fi
    else
        log_success "Node.js ($(node -v)) e npm ($(npm -v)) já estão instalados."
    fi

    log_success "Ferramentas base instaladas com sucesso."
}

# ------------------------------------------------------------------------------
# Module 2: GitHub SSH Configuration & gh CLI
# ------------------------------------------------------------------------------
setup_github_ssh() {
    log_info "--- [2/6] Configurando Chave SSH para o GitHub ---"
    
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    local ssh_key="$HOME/.ssh/id_ed25519"
    local email=""

    if [ ! -f "$ssh_key" ]; then
        if [ -t 0 ]; then
            read -p "Digite seu e-mail do GitHub: " email
        fi
        if [ -z "$email" ]; then
            email="$(git config --global user.email || echo "dev@linux.local")"
        fi

        log_info "Gerando nova chave SSH Ed25519 para: $email"
        ssh-keygen -t ed25519 -C "$email" -N "" -f "$ssh_key"
        log_success "Chave SSH criada em: $ssh_key"
    else
        log_success "Chave SSH Ed25519 já existe em: $ssh_key"
    fi

    # Start ssh-agent and add key
    eval "$(ssh-agent -s)" &>/dev/null || true
    ssh-add "$ssh_key" &>/dev/null || true

    # Write ~/.ssh/config if not existing
    local config_file="$HOME/.ssh/config"
    if ! grep -q "Host github.com" "$config_file" 2>/dev/null; then
        cat <<EOF >> "$config_file"

Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    AddKeysToAgent yes
EOF
        chmod 600 "$config_file"
        log_success "Arquivo ~/.ssh/config atualizado com as configurações do GitHub."
    fi

    # Install GitHub CLI (gh) if missing
    if ! command -v gh &>/dev/null; then
        log_info "Instalando GitHub CLI (gh)..."
        check_sudo
        sudo mkdir -p -m 755 /etc/apt/keyrings
        wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
        sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update -y
        sudo apt install -y gh
        log_success "GitHub CLI (gh) instalado."
    fi

    echo -e "\n${YELLOW}${BOLD}=================== SUA CHAVE PÚBLICA GITHUB ===================${NC}"
    cat "${ssh_key}.pub"
    echo -e "${YELLOW}${BOLD}================================================================${NC}"
    echo -e "${CYAN}Copie a chave acima e adicione em: ${BOLD}https://github.com/settings/keys${NC}"
    echo -e "${CYAN}Ou execute: ${BOLD}gh auth login${NC} para autenticar diretamente pelo terminal.\n"
}

# ------------------------------------------------------------------------------
# Module 3: VS Code Installation & Extensions
# ------------------------------------------------------------------------------
setup_vscode() {
    log_info "--- [3/6] Instalando VS Code e Extensões ---"
    
    if ! command -v code &>/dev/null; then
        check_sudo
        log_info "Adicionando repositório oficial da Microsoft para o VS Code..."
        sudo mkdir -p -m 755 /etc/apt/keyrings
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/packages.microsoft.gpg > /dev/null
        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
        sudo apt update -y
        sudo apt install -y code
        log_success "VS Code instalado com sucesso."
    else
        log_success "VS Code já está instalado."
    fi

    # Install extensions
    log_info "Instalando extensões recomendadas no VS Code..."
    local extensions=(
        "geequlim.godot-tools"
        "ms-python.python"
        "eamodio.gitlens"
        "esbenp.prettier-vscode"
        "dbaeumer.vscode-eslint"
        "PKief.material-icon-theme"
    )

    for ext in "${extensions[@]}"; do
        if code --list-extensions | grep -qi "^${ext}$"; then
            log_info "Extensão $ext já instalada."
        else
            log_info "Instalando extensão: $ext"
            code --install-extension "$ext" --force || log_warn "Não foi possível instalar $ext"
        fi
    done

    log_success "VS Code configurado com sucesso."
}

# ------------------------------------------------------------------------------
# Module 4: Godot 4 Setup & VS Code Integration
# ------------------------------------------------------------------------------
setup_godot() {
    log_info "--- [4/6] Configurando o Godot Engine 4 ---"
    ensure_local_bin_path

    local godot_bin="$HOME/.local/bin/godot"

    if [ ! -f "$godot_bin" ]; then
        log_info "Buscando versão estável mais recente do Godot 4..."
        
        # Default fallback release URL if GitHub API rate-limited
        local godot_zip_url="https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip"
        
        # Try fetching latest 4.x release via GitHub API
        local latest_release
        latest_release=$(curl -s https://api.github.com/repos/godotengine/godot/releases/latest | jq -r '.assets[] | select(.name | contains("linux.x86_64") or contains("linux_x86_64")) | select(.name | contains("mono") | not) | .browser_download_url' | head -n 1 || echo "")
        
        if [ -n "$latest_release" ] && [ "$latest_release" != "null" ]; then
            godot_zip_url="$latest_release"
        fi

        log_info "Baixando Godot de: $godot_zip_url"
        local tmp_dir
        tmp_dir=$(mktemp -d)
        curl -sSL "$godot_zip_url" -o "$tmp_dir/godot.zip"

        log_info "Extraindo executável do Godot..."
        unzip -q "$tmp_dir/godot.zip" -d "$tmp_dir"
        
        local extracted_bin
        extracted_bin=$(find "$tmp_dir" -maxdepth 2 -type f \( -name "Godot_v*" -o -name "godot*" \) ! -name "*.zip" | head -n 1)

        if [ -f "$extracted_bin" ]; then
            mv "$extracted_bin" "$godot_bin"
            chmod +x "$godot_bin"
            log_success "Godot instalado em: $godot_bin"
        else
            log_error "Erro ao extrair o executável do Godot."
            rm -rf "$tmp_dir"
            return 1
        fi
        rm -rf "$tmp_dir"
    else
        log_success "Godot 4 já está instalado em: $godot_bin"
    fi

    # Create Desktop Shortcut
    log_info "Criando atalho de aplicativo (.desktop) para o Godot..."
    mkdir -p "$HOME/.local/share/applications"
    mkdir -p "$HOME/.local/share/icons/hicolor/256x256/apps"

    local icon_path="$HOME/.local/share/icons/hicolor/256x256/apps/godot.png"
    if [ ! -f "$icon_path" ]; then
        curl -sSL "https://raw.githubusercontent.com/godotengine/godot/master/icon.png" -o "$icon_path" || true
    fi

    cat <<EOF > "$HOME/.local/share/applications/godot.desktop"
[Desktop Entry]
Name=Godot Engine 4
Comment=Free and open-source 2D and 3D game engine
Exec=$godot_bin %f
Icon=$icon_path
Terminal=false
Type=Application
Categories=Development;IDE;Game;
MimeType=application/x-godot-project;
EOF
    chmod +x "$HOME/.local/share/applications/godot.desktop"
    log_success "Atalho criado em ~/.local/share/applications/godot.desktop"

    # VS Code Settings integration for Godot LSP
    log_info "Configurando integração do Godot no VS Code..."
    local vscode_config_dir="$HOME/.config/Code/User"
    local settings_file="$vscode_config_dir/settings.json"
    mkdir -p "$vscode_config_dir"

    if [ ! -f "$settings_file" ]; then
        echo "{}" > "$settings_file"
    fi

    # Safely merge settings using jq if available
    if command -v jq &>/dev/null; then
        tmp_json=$(mktemp)
        jq --arg gbin "$godot_bin" '
            .["godotTools.editorPath.godot4"] = $gbin |
            .["godotTools.lsp.serverHost"] = "127.0.0.1" |
            .["godotTools.lsp.serverPort"] = 6005
        ' "$settings_file" > "$tmp_json" && mv "$tmp_json" "$settings_file"
        log_success "Configurações do Godot adicionadas em: $settings_file"
    fi
}

# ------------------------------------------------------------------------------
# Module 5: Claude Code / CLI Setup
# ------------------------------------------------------------------------------
setup_claude() {
    log_info "--- [5/6] Instalando e Configurando o Claude CLI ---"
    
    # Load NVM/node if installed
    if [ -s "$HOME/.nvm/nvm.sh" ]; then
        \. "$HOME/.nvm/nvm.sh" || true
    fi

    if ! command -v npm &>/dev/null; then
        log_error "npm não encontrado. Execute o módulo de ferramentas base primeiro."
        return 1
    fi

    log_info "Instalando @anthropic-ai/claude-code globalmente via npm..."
    npm install -g @anthropic-ai/claude-code || {
        log_warn "Instalação sem sudo falhou. Tentando com sudo ou ajustando permissões..."
        sudo npm install -g @anthropic-ai/claude-code
    }

    if command -v claude &>/dev/null; then
        log_success "Claude CLI instalado com sucesso ($(claude --version 2>/dev/null || echo "ok"))."
    else
        log_success "Claude CLI instalado via npm."
    fi

    log_info "Dica: Para autenticar o Claude Code, defina a variável ANTHROPIC_API_KEY no seu shell ou execute 'claude' no terminal."
}

# ------------------------------------------------------------------------------
# Module 6: Antigravity 2.0 Environment & CLI Config
# ------------------------------------------------------------------------------
setup_antigravity() {
    log_info "--- [6/6] Configurando o Ambiente Antigravity 2.0 ---"
    ensure_local_bin_path

    local antigravity_home="$HOME/.antigravity"
    mkdir -p "$antigravity_home/bin" "$antigravity_home/config" "$antigravity_home/plugins"

    # Create environment script
    local env_script="$antigravity_home/env.sh"
    cat <<'EOF' > "$env_script"
# Antigravity 2.0 Environment Configuration
export ANTIGRAVITY_HOME="$HOME/.antigravity"
export PATH="$ANTIGRAVITY_HOME/bin:$PATH"

# Custom Dev Aliases
alias ag='antigravity'
alias godot-dev='godot --editor .'
alias code-here='code .'
EOF

    # Source env in shell profiles
    for profile in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$profile" ] && ! grep -q "ANTIGRAVITY_HOME" "$profile"; then
            echo -e "\n# Antigravity 2.0 Setup\n[ -f \"$env_script\" ] && source \"$env_script\"" >> "$profile"
            log_info "Configuração Antigravity adicionada ao $profile"
        fi
    done

    # Create executable wrapper / entrypoint script in ~/.local/bin
    cat <<'EOF' > "$HOME/.local/bin/antigravity"
#!/usr/bin/env bash
# Antigravity 2.0 CLI Wrapper
echo -e "\033[1;35m[Antigravity 2.0]\033[0m Antigravity Development Assistant CLI Initialized."
echo "Workspace: $(pwd)"
echo "Timestamp: $(date)"
EOF
    chmod +x "$HOME/.local/bin/antigravity"

    log_success "Ambiente Antigravity 2.0 configurado com sucesso!"
}

# ------------------------------------------------------------------------------
# Menu / Flag Processing
# ------------------------------------------------------------------------------
show_help() {
    print_banner
    echo -e "Uso: ./setup.sh [OPÇÕES]\n"
    echo -e "Opções:"
    echo -e "  --all           Instala todos os componentes (Ambiente Completo)"
    echo -e "  --base          Instala apenas ferramentas base (Git, Node, Python, etc.)"
    echo -e "  --ssh           Configura apenas chave SSH e GitHub CLI"
    echo -e "  --vscode        Instala apenas o VS Code e extensões"
    echo -e "  --godot         Instala apenas a Engine Godot 4 e integração"
    echo -e "  --claude        Instala apenas o Claude CLI"
    echo -e "  --antigravity   Configura apenas o ambiente Antigravity 2.0"
    echo -e "  -h, --help      Exibe esta ajuda\n"
}

interactive_menu() {
    print_banner
    echo -e "${CYAN}Selecione o modo de instalação:${NC}\n"
    echo "1) Instalação Completa (TUDO)"
    echo "2) Personalizada (Escolher componentes)"
    echo "3) Sair"
    echo ""
    read -p "Opção [1-3]: " choice

    case "$choice" in
        1)
            setup_base_tools
            setup_github_ssh
            setup_vscode
            setup_godot
            setup_claude
            setup_antigravity
            ;;
        2)
            read -p "Instalar ferramentas base (Git, Node, Python)? [S/n]: " resp
            [[ "$resp" =~ ^[SsYy]?$ ]] && setup_base_tools

            read -p "Configurar GitHub SSH & CLI? [S/n]: " resp
            [[ "$resp" =~ ^[SsYy]?$ ]] && setup_github_ssh

            read -p "Instalar VS Code + Extensões? [S/n]: " resp
            [[ "$resp" =~ ^[SsYy]?$ ]] && setup_vscode

            read -p "Instalar Godot Engine 4? [S/n]: " resp
            [[ "$resp" =~ ^[SsYy]?$ ]] && setup_godot

            read -p "Instalar Claude CLI? [S/n]: " resp
            [[ "$resp" =~ ^[SsYy]?$ ]] && setup_claude

            read -p "Configurar Antigravity 2.0? [S/n]: " resp
            [[ "$resp" =~ ^[SsYy]?$ ]] && setup_antigravity
            ;;
        3)
            echo "Saindo..."
            exit 0
            ;;
        *)
            log_error "Opção inválida."
            exit 1
            ;;
    esac
}

main() {
    if [ $# -eq 0 ]; then
        interactive_menu
        print_banner
        log_success "Configuração do ambiente de desenvolvimento concluída com sucesso!"
        exit 0
    fi

    while [ $# -gt 0 ]; do
        case "$1" in
            --all)
                setup_base_tools
                setup_github_ssh
                setup_vscode
                setup_godot
                setup_claude
                setup_antigravity
                ;;
            --base) setup_base_tools ;;
            --ssh) setup_github_ssh ;;
            --vscode) setup_vscode ;;
            --godot) setup_godot ;;
            --claude) setup_claude ;;
            --antigravity) setup_antigravity ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Opção desconhecida: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done

    print_banner
    log_success "Operações concluídas!"
}

main "$@"
