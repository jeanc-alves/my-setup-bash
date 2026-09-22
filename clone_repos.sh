#!/usr/bin/env bash
# ==============================================================================
# Repositories Cloning Script for Development Environment
# Clones active personal, work (Rimatur/Inovando), AI, and Game Dev repositories
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
    echo "          REPOSITORIES AUTO-CLONING ASSISTANT                         "
    echo "  Cloning Work, AI, Game Dev & Personal Projects into Local Structure "
    echo "======================================================================"
    echo -e "${NC}"
}

# Helper to clone or pull a repository idempotently
clone_or_pull() {
    local url="$1"
    local target_dir="$2"
    local category="$3"

    echo -e "${BOLD}--> [$category]${NC} $target_dir"

    if [ -d "$target_dir/.git" ]; then
        log_warn "Repositório já clonado em $target_dir. Atualizando com 'git pull'..."
        (cd "$target_dir" && git pull --ff-only) || log_error "Erro ao atualizar $target_dir"
    elif [ -d "$target_dir" ] && [ "$(ls -A "$target_dir")" ]; then
        log_warn "Diretório $target_dir já existe e não está vazio. Pulando clone."
    else
        mkdir -p "$(dirname "$target_dir")"
        log_info "Clonando $url -> $target_dir"
        git clone "$url" "$target_dir" && log_success "Clonado com sucesso!" || log_error "Falha ao clonar $url"
    fi
    echo ""
}

# ------------------------------------------------------------------------------
# Mapped Repositories Catalog
# ------------------------------------------------------------------------------

clone_work_projects() {
    log_info "--- Clonando Projetos de Trabalho (Rimatur & Inovando) ---"
    
    # Rimatur Projects (GitLab Inovando)
    clone_or_pull "git@git.inovan.do:rimatur/api-portal-rimatur.git" "$HOME/Projects/Rimatur/api-portal-rimatur" "Rimatur Work"
    clone_or_pull "git@git.inovan.do:rimatur/next-portal-rimatur.git" "$HOME/Projects/Rimatur/next-portal-rimatur" "Rimatur Work"

    # Inovando & LowCode Projects
    clone_or_pull "git@git.inovan.do:inovando/lowcode/front-low-code.git" "$HOME/Inovando/LowCode/front-low-code" "Inovando LowCode"
    clone_or_pull "git@git.inovan.do:inovando/lowcode/adonis-low-code.git" "$HOME/Inovando/LowCode/adonis-low-code" "Inovando LowCode"
    clone_or_pull "git@git.inovan.do:inovando/langfuse-client-sh.git" "$HOME/Projects/langfuse-client-sh" "Inovando"
    clone_or_pull "git@github.com:inovando/adonis-crud.git" "$HOME/Inovando/adonis-crud-packege/adonis-crud" "Inovando"
    clone_or_pull "git@github.com:inovando/obsidian-rag-tools.git" "$HOME/Projects/local_rag_obisidian_project" "Inovando RAG"
}

clone_personal_ai_projects() {
    log_info "--- Clonando Projetos Pessoais & IA ---"

    clone_or_pull "git@github.com:jeanc-alves/finanace-hub-app.git" "$HOME/Projects/IA/finance-hub-app" "Personal Finance"
    clone_or_pull "git@github.com:jeanc-alves/finance-hub-backend.git" "$HOME/Projects/IA/finance-hub-backend" "Personal Finance"
    clone_or_pull "git@github.com:jeanc-alves/NestApi.git" "$HOME/Projects/NestApi/nest-api" "Personal API"
    clone_or_pull "git@github.com:jeanc-alves/rentx.git" "$HOME/Inovando/rentx" "Personal RentX"
    clone_or_pull "git@github.com:Jean1dev/mba-ia.git" "$HOME/MeuVaultRAG/mba-ia" "MBA IA Vault"
    clone_or_pull "git@github.com:jeanc-alves/my-setup-bash.git" "$HOME/Projects/my-setup-bash" "Setup Bash"
}

clone_game_projects() {
    log_info "--- Clonando Projetos de Jogos (Game Dev) ---"

    clone_or_pull "git@github.com:otland/forgottenserver.git" "$HOME/Projects/games/forgottenserver" "Game Server"
    clone_or_pull "git@github.com:otland/otclient.git" "$HOME/Projects/games/otclient" "Game Client"
}

# ------------------------------------------------------------------------------
# Interactive Menu / CLI Flags
# ------------------------------------------------------------------------------
show_help() {
    print_banner
    echo -e "Uso: ./clone_repos.sh [OPÇÕES]\n"
    echo -e "Opções:"
    echo -e "  --all         Clona TODOS os repositórios mapeados (Trabalho + IA + Jogos + Pessoais)"
    echo -e "  --work        Clona apenas repositórios de Trabalho (Rimatur & Inovando)"
    echo -e "  --personal    Clona apenas repositórios Pessoais & IA"
    echo -e "  --games       Clona apenas repositórios de Jogos"
    echo -e "  -h, --help    Exibe esta ajuda\n"
}

interactive_menu() {
    print_banner
    echo -e "${CYAN}Selecione quais repositórios deseja clonar:${NC}\n"
    echo "1) Clonar TODOS os Repositórios (Trabalho, Pessoais, IA, Jogos)"
    echo "2) Apenas Repositórios de Trabalho (Rimatur & Inovando)"
    echo "3) Apenas Repositórios Pessoais & IA"
    echo "4) Apenas Repositórios de Jogos"
    echo "5) Sair"
    echo ""
    read -p "Opção [1-5]: " choice

    case "$choice" in
        1)
            clone_work_projects
            clone_personal_ai_projects
            clone_game_projects
            ;;
        2) clone_work_projects ;;
        3) clone_personal_ai_projects ;;
        4) clone_game_projects ;;
        5) exit 0 ;;
        *) log_error "Opção inválida."; exit 1 ;;
    esac
}

main() {
    if [ $# -eq 0 ]; then
        interactive_menu
        print_banner
        log_success "Clonagem de repositórios concluída com sucesso!"
        exit 0
    fi

    while [ $# -gt 0 ]; do
        case "$1" in
            --all)
                clone_work_projects
                clone_personal_ai_projects
                clone_game_projects
                ;;
            --work) clone_work_projects ;;
            --personal) clone_personal_ai_projects ;;
            --games) clone_game_projects ;;
            -h|--help) show_help; exit 0 ;;
            *) log_error "Opção desconhecida: $1"; show_help; exit 1 ;;
        esac
        shift
    done

    print_banner
    log_success "Operações concluídas!"
}

main "$@"
