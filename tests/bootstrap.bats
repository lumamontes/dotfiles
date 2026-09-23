#!/usr/bin/env bats

setup() {
  BOOTSTRAP="$BATS_TEST_DIRNAME/../bootstrap.sh"
  TEST_HOME="$(mktemp -d)"
  export DOTFILES_TARGET="$TEST_HOME"
}

teardown() {
  rm -rf "$TEST_HOME"
}

@test "--help sai com zero e explica o uso" {
  run "$BOOTSTRAP" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--private"* ]]
}

@test "--private com caminho inexistente falha com mensagem clara" {
  run "$BOOTSTRAP" --dry-run --private /caminho/que/nao/existe
  [ "$status" -ne 0 ]
  [[ "$output" == *"nao encontrado"* ]]
}

@test "--private sem overlay.sh falha com mensagem clara" {
  vazio="$(mktemp -d)"
  run "$BOOTSTRAP" --dry-run --private "$vazio"
  rm -rf "$vazio"
  [ "$status" -ne 0 ]
  [[ "$output" == *"overlay.sh"* ]]
}

@test "flag desconhecida falha" {
  run "$BOOTSTRAP" --flag-que-nao-existe
  [ "$status" -ne 0 ]
}

@test "--dry-run nao escreve nada no destino" {
  run "$BOOTSTRAP" --dry-run
  [ "$status" -eq 0 ]
  [ -z "$(ls -A "$TEST_HOME")" ]
}
