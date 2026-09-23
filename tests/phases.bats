#!/usr/bin/env bats

setup() {
  TEST_HOME="$(mktemp -d)"
  REPO_FIXTURE="$(mktemp -d)"
  export DOTFILES_TARGET="$TEST_HOME"
  # shellcheck disable=SC1090
  . "$BATS_TEST_DIRNAME/../lib/phases.sh"
}

teardown() {
  rm -rf "$TEST_HOME" "$REPO_FIXTURE"
}

@test "needs_nvm e verdadeiro quando o diretorio nao existe" {
  run needs_nvm
  [ "$status" -eq 0 ]
}

@test "needs_nvm e falso quando o diretorio existe" {
  mkdir -p "$TEST_HOME/.nvm"
  run needs_nvm
  [ "$status" -eq 1 ]
}

@test "needs_sdkman e verdadeiro quando o diretorio nao existe" {
  run needs_sdkman
  [ "$status" -eq 0 ]
}

@test "needs_sdkman e falso quando o diretorio existe" {
  mkdir -p "$TEST_HOME/.sdkman"
  run needs_sdkman
  [ "$status" -eq 1 ]
}

@test "phase_symlinks linka home/ e config/ do repo" {
  mkdir -p "$REPO_FIXTURE/home" "$REPO_FIXTURE/config/gh"
  echo "z" > "$REPO_FIXTURE/home/.zshrc"
  echo "g" > "$REPO_FIXTURE/home/.gitconfig"
  echo "c" > "$REPO_FIXTURE/config/gh/config.yml"

  run phase_symlinks "$REPO_FIXTURE"
  [ "$status" -eq 0 ]
  [ -L "$TEST_HOME/.zshrc" ]
  [ -L "$TEST_HOME/.gitconfig" ]
  [ -L "$TEST_HOME/.config/gh" ]
}

@test "phase_symlinks ignora arquivos .template" {
  mkdir -p "$REPO_FIXTURE/home"
  echo "z" > "$REPO_FIXTURE/home/.zshrc"
  echo "t" > "$REPO_FIXTURE/home/.zshrc.local.template"

  run phase_symlinks "$REPO_FIXTURE"
  [ "$status" -eq 0 ]
  [ -L "$TEST_HOME/.zshrc" ]
  [ ! -e "$TEST_HOME/.zshrc.local.template" ]
}

@test "phase_symlinks e idempotente" {
  mkdir -p "$REPO_FIXTURE/home"
  echo "z" > "$REPO_FIXTURE/home/.zshrc"
  phase_symlinks "$REPO_FIXTURE"
  run phase_symlinks "$REPO_FIXTURE"
  [ "$status" -eq 0 ]
  [ "$(find "$TEST_HOME" -maxdepth 1 -name '.zshrc*' | wc -l)" -eq 1 ]
}
