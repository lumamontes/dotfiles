# dotfiles

Meu setup de macOS: configuração de shell, `Brewfile` e um `bootstrap.sh`
idempotente. Serve para reconstruir a máquina do zero com um clone e um comando.

## Máquina nova

```bash
git clone <este-repo> ~/www/dotfiles
cd ~/www/dotfiles
./bootstrap.sh
```

Veja antes o que ele faria, sem escrever nada:

```bash
./bootstrap.sh --dry-run
```

## O que o bootstrap faz

Cinco fases. Cada uma verifica antes de agir, então rodar N vezes dá sempre o
mesmo resultado.

| Fase | O quê |
|---|---|
| 1 | Xcode Command Line Tools |
| 2 | Homebrew |
| 3 | `brew bundle` — 25 fórmulas e 28 casks |
| 4 | Symlinks de `home/` e `config/` |
| 5 | nvm e sdkman |

Arquivo real preexistente (`~/.zshrc`, por exemplo) é movido para
`.backup-<timestamp>` antes de virar symlink. Nada é sobrescrito.

## Segredos

Não há nenhum neste repositório, e não deve haver. Tokens e configuração de
máquina ficam em arquivos `.local`, que estão no `.gitignore`:

```
home/.zshrc.local.template      ->  copie para  ~/.zshrc.local
home/.gitconfig.local.template  ->  copie para  ~/.gitconfig.local
home/.npmrc.template            ->  copie para  ~/.npmrc
```

O `.gitignore` é uma *allowlist*: começa com `*` e libera cada arquivo
nominalmente. Adicionar arquivo novo exige uma linha consciente — que é o
momento certo de decidir se aquilo pode ser público. Um hook de pre-commit
roda `gitleaks` como segunda barreira.

## Falta fazer à mão

O `bootstrap.sh` imprime esta lista ao terminar:

| Passo | Por quê |
|---|---|
| Preencher os três arquivos `.local` | Credenciais não são versionáveis |
| `gh auth login` | idem |
| Gerar chave SSH e registrar no GitHub | idem |
| `nvm install 20 && nvm install 24` | Versões em uso |
| `sdk install java` | JDK do `JAVA_HOME` |
| iTerm2: *Preferences → General → Settings → Save settings to folder* | A config do iTerm2 é um plist binário; este passo gera uma versão legível, que aí sim pode ser versionada |
| Login em Slack, Linear, Spotify, Chrome, Drive, Obsidian, Granola | Instalar não autentica |
| Aplicativos provisionados pela TI | Abrir chamado |

## Testes

```bash
brew install bats-core shellcheck gitleaks
bats tests/
shellcheck bootstrap.sh lib/phases.sh
```

A lógica testável vive em `lib/phases.sh` e lê o destino de `DOTFILES_TARGET`,
não de `$HOME` — é o que permite rodar a suíte contra um diretório temporário
sem tocar na máquina real.

## Estrutura

```
bootstrap.sh     orquestrador, 5 fases
lib/phases.sh    link_file, guards de idempotência, phase_symlinks
Brewfile         fórmulas e casks
home/            vira ~/.<arquivo>
config/          vira ~/.config/<pasta>
tests/           bats
```
