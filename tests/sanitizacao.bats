#!/usr/bin/env bats
#
# Os padroes abaixo sao genericos de proposito: um teste que escreve o
# hostname interno literal vazaria exatamente o que veio impedir, e casaria
# consigo mesmo. A denylist nominal vive no repo privado.

setup() {
  REPO="$BATS_TEST_DIRNAME/.."
  SELF=":(exclude)tests/sanitizacao.bats"
}

@test "nenhum arquivo versionado contem token" {
  run git -C "$REPO" grep -lE 'gh[pousr]_[A-Za-z0-9]{30}|github_pat_[A-Za-z0-9_]{30}|eyJhbGciOi' -- . "$SELF"
  [ "$status" -ne 0 ]
}

@test "nenhum arquivo versionado contem path absoluto de usuario" {
  run git -C "$REPO" grep -lE '/Users/[a-z]+\.[a-z]+' -- . "$SELF"
  [ "$status" -ne 0 ]
}

@test "nenhum arquivo versionado contem hostname de infra interna" {
  run git -C "$REPO" grep -lE '[a-z0-9-]+\.(cloud|internal|corp|intranet)' -- . "$SELF"
  [ "$status" -ne 0 ]
}

@test "nenhum arquivo versionado contem asset tag de maquina corporativa" {
  run git -C "$REPO" grep -lE '[A-Z]{3,}-[A-Z0-9]{8,}' -- . "$SELF"
  [ "$status" -ne 0 ]
}

@test ".zshrc faz source do .local" {
  run grep -q 'zshrc.local' "$REPO/home/.zshrc"
  [ "$status" -eq 0 ]
}

@test ".zshrc chama compinit uma vez so" {
  n="$(grep -c 'compinit' "$REPO/home/.zshrc")"
  [ "$n" -eq 1 ]
}

@test "o template lista as variaveis sem valores" {
  run grep -q 'GITHUB_TOKEN=""' "$REPO/home/.zshrc.local.template"
  [ "$status" -eq 0 ]
}
