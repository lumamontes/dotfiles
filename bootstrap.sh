#!/usr/bin/env bash
# Reconstroi o ambiente de desenvolvimento macOS.
# Idempotente: rodar N vezes produz o mesmo resultado.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/phases.sh
. "$REPO_ROOT/lib/phases.sh"

PRIVATE_PATH=""
DRY_RUN=0

usage() {
  cat <<'USAGE'
Uso: ./bootstrap.sh [opcoes]

  --private <caminho>  Aplica o overlay do repo privado local.
                       O repo privado nao tem remoto: copie a pasta
                       para esta maquina antes (Drive, Syncthing, AirDrop).
  --dry-run            Mostra o que faria, sem escrever nada.
  --help               Esta mensagem.
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --private)
      [ $# -ge 2 ] || die "--private exige um caminho"
      PRIVATE_PATH="$2"
      shift 2
      ;;
    --dry-run) DRY_RUN=1; shift ;;
    --help)    usage; exit 0 ;;
    *)         printf 'erro: opcao desconhecida: %s\n\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done

if [ -n "$PRIVATE_PATH" ]; then
  [ -d "$PRIVATE_PATH" ] || die "repo privado nao encontrado: $PRIVATE_PATH"
  [ -f "$PRIVATE_PATH/overlay.sh" ] || die "overlay.sh ausente em: $PRIVATE_PATH"
fi

if [ "$DRY_RUN" -eq 1 ]; then
  echo "== dry-run: nada sera escrito =="
  needs_clt      && echo "fase 1: instalaria Xcode CLT"      || echo "fase 1: ok"
  needs_homebrew && echo "fase 2: instalaria Homebrew"       || echo "fase 2: ok"
  echo "fase 3: rodaria brew bundle"
  echo "fase 4: linkaria home/ e config/ em $DOTFILES_TARGET"
  needs_nvm      && echo "fase 5: instalaria nvm"            || echo "fase 5: nvm ok"
  needs_sdkman   && echo "fase 5: instalaria sdkman"         || echo "fase 5: sdkman ok"
  if [ -n "$PRIVATE_PATH" ]; then echo "overlay: rodaria $PRIVATE_PATH/overlay.sh"; fi
  exit 0
fi

echo "== fase 1/5: Xcode Command Line Tools =="
if needs_clt; then xcode-select --install; log "aguarde a instalacao e rode de novo"; exit 0
else log "ja instalado"; fi

echo "== fase 2/5: Homebrew =="
if needs_homebrew; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else log "ja instalado"; fi

echo "== fase 3/5: brew bundle =="
brew bundle --file="$REPO_ROOT/Brewfile"

echo "== fase 4/5: symlinks =="
phase_symlinks "$REPO_ROOT"

echo "== fase 5/5: runtimes =="
if needs_nvm; then brew install nvm; mkdir -p "$DOTFILES_TARGET/.nvm"; else log "nvm ja instalado"; fi
if needs_sdkman; then curl -s "https://get.sdkman.io" | bash; else log "sdkman ja instalado"; fi

if [ -n "$PRIVATE_PATH" ]; then
  echo "== overlay privado =="
  bash "$PRIVATE_PATH/overlay.sh"
fi

cat <<'MANUAL'

== falta fazer a mao ==
  1. preencher ~/.zshrc.local       (modelo: home/.zshrc.local.template)
  2. preencher ~/.gitconfig.local   (modelo: home/.gitconfig.local.template)
  3. preencher ~/.npmrc             (modelo: home/.npmrc.template)
  4. gh auth login
  5. gerar chave SSH e registrar no GitHub
  6. nvm install 20 && nvm install 24
  7. sdk install java
  8. iTerm2: Preferences > General > Settings > Save settings to folder
  9. apps provisionados pela TI: abrir chamado
 10. login em Slack, Linear, Spotify, Chrome, Drive, Obsidian, Granola
MANUAL
