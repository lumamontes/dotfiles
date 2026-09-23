# dotfiles

Meu setup de macOS: zsh, git, `Brewfile` e um `bootstrap.sh` idempotente.

## Máquina nova

```bash
git clone https://github.com/lumamontes/dotfiles ~/www/dotfiles
cd ~/www/dotfiles
./bootstrap.sh
```

`./bootstrap.sh --dry-run` mostra o que ele faria sem escrever nada.

O script instala Xcode CLT, Homebrew, o `Brewfile`, oh-my-zsh, os symlinks e os
runtimes (nvm, sdkman) — pulando o que já existe. No fim, imprime o que ainda
falta fazer à mão: preencher os arquivos `.local`, `gh auth login`, chave SSH e
os logins de app.

Arquivo real preexistente vira `.backup-<timestamp>` antes de ser substituído.
Nada é sobrescrito.

## Segredos

Não há nenhum aqui, e não deve haver. Tokens ficam em arquivos `.local`, fora do
git — os `.template` dizem o que preencher:

```
home/.zshrc.local.template      →  ~/.zshrc.local
home/.gitconfig.local.template  →  ~/.gitconfig.local
home/.npmrc.template            →  ~/.npmrc
```

O `.gitignore` é uma allowlist: começa com `*` e libera cada arquivo pelo nome,
então arquivo novo só entra com uma linha consciente. Um hook de pre-commit roda
`gitleaks` como segunda barreira.

## Estrutura

```
bootstrap.sh     6 fases, cada uma checa antes de agir
lib/phases.sh    link_file, guards, symlinks
home/            vira ~/.<arquivo>
config/          vira ~/.config/<pasta>/<arquivo>
```

## Testes

```bash
bats tests/ && shellcheck bootstrap.sh lib/phases.sh
```

`lib/phases.sh` lê o destino de `DOTFILES_TARGET`, não de `$HOME` — é o que
permite rodar a suíte contra um diretório temporário sem tocar na máquina real.
