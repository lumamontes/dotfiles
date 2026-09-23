#!/usr/bin/env bats

setup() {
  REPO="$BATS_TEST_DIRNAME/.."
}

@test "arquivo nao-allowlisted e ignorado" {
  touch "$REPO/segredo-acidental.txt"
  run git -C "$REPO" check-ignore -q segredo-acidental.txt
  rm -f "$REPO/segredo-acidental.txt"
  [ "$status" -eq 0 ]
}

@test "bootstrap.sh e rastreavel" {
  run git -C "$REPO" check-ignore -q bootstrap.sh
  [ "$status" -eq 1 ]
}

@test "Brewfile e rastreavel" {
  run git -C "$REPO" check-ignore -q Brewfile
  [ "$status" -eq 1 ]
}

@test "home/.zshrc.local nunca e rastreavel" {
  run git -C "$REPO" check-ignore -q home/.zshrc.local
  [ "$status" -eq 0 ]
}

@test "o hook de pre-commit e versionado" {
  run git -C "$REPO" check-ignore -q hooks/pre-commit
  [ "$status" -eq 1 ]
}

@test "o hook versionado e executavel" {
  [ -x "$REPO/hooks/pre-commit" ]
}
