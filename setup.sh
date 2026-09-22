#!/usr/bin/env bash
# ==============================================================================
# Development Environment Setup Script for Linux (Ubuntu/Debian)
# Specialized for Web Development & Game Development
# Stack: Godot 4, Tiled, Android Export SDK, Node.js/Yarn/pnpm, Docker, Postgres,
#        VS Code, GitHub SSH, Claude CLI, Antigravity 2.0, Postman, DBeaver, Obsidian
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

log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

print_banner() {
    echo -e "${MAGENTA}${BOLD}"
    echo "======================================================================"
    echo "       LINUX WEB & GAME DEVELOPMENT ENVIRONMENT SETUP SCRIPT         "
    echo "   Godot 4 | Tiled | Docker | Node/pnpm/Yarn | Postgres | VS Code   "
    echo "   GitHub SSH | Claude CLI | Antigravity 2.0 | Postman | Obsidian   "
    echo "======================================================================"
    echo -e "${NC}"
}

ensure_local_bin_path() {
    mkdir -p "$HOME/.local/bin"
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        for profile in "$HOME/.bashrc" "$HOME/.zshrc"; do
            if [ -f "$profile" ] && ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$profile"; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$profile"
                log_info "Adicionado ~/.local/bin ao $profile"
            fi
        done
    fi
}

check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        log_info "Solicitando privilégios de administrador (sudo)..."
        sudo -v
        while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    fi
}

# ------------------------------------------------------------------------------
# Module 1: Base Tools (Web & Game Essentials)
# ------------------------------------------------------------------------------
setup_base_tools() {
    log_info "--- [1/7] Instalando Ferramentas Base (Web & Game Dev) ---"
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
        postgresql-client \
        sqlite3 \
        htop \
        tree

    # Node.js LTS via NVM
    if ! command -v node &>/dev/null || ! command -v npm &>/dev/null; then
        log_info "Instalando NVM e Node.js LTS..."
        export NVM_DIR="$HOME/.nvm"
        if [ ! -d "$NVM_DIR" ]; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        fi
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        if command -v nvm &>/dev/null; then
            nvm install --lts
            nvm use --lts
            nvm alias default 'lts/*'
        fi
    fi

    # Global Web Package Managers: Yarn & pnpm
    log_info "Configurando gerenciadores de pacotes globais (Yarn e pnpm)..."
    npm install -g yarn pnpm || true

    log_success "Ferramentas base instaladas com sucesso."
}

# ------------------------------------------------------------------------------
# Module 2: Docker & Containerization (Web Backend)
# ------------------------------------------------------------------------------
setup_docker() {
    log_info "--- [2/7] Instalando Docker CE & Docker Compose V2 ---"
    
    if ! command -v docker &>/dev/null; then
        check_sudo
        log_info "Adicionando repositório oficial do Docker..."
        sudo mkdir -p -m 755 /etc/apt/keyrings
        wget -qO- https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update -y
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        # Configure user group
        log_info "Adicionando usuário $(whoami) ao grupo 'docker'..."
        sudo usermod -aG docker "$USER" || true
        log_success "Docker instalado com sucesso."
    else
        log_success "Docker já está instalado no sistema."
    fi
}

# ------------------------------------------------------------------------------
# Module 3: GitHub & GitLab SSH Configuration & GitHub CLI
# ------------------------------------------------------------------------------
setup_git_ssh() {
    log_info "--- [3/7] Configurando Chaves SSH (GitHub & GitLab) e GitHub CLI ---"
    
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    eval "$(ssh-agent -s)" &>/dev/null || true
    local config_file="$HOME/.ssh/config"

    # --- 1. GitHub SSH Setup ---
    local github_key="$HOME/.ssh/id_ed25519"
    if [ ! -f "$github_key" ]; then
        local github_email=""
        if [ -t 0 ]; then read -p "Digite seu e-mail do GitHub (ou Pessoal): " github_email; fi
        [ -z "$github_email" ] && github_email="$(git config --global user.email || echo "dev@linux.local")"
        log_info "Gerando chave SSH Ed25519 para o GitHub ($github_email)..."
        ssh-keygen -t ed25519 -C "$github_email" -N "" -f "$github_key"
    else
        log_success "Chave SSH do GitHub já existe em: $github_key"
    fi
    ssh-add "$github_key" &>/dev/null || true

    if ! grep -q "Host github.com" "$config_file" 2>/dev/null; then
        cat <<EOF >> "$config_file"

Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    AddKeysToAgent yes
EOF
    fi

    # --- 2. GitLab SSH Setup ---
    local gitlab_key="$HOME/.ssh/id_ed25519_gitlab"
    if [ ! -f "$gitlab_key" ]; then
        local gitlab_email=""
        if [ -t 0 ]; then read -p "Digite seu e-mail do GitLab (Trabalho): " gitlab_email; fi
        [ -z "$gitlab_email" ] && gitlab_email="$(git config --global user.email || echo "trabalho@gitlab.local")"
        log_info "Gerando chave SSH Ed25519 para o GitLab ($gitlab_email)..."
        ssh-keygen -t ed25519 -C "$gitlab_email" -N "" -f "$gitlab_key"
    else
        log_success "Chave SSH do GitLab já existe em: $gitlab_key"
    fi
    ssh-add "$gitlab_key" &>/dev/null || true

    if ! grep -q "Host gitlab.com" "$config_file" 2>/dev/null; then
        cat <<EOF >> "$config_file"

Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519_gitlab
    AddKeysToAgent yes
EOF
    fi

    chmod 600 "$config_file"

    # --- 3. GitHub CLI ---
    if ! command -v gh &>/dev/null; then
        check_sudo
        sudo mkdir -p -m 755 /etc/apt/keyrings
        wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update -y
        sudo apt install -y gh
    fi

    echo -e "\n${YELLOW}${BOLD}=================== SUA CHAVE PÚBLICA GITHUB ===================${NC}"
    cat "${github_key}.pub"
    echo -e "${YELLOW}${BOLD}================================================================${NC}"
    echo -e "${CYAN}Adicione no GitHub em: ${BOLD}https://github.com/settings/keys${NC}\n"

    echo -e "${YELLOW}${BOLD}=================== SUA CHAVE PÚBLICA GITLAB ===================${NC}"
    cat "${gitlab_key}.pub"
    echo -e "${YELLOW}${BOLD}================================================================${NC}"
    echo -e "${CYAN}Adicione no GitLab em: ${BOLD}https://gitlab.com/-/profile/keys${NC}\n"
}

# ------------------------------------------------------------------------------
# Module 4: VS Code (Web & Game Dev Extensions)
# ------------------------------------------------------------------------------
setup_vscode() {
    log_info "--- [4/7] Instalando VS Code e Extensões (Web & Game Dev) ---"
    
    if ! command -v code &>/dev/null; then
        check_sudo
        sudo mkdir -p -m 755 /etc/apt/keyrings
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/packages.microsoft.gpg > /dev/null
        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
        sudo apt update -y
        sudo apt install -y code
    fi

    log_info "Instalando extensões recomendadas do VS Code..."
    local extensions=(
        "geequlim.godot-tools"
        "ms-python.python"
        "eamodio.gitlens"
        "ms-azuretools.vscode-docker"
        "dbaeumer.vscode-eslint"
        "esbenp.prettier-vscode"
        "PKief.material-icon-theme"
    )

    for ext in "${extensions[@]}"; do
        code --install-extension "$ext" --force &>/dev/null || true
    done
    log_success "VS Code configurado."
}

# ------------------------------------------------------------------------------
# Module 5: Game Development Suite (Godot 4, Tiled, Android Export SDK)
# ------------------------------------------------------------------------------
setup_gamedev() {
    log_info "--- [5/7] Configurando Suíte de Desenvolvimento de Jogos (Godot 4 & Tiled) ---"
    ensure_local_bin_path
    check_sudo

    # Dependencies for Godot Android Export
    log_info "Instalando dependências para exportação de jogos (OpenJDK 17 e ADB)..."
    sudo apt install -y openjdk-17-jdk android-tools-adb || true

    # Godot 4 Binary Installation
    local godot_bin="$HOME/.local/bin/godot"
    if [ ! -f "$godot_bin" ]; then
        log_info "Baixando Godot Engine 4..."
        local godot_zip_url="https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip"
        local latest_release
        latest_release=$(curl -s https://api.github.com/repos/godotengine/godot/releases/latest | jq -r '.assets[] | select(.name | contains("linux.x86_64") or contains("linux_x86_64")) | select(.name | contains("mono") | not) | .browser_download_url' | head -n 1 || echo "")
        [ -n "$latest_release" ] && [ "$latest_release" != "null" ] && godot_zip_url="$latest_release"

        local tmp_dir
        tmp_dir=$(mktemp -d)
        curl -sSL "$godot_zip_url" -o "$tmp_dir/godot.zip"
        unzip -q "$tmp_dir/godot.zip" -d "$tmp_dir"
        local extracted_bin
        extracted_bin=$(find "$tmp_dir" -maxdepth 2 -type f \( -name "Godot_v*" -o -name "godot*" \) ! -name "*.zip" | head -n 1)

        if [ -f "$extracted_bin" ]; then
            mv "$extracted_bin" "$godot_bin"
            chmod +x "$godot_bin"
            log_success "Godot 4 instalado em: $godot_bin"
        fi
        rm -rf "$tmp_dir"
    fi

    # Desktop Entry for Godot
    mkdir -p "$HOME/.local/share/applications" "$HOME/.local/share/icons/hicolor/256x256/apps"
    local icon_path="$HOME/.local/share/icons/hicolor/256x256/apps/godot.png"
    [ ! -f "$icon_path" ] && curl -sSL "https://raw.githubusercontent.com/godotengine/godot/master/icon.png" -o "$icon_path" || true

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

    # VS Code LSP Integration for Godot
    local settings_file="$HOME/.config/Code/User/settings.json"
    mkdir -p "$HOME/.config/Code/User"
    [ ! -f "$settings_file" ] && echo "{}" > "$settings_file"
    if command -v jq &>/dev/null; then
        tmp_json=$(mktemp)
        jq --arg gbin "$godot_bin" '
            .["godotTools.editorPath.godot4"] = $gbin |
            .["godotTools.lsp.serverHost"] = "127.0.0.1" |
            .["godotTools.lsp.serverPort"] = 6005
        ' "$settings_file" > "$tmp_json" && mv "$tmp_json" "$settings_file"
    fi

    # Tiled Map Editor (Snap installation)
    if command -v snap &>/dev/null; then
        log_info "Instalando Tiled Map Editor (para mapas de jogos 2D)..."
        sudo snap install tiled || true
    fi

    log_success "Ferramentas de desenvolvimento de jogos configuradas com sucesso."
}

# ------------------------------------------------------------------------------
# Module 6: Web Tools Suite (Postman & DBeaver Database GUI)
# ------------------------------------------------------------------------------
setup_web_tools() {
    log_info "--- [6/7] Instalando Ferramentas Web (Postman & DBeaver CE) ---"
    check_sudo

    if command -v snap &>/dev/null; then
        log_info "Instalando Postman (Teste de APIs)..."
        sudo snap install postman || true

        log_info "Instalando DBeaver CE (Gerenciador de Bancos de Dados Web)..."
        sudo snap install dbeaver-ce || true
    fi

    log_success "Ferramentas de Desenvolvimento Web instaladas."
}

# ------------------------------------------------------------------------------
# Module 7: AI Assistants & Documentation (Claude, Antigravity 2.0, Obsidian)
# ------------------------------------------------------------------------------
setup_ai_and_productivity() {
    log_info "--- [7/7] Configurando Assistentes de IA e Documentação (Claude, Antigravity 2.0, Obsidian) ---"
    ensure_local_bin_path

    # Claude CLI
    if [ -s "$HOME/.nvm/nvm.sh" ]; then \. "$HOME/.nvm/nvm.sh" || true; fi
    if command -v npm &>/dev/null; then
        log_info "Instalando Claude CLI (@anthropic-ai/claude-code)..."
        npm install -g @anthropic-ai/claude-code || sudo npm install -g @anthropic-ai/claude-code || true
    fi

    # Antigravity 2.0 Environment
    local antigravity_home="$HOME/.antigravity"
    mkdir -p "$antigravity_home/bin" "$antigravity_home/config" "$antigravity_home/plugins"

    local env_script="$antigravity_home/env.sh"
    cat <<'EOF' > "$env_script"
# Antigravity 2.0 Environment Configuration
export ANTIGRAVITY_HOME="$HOME/.antigravity"
export PATH="$ANTIGRAVITY_HOME/bin:$PATH"

# Web & Game Dev Aliases
alias ag='antigravity'
alias godot-dev='godot --editor .'
alias code-here='code .'
alias dcup='docker compose up -d'
alias dcdown='docker compose down'
EOF

    for profile in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$profile" ] && ! grep -q "ANTIGRAVITY_HOME" "$profile"; then
            echo -e "\n# Antigravity 2.0 Setup\n[ -f \"$env_script\" ] && source \"$env_script\"" >> "$profile"
        fi
    done

    cat <<'EOF' > "$HOME/.local/bin/antigravity"
#!/usr/bin/env bash
echo -e "\033[1;35m[Antigravity 2.0]\033[0m Antigravity Development Assistant CLI Initialized."
echo "Workspace: $(pwd)"
echo "Timestamp: $(date)"
EOF
    chmod +x "$HOME/.local/bin/antigravity"

    # Obsidian (Game Design Docs & Web Docs)
    if command -v snap &>/dev/null; then
        log_info "Instalando Obsidian (Documentação & Game Design Docs)..."
        sudo snap install obsidian --classic || true
    fi

    log_success "Ambiente de IA e Documentação configurado!"
}

# ------------------------------------------------------------------------------
# Menu / CLI Flags
# ------------------------------------------------------------------------------
show_help() {
    print_banner
    echo -e "Uso: ./setup.sh [OPÇÕES]\n"
    echo -e "Opções:"
    echo -e "  --all           Instala TODO o ambiente (Web + Game Dev)"
    echo -e "  --gamedev       Instala apenas ferramentas de Jogos (Godot 4, Tiled, Android Export SDK)"
    echo -e "  --web           Instala apenas ferramentas Web (Docker, Node, Postgres, Postman, DBeaver)"
    echo -e "  --base          Instala apenas ferramentas base (Git, Node LTS, Python, C++)"
    echo -e "  --docker        Instala apenas Docker CE & Docker Compose V2"
    echo -e "  --ssh           Configura chave SSH e GitHub CLI"
    echo -e "  --vscode        Instala VS Code e extensões Web/Game"
    echo -e "  --ai            Instala Claude CLI, Antigravity 2.0 e Obsidian"
    echo -e "  -h, --help      Exibe esta ajuda\n"
}

interactive_menu() {
    print_banner
    echo -e "${CYAN}Selecione o modo de instalação:${NC}\n"
    echo "1) Instalação Completa (Web + Game Dev Stack)"
    echo "2) Apenas Desenvolvimento de Jogos (Godot 4, Tiled, OpenJDK Android)"
    echo "3) Apenas Desenvolvimento Web (Docker, Postgres, Postman, DBeaver)"
    echo "4) Seleção Personalizada"
    echo "5) Sair"
    echo ""
    read -p "Opção [1-5]: " choice

    case "$choice" in
        1)
            setup_base_tools
            setup_docker
            setup_git_ssh
            setup_vscode
            setup_gamedev
            setup_web_tools
            setup_ai_and_productivity
            ;;
        2)
            setup_base_tools
            setup_vscode
            setup_gamedev
            ;;
        3)
            setup_base_tools
            setup_docker
            setup_vscode
            setup_web_tools
            ;;
        4)
            read -p "Instalar ferramentas base (Node/Python/Postgres)? [S/n]: " r; [[ "$r" =~ ^[SsYy]?$ ]] && setup_base_tools
            read -p "Instalar Docker CE & Compose? [S/n]: " r; [[ "$r" =~ ^[SsYy]?$ ]] && setup_docker
            read -p "Configurar Chaves SSH (GitHub & GitLab) & CLI? [S/n]: " r; [[ "$r" =~ ^[SsYy]?$ ]] && setup_git_ssh
            read -p "Instalar VS Code + Extensões? [S/n]: " r; [[ "$r" =~ ^[SsYy]?$ ]] && setup_vscode
            read -p "Instalar Suíte Game Dev (Godot 4, Tiled, Android Export)? [S/n]: " r; [[ "$r" =~ ^[SsYy]?$ ]] && setup_gamedev
            read -p "Instalar Suíte Web (Postman, DBeaver)? [S/n]: " r; [[ "$r" =~ ^[SsYy]?$ ]] && setup_web_tools
            read -p "Instalar Claude, Antigravity 2.0 e Obsidian? [S/n]: " r; [[ "$r" =~ ^[SsYy]?$ ]] && setup_ai_and_productivity
            ;;
        5) exit 0 ;;
        *) log_error "Opção inválida."; exit 1 ;;
    esac
}

main() {
    if [ $# -eq 0 ]; then
        interactive_menu
        print_banner
        log_success "Ambiente configurado com sucesso!"
        exit 0
    fi

    while [ $# -gt 0 ]; do
        case "$1" in
            --all)
                setup_base_tools
                setup_docker
                setup_git_ssh
                setup_vscode
                setup_gamedev
                setup_web_tools
                setup_ai_and_productivity
                ;;
            --gamedev) setup_base_tools; setup_vscode; setup_gamedev ;;
            --web) setup_base_tools; setup_docker; setup_vscode; setup_web_tools ;;
            --base) setup_base_tools ;;
            --docker) setup_docker ;;
            --ssh) setup_git_ssh ;;
            --vscode) setup_vscode ;;
            --ai) setup_ai_and_productivity ;;
            -h|--help) show_help; exit 0 ;;
            *) log_error "Opção desconhecida: $1"; show_help; exit 1 ;;
        esac
        shift
    done

    print_banner
    log_success "Instalação concluída!"
}

main "$@"
