#!/usr/bin/env bash
# ==============================================================================
# Docker Environment & Containers Setup Script
# Configures Docker images, containers stack, and service management aliases
# ==============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

print_banner() {
    echo -e "${MAGENTA}${BOLD}"
    echo "======================================================================"
    echo "          DOCKER DEV CONTAINERS & STACK SETUP ASSISTANT               "
    echo "   PostgreSQL 16 | Redis 7 | Mailpit | Portainer | MinIO S3           "
    echo "======================================================================"
    echo -e "${NC}"
}

setup_docker_stack() {
    print_banner

    if ! command -v docker &>/dev/null; then
        log_error "Docker não está instalado. Execute './setup.sh --docker' primeiro."
        exit 1
    fi

    local stack_dir="$HOME/.docker-dev-stack"
    mkdir -p "$stack_dir"

    log_info "Instalando stack Docker em: $stack_dir"

    # Copy docker-compose.yml to ~/.docker-dev-stack/docker-compose.yml
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -f "$script_dir/docker-compose.yml" ]; then
        cp "$script_dir/docker-compose.yml" "$stack_dir/docker-compose.yml"
    else
        log_error "Arquivo docker-compose.yml não encontrado."
        exit 1
    fi

    # Pre-pulling Docker Images
    log_info "Baixando imagens Docker de desenvolvimento..."
    local images=(
        "postgres:16-alpine"
        "redis:7-alpine"
        "axllent/mailpit:latest"
        "portainer/portainer-ce:latest"
        "quay.io/minio/minio:latest"
    )

    for img in "${images[@]}"; do
        log_info "Pulling image: $img..."
        docker pull "$img" || log_warn "Não foi possível baixar $img agora."
    done

    # Configuring Aliases in Shell Profiles
    log_info "Configurando atalhos de gerenciamento do Docker Stack no shell..."
    for profile in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$profile" ] && ! grep -q "dev-stack-up" "$profile"; then
            cat <<'EOF' >> "$profile"

# Docker Dev Stack Aliases
alias dev-stack-up='docker compose -f ~/.docker-dev-stack/docker-compose.yml up -d'
alias dev-stack-down='docker compose -f ~/.docker-dev-stack/docker-compose.yml down'
alias dev-stack-ps='docker compose -f ~/.docker-dev-stack/docker-compose.yml ps'
alias dev-stack-logs='docker compose -f ~/.docker-dev-stack/docker-compose.yml logs -f'
EOF
            log_info "Atalhos adicionados ao $profile"
        fi
    done

    echo ""
    local start_stack="${START_DOCKER_STACK:-}"
    if [ -z "$start_stack" ]; then
        if [ -t 0 ]; then
            echo -n -e "${CYAN}Deseja iniciar os containers da stack agora? [S/n] [Timeout 30s]: ${NC}"
            read -r -t 30 start_stack || start_stack="S"
            echo ""
        else
            start_stack="S"
        fi
    fi

    if [[ "$start_stack" =~ ^[SsYy]?$ ]]; then
        log_info "Iniciando os containers..."
        docker compose -f "$stack_dir/docker-compose.yml" up -d
        log_success "Containers iniciados!"
        echo -e "\n${CYAN}${BOLD}Serviços Disponíveis:${NC}"
        echo "- PostgreSQL 16:  localhost:5432 (user: postgres, pass: postgres, db: dev_db)"
        echo "- Redis 7:        localhost:6379"
        echo "- Mailpit (Web):  http://localhost:8025 (SMTP: 1025)"
        echo "- Portainer UI:   http://localhost:9000"
        echo "- MinIO Console:  http://localhost:9001 (user: minioadmin, pass: minioadmin)"
        echo ""
    fi

    log_success "Configuração da Stack Docker concluída com sucesso!"
}

setup_docker_stack "$@"
