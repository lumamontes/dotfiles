# Herdr Cheatsheet

Use this tomorrow when replacing several independent Claude Code iTerm2 tabs
with one Herdr session.

## Start

Open one normal iTerm2 shell and run:

```bash
herdr
```

This attaches to the persistent Herdr session. Do not run `herdr` inside a
Claude Code pane.

If you open a new shell and the helper is missing:

```bash
source ~/.zshrc
type herdr-feature
```

## One Feature Across Services

Use one workspace for the feature and one tab per service repository:

```bash
herdr-feature "PAY-123 checkout" \
  frontend=~/www/checkout-web \
  bff=~/www/checkout-bff \
  backend=~/www/checkout-api
```

The paths above are examples. Replace them with real repository paths.

This creates and focuses:

```text
Workspace: PAY-123 checkout
Tab: frontend
Tab: bff
Tab: backend
```

Then focus each tab and run what belongs there:

```bash
claude
```

Run the BFF and backend processes in their service tabs. Use panes only when
one service needs multiple simultaneous processes.

## The Five Shortcuts To Learn First

Herdr shortcuts use a prefix. Press and release `Ctrl+B`, then press the next
key. Do not hold both keys as one chord.

```text
Ctrl+B, ?          Show the keyboard help
Ctrl+B, c          Create a new tab
Shift+Left/Right   Previous/next tab
Ctrl+B, w          Open workspace navigation
Ctrl+B, q          Detach and leave everything running
```

The help panel is a reference for when you forget a command. It is not part of
the normal workflow.

## Tab And Workspace Navigation

```text
Ctrl+Alt+1..9          Jump to tab 1..9
Ctrl+Alt+Shift+1..9    Jump to workspace 1..9
Ctrl+B, p              Previous tab
Ctrl+B, n              Next tab
Ctrl+B, 1..9           Jump to tab 1..9
```

Inside the workspace navigator:

```text
Up/Down                Move between workspaces
Enter                  Focus the selected workspace
Esc                    Leave the navigator
```

If there is only one workspace, Up/Down will appear to do nothing. That is
expected.

## Panes

Use tabs for separate services. Use panes for closely related processes inside
one service:

```text
Ctrl+B, v          Split right
Ctrl+B, -          Split down
Ctrl+Alt+h         Focus left pane
Ctrl+Alt+j         Focus pane below
Ctrl+Alt+k         Focus pane above
Ctrl+Alt+l         Focus right pane
Ctrl+B, z          Zoom the focused pane
Ctrl+B, x          Close the focused pane
```

Do not split everything immediately. Start with service tabs and add panes only
when logs, tests, and a server need to be visible together.

## Scrolling And Copying

Herdr mouse capture is disabled so normal terminal selection works:

- Drag over exactly the text you want.
- Release to select/copy according to the terminal behavior.
- Herdr sidebar and split borders are keyboard-driven.

For OpenCode transcript scrolling, restart OpenCode after the TUI configuration
change, then use:

```text
Ctrl+Alt+Up       One line up
Ctrl+Alt+Down     One line down
Ctrl+Alt+U        Half page up
Ctrl+Alt+D        Half page down
```

These provide a smooth viewport that can stop at any point. On a Mac keyboard,
`Fn+Up` and `Fn+Down` are the physical Page Up and Page Down keys, but they are
not the preferred workflow here.

## Parallel Branch Work

Create a separate worktree workspace when one service needs an independent
branch:

```bash
herdr-worktree \
  "PAY-123 checkout / backend" \
  ~/www/checkout-api \
  pay-123-checkout-api
```

The new workspace is focused and labelled with `[worktree]`.

## Waiting For Agents

Use the sidebar as the main dashboard:

```text
RUNNING      Leave it alone
ATTENTION    Inspect blocked, done, or unclear work
CLEAR        No immediate action
```

Herdr internally keeps more precise states, but the visible sidebar uses
symbols to reduce reading load.

When a notification arrives, inspect the relevant workspace when you reach a
natural stopping point. Do not treat every notification as an instruction to
abandon the task currently holding your attention.

## Leave And Return

Detach without stopping agents, servers, or tests:

```text
Ctrl+B, q
```

Later, attach again:

```bash
herdr
```

## If Something Is Wrong

```bash
herdr status
herdr workspace list
herdr agent list
herdr integration status
```

Useful checks:

- Helper missing: `source ~/.zshrc`.
- Workspace arrows do nothing: create or open a second workspace.
- OpenCode scroll shortcuts do nothing: restart OpenCode and check iTerm2 key
  mappings.
- Copy includes borders or extra characters: confirm Herdr mouse capture is
  disabled and use terminal-native drag selection.
- Agent is not detected: `herdr agent explain <target> --json`.

## Other Mac

After the dotfiles bootstrap:

```bash
herdr server reload-config
herdr integration install claude
source ~/.zshrc
```

The Herdr configuration and shell helper are tracked in the dotfiles
repository. OpenCode's local TUI scroll bindings still need to be copied into
that machine's `~/.config/opencode/tui.jsonc` and OpenCode must be restarted.

## Related Docs

- [`herdr-daily-workflow.md`](herdr-daily-workflow.md)
- [`herdr-open-decisions.md`](herdr-open-decisions.md)
- [`adr/0001-herdr-neurodivergent-workspace.md`](adr/0001-herdr-neurodivergent-workspace.md)
