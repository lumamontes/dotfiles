# dotfiles

Meu setup de macOS: zsh, git, `Brewfile` e um `bootstrap.sh` idempotente.

## Máquina nova

```bash
git clone https://github.com/lumamontes/dotfiles ~/www/dotfiles
cd ~/www/dotfiles
./bootstrap.sh
```

`./bootstrap.sh --dry-run` mostra o que ele faria sem escrever nada.

### Herdr

O `Brewfile` instala o Herdr e `config/herdr/config.toml` vira um symlink em
`~/.config/herdr/config.toml`. Depois do bootstrap, recarregue a configuracao:

```bash
herdr server reload-config
herdr integration install claude
herdr integration install opencode
```

O arquivo versionado deixa visiveis workspace, branch, status Git, pane e o
titulo que o agente publica. `Shift+Left/Right` troca tabs; tambem existem os
atalhos diretos `Ctrl+Alt+1..9` para tabs e `Ctrl+Alt+Shift+1..9` para
workspaces. O prefixo `Ctrl+B` continua disponivel como fallback e para abrir
a ajuda (`Ctrl+B`, `?`) ou o navegador de workspaces (`Ctrl+B`, `w`). No
navegador, use as setas e `Enter` para focar outro workspace. Pela CLI, liste e
foque um workspace com `herdr workspace list` e `herdr workspace focus
<workspace-id>`.

O guia de uso diario esta em
`docs/herdr-daily-workflow.md`; a decisao e os tradeoffs estao em
`docs/adr/0001-herdr-neurodivergent-workspace.md`.
O cheatsheet para o trabalho diario esta em `docs/herdr-cheatsheet.md`.
As decisoes que ainda exigem teste manual estao em
`docs/herdr-open-decisions.md`.
Para uma feature que atravessa varios microservicos, use `herdr-feature` para
criar um workspace com uma tab por servico.
O helper roda em qualquer shell zsh enquanto o servidor Herdr estiver ativo:
em um tab normal do iTerm2 ou em um shell pane do proprio Herdr. Se necessario,
rode `source ~/.zshrc` antes.

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
