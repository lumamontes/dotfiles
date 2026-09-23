#!/usr/bin/env bats

setup() {
  load_target="$BATS_TEST_DIRNAME/../lib/phases.sh"
  TEST_HOME="$(mktemp -d)"
  SRC_DIR="$(mktemp -d)"
  export DOTFILES_TARGET="$TEST_HOME"
  echo "conteudo-origem" > "$SRC_DIR/.zshrc"
  # shellcheck disable=SC1090
  . "$load_target"
}

teardown() {
  rm -rf "$TEST_HOME" "$SRC_DIR"
}

@test "cria o symlink quando o destino nao existe" {
  run link_file "$SRC_DIR/.zshrc" "$TEST_HOME/.zshrc"
  [ "$status" -eq 0 ]
  [ -L "$TEST_HOME/.zshrc" ]
  [ "$(readlink "$TEST_HOME/.zshrc")" = "$SRC_DIR/.zshrc" ]
}

@test "e idempotente: rodar tres vezes nao muda nada" {
  link_file "$SRC_DIR/.zshrc" "$TEST_HOME/.zshrc"
  link_file "$SRC_DIR/.zshrc" "$TEST_HOME/.zshrc"
  run link_file "$SRC_DIR/.zshrc" "$TEST_HOME/.zshrc"
  [ "$status" -eq 0 ]
  [ "$(readlink "$TEST_HOME/.zshrc")" = "$SRC_DIR/.zshrc" ]
  [ "$(find "$TEST_HOME" -maxdepth 1 -name '.zshrc*' | wc -l)" -eq 1 ]
}

@test "faz backup de arquivo real preexistente" {
  echo "config-antiga-do-usuario" > "$TEST_HOME/.zshrc"
  run link_file "$SRC_DIR/.zshrc" "$TEST_HOME/.zshrc"
  [ "$status" -eq 0 ]
  [ -L "$TEST_HOME/.zshrc" ]
  backup="$(find "$TEST_HOME" -maxdepth 1 -name '.zshrc.backup-*' | head -1)"
  [ -n "$backup" ]
  [ "$(cat "$backup")" = "config-antiga-do-usuario" ]
}

@test "corrige symlink que aponta para o lugar errado" {
  ln -s /tmp/lugar-errado "$TEST_HOME/.zshrc"
  run link_file "$SRC_DIR/.zshrc" "$TEST_HOME/.zshrc"
  [ "$status" -eq 0 ]
  [ "$(readlink "$TEST_HOME/.zshrc")" = "$SRC_DIR/.zshrc" ]
}

@test "substitui diretorio existente em vez de linkar dentro dele" {
  mkdir -p "$TEST_HOME/.config/gh"
  mkdir -p "$SRC_DIR/gh"
  echo "cfg" > "$SRC_DIR/gh/config.yml"
  run link_file "$SRC_DIR/gh" "$TEST_HOME/.config/gh"
  [ "$status" -eq 0 ]
  [ -L "$TEST_HOME/.config/gh" ]
  [ ! -e "$TEST_HOME/.config/gh/gh" ]
}

@test "cria diretorios intermediarios do destino" {
  run link_file "$SRC_DIR/.zshrc" "$TEST_HOME/fundo/do/poco/.zshrc"
  [ "$status" -eq 0 ]
  [ -L "$TEST_HOME/fundo/do/poco/.zshrc" ]
}

@test "falha quando a origem nao existe" {
  run link_file "$SRC_DIR/nao-existe" "$TEST_HOME/.zshrc"
  [ "$status" -eq 1 ]
  [ ! -e "$TEST_HOME/.zshrc" ]
}
