#!/usr/bin/env bash
# Funcoes de fase do bootstrap. Sourceable e testavel isoladamente.
# Nenhuma funcao referencia $HOME: o destino vem de DOTFILES_TARGET.

DOTFILES_TARGET="${DOTFILES_TARGET:-$HOME}"

log()  { printf '  %s\n' "$*"; }
warn() { printf '  aviso: %s\n' "$*" >&2; }
die()  { printf '  erro: %s\n' "$*" >&2; exit 1; }

# link_file <origem_absoluta> <destino_absoluto>
# Cria symlink idempotente. Faz backup de destino real preexistente.
link_file() {
  local src="$1" dest="$2"

  if [ ! -e "$src" ]; then
    warn "origem inexistente: $src"
    return 1
  fi

  # Ja esta correto: nada a fazer.
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    return 0
  fi

  # Destino real (nao symlink): preserva antes de substituir.
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    local backup
    backup="${dest}.backup-$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    log "backup: $dest -> $backup"
  fi

  mkdir -p "$(dirname "$dest")"
  # -f sobrescreve link existente; -n impede que um link para diretorio
  # seja criado DENTRO do alvo em vez de substitui-lo.
  ln -sfn "$src" "$dest"
  log "link: $dest -> $src"
}
