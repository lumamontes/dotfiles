# Herdr Daily Workflow

This guide describes how to use Herdr as a replacement for manually managing
many iTerm2 tabs while working with multiple coding agents.

The goal is not to prevent parallel work. The goal is to make parallel work
recoverable after attention shifts, interruptions, or hyperfocus on another
task.

## The Mental Model

Herdr adds a hierarchy around the terminal:

| Herdr concept | Use it for |
| --- | --- |
| Session | The persistent Herdr server namespace |
| Workspace | A feature/task group, repository, or Git worktree |
| Tab | One service, agent session, or view inside a workspace |
| Pane | A terminal, test runner, server, or supporting shell |
| Agent | Claude Code, OpenCode, or another recognized coding agent |

The recommended mapping is:

- Feature or task spanning several repositories = workspace.
- Service repository or agent session within that feature = tab.
- Repository-only task or isolated worktree = workspace.
- Supporting terminal process = pane.
- Agent-generated task title = terminal title.
- Short current task or next action = optional summary metadata.

Example:

```text
Workspace: PAY-123 checkout
Tab: frontend
Repository: checkout-web
Agent title: Implement checkout screen
Pane: Claude Code
Status: ATTENTION
```

## Starting The Day

Open one iTerm2 window and start Herdr once:

```bash
herdr
```

If Herdr is already running, this attaches to the existing default session.
Do not start a nested `herdr` inside a Herdr pane.

For a single-repository task, create or open a workspace for that repository.
For a feature that spans several services, create one feature workspace and
one tab per service:

```bash
herdr-feature "PAY-123 checkout" \
  frontend=~/www/checkout-web \
  bff=~/www/checkout-bff \
  backend=~/www/checkout-api
```

Then start the main agent in the relevant tab:

```bash
claude
```

Herdr detects supported agents automatically. The sidebar shows the agent,
workspace, tab, pane, status, and terminal title.

## Where To Run The Helper

`herdr-feature` is a zsh function loaded from `~/.zshrc`. It talks to the
already-running Herdr server; it is not typed into the Herdr command palette.

You can run it in either place:

- A normal iTerm2 shell outside the Herdr interface, while Herdr is already
  running in another terminal tab or window.
- A shell pane inside Herdr. Open a new Herdr tab with `Ctrl+B`, then `c`, and
  run it there.

If the shell was opened before the dotfiles update, load the helper first:

```bash
source ~/.zshrc
```

Example from a normal iTerm2 shell:

```bash
herdr status
herdr-feature "PAY-123 checkout" \
  frontend=~/www/checkout-web \
  bff=~/www/checkout-bff \
  backend=~/www/checkout-api
```

The helper creates the workspace and tabs but does not decide which commands
to run in them. Afterward, focus each tab and start Claude or the service
process there. This separation is deliberate: the same service may be started
with different commands on different projects or machines.

## Choosing Tabs Or Worktrees

Use another **tab** for a service or supporting view that belongs to the same
feature, even when it lives in a different repository. Good examples are:

- Frontend, BFF, and backend repositories needed to test one feature.
- A Claude implementation session and a service process.
- A service process and its logs or test runner.

Use another **workspace** when the work is a separate task or needs an
independent branch/worktree. Good examples are:

- A feature and a bug fix in parallel.
- An implementation agent and a refactoring agent.
- Work that must not change the files another agent is currently editing.

Herdr groups managed worktrees under the parent repository workspace. The
sidebar shows the relationship through grouping and indentation, while branch
names remain visible. A worktree created for one service is still a separate
workspace; give it the same feature label when it belongs to the same feature.

## One Task Across Multiple Services

Herdr does not currently create a first-class parent task containing several
repositories. The simple grouping convention is one feature workspace with one
tab per service:

```bash
herdr-feature "PAY-123 checkout" \
  frontend=~/www/checkout-web \
  bff=~/www/checkout-bff \
  backend=~/www/checkout-api
```

This creates one workspace labelled `PAY-123 checkout` and tabs labelled
`frontend`, `bff`, and `backend`, each rooted in its own repository. The command
focuses the new workspace, so you can immediately start the feature's main
Claude session in the frontend tab and run the other services in their tabs.

Create a separately branched worktree with an explicit label:

```bash
herdr-worktree "PAY-123 checkout" \
  ~/www/checkout-api \
  pay-123-checkout-api
```

Use one tab for each service's main agent or process. Use additional panes for
that service's tests, logs, or local server. The shared feature workspace keeps
the services visually grouped while each tab retains its own repository path.

The helper is loaded by the tracked `.zshrc` configuration. Herdr should be
running before invoking it.

The current setup disables Herdr mouse capture so terminal-native text
selection and scrolling work normally. This means the Herdr sidebar and split
borders are keyboard-driven; use the shortcuts in the next section instead of
dragging Herdr UI elements.

## Moving Around

The primary low-memory shortcuts are:

- `Shift+Left`: previous tab.
- `Shift+Right`: next tab.
- `Ctrl+Alt+1..9`: jump directly to a tab.
- `Ctrl+Alt+Shift+1..9`: jump directly to a workspace.
- `Ctrl+Alt+h/j/k/l`: move between panes.
- `Ctrl+B`, then `w`: open the workspace navigator.
- `Ctrl+B`, then `?`: show active keybindings.
- `Ctrl+B`, then `q`: detach while agents continue running.

### Switching Workspaces (Spaces)

In the Herdr UI, a workspace is the same high-level container that may be
shown as a space in the navigator. To switch directly between workspaces:

- Press `Ctrl+Alt+Shift+1..9` to jump to the workspace at that index.
- Press `Ctrl+B`, then `w` to open the workspace navigator, use the arrow keys
  to select a workspace, and press `Enter` to focus it.

If the navigator appears not to move, verify that more than one workspace
exists. Tabs inside one workspace are not separate workspaces. Create another
workspace when the work is independent:

```bash
herdr workspace list
herdr workspace create --cwd ~/www/another-repository --label "another task"
```

The CLI can focus an exact workspace when keyboard navigation is inconvenient:

```bash
herdr workspace list
herdr workspace focus <workspace-id>
```

Use the ID returned by `herdr workspace list`; do not infer it from the
workspace's position in the sidebar. Workspace focus changes the active
workspace but does not stop its agents or panes.

Plain arrow keys remain available for pane and navigation movement. They are
not assigned to tabs because Herdr reserves left and right arrows as pane
navigation aliases.

When the workspace navigator is open, arrow keys move through the available
workspaces. If only one workspace exists, the selection will not visibly move.
After creating or focusing a workspace, use `Ctrl+Alt+Shift+1..9` for quick
switching once its index is known.

For OpenCode message scrolling, use its smooth line movement shortcuts:

- `Ctrl+Alt+Up`: one line up.
- `Ctrl+Alt+Down`: one line down.
- `Ctrl+Alt+U`: half page up.
- `Ctrl+Alt+D`: half page down.

These are different from Herdr's tab and pane shortcuts and preserve a
scrollable viewport instead of jumping directly between messages.

These OpenCode shortcuts are configured in the local OpenCode TUI settings.
Restart OpenCode after changing that configuration, including on another Mac.

The prefix fallback is always available:

- `Ctrl+B`, then `p`: previous tab.
- `Ctrl+B`, then `n`: next tab.
- `Ctrl+B`, then `1..9`: jump to a tab.

## The Attention Model

Herdr internally distinguishes five states:

| Internal state | Meaning |
| --- | --- |
| `working` | The agent is actively working |
| `blocked` | The agent needs input, approval, or a decision |
| `done` | The agent finished and has not been reviewed yet |
| `idle` | The agent is ready and does not currently need attention |
| `unknown` | Herdr cannot classify the current state confidently |

For daily use, these can be mentally reduced to three categories:

| Simple category | Internal states | What to do |
| --- | --- | --- |
| `RUNNING` | `working` | Leave it alone |
| `ATTENTION` | `blocked`, `done`, `unknown` | Inspect it when ready |
| `CLEAR` | `idle` | No immediate action |

The internal distinctions remain useful. A blocked agent needs an answer; a
done agent needs review; an unknown agent needs diagnosis. The simplified model
is only a presentation aid. The sidebar intentionally hides the verbose
`state_text` labels and keeps the compact state symbols instead. Herdr still
uses the full internal state model for notifications, waits, rollups, and
automation.

## Notifications

The current policy is intentionally conservative:

- System notifications are enabled.
- Notifications wait five seconds before appearing.
- Notifications for the active tab are suppressed.
- Sounds remain enabled for Claude and OpenCode.
- Pane screen-history persistence remains disabled because it may retain
  secrets, prompts, tokens, and command output.

Treat a notification as a request to inspect a workspace, not an instruction
to abandon the task currently holding your attention.

If notifications become overwhelming, adjust them in this order:

1. Disable sound.
2. Increase the notification delay.
3. Switch from system notifications to in-app Herdr toasts.
4. Disable popups entirely and rely on the sidebar.

Herdr currently has no documented general notification digest or rate limiter.

## Titles And Context

Herdr can display the terminal title emitted by an agent. OpenCode currently
publishes a title in the active setup. Claude Code is supported by Herdr and can
use the same display surface when Claude emits a terminal title.

Herdr itself does not generate an AI task title. Title quality and availability
depend on the agent. A future skill or plugin may report a short summary such
as:

```bash
herdr pane report-metadata <pane-id> \
  --source workflow \
  --token summary="reviewing authentication flow"
```

The configured sidebar includes `$summary`, but it remains empty until an
agent or script reports one.

## Detaching And Returning

Detach without stopping anything:

```text
Ctrl+B, q
```

The Herdr server keeps panes, agents, tests, servers, and shells running.
Reattach later:

```bash
herdr
```

This is preferable to closing individual iTerm2 tabs when the work is merely
waiting.

## Existing Terminal Sessions

Herdr cannot adopt arbitrary live terminal tabs because those processes belong
to the outer terminal rather than the Herdr server.

Migration is still possible:

- Leave existing sessions running while migrating.
- Create the matching workspace and tab inside Herdr.
- Reopen Claude using its native session resume command when the session ID is
  available:

```bash
claude --resume <session-id>
```

- Reopen OpenCode using its native session identifier:

```bash
opencode --session <session-id>
```

- Restart ordinary shells, servers, and test runners inside Herdr.

## New-Machine Setup

The durable Herdr configuration lives in the dotfiles repository:

```text
config/herdr/config.toml
```

On another Mac:

```bash
git clone https://github.com/lumamontes/dotfiles ~/www/dotfiles
cd ~/www/dotfiles
./bootstrap.sh
herdr server reload-config
herdr integration install claude
herdr integration install opencode
```

The bootstrap links the tracked configuration to:

```text
~/.config/herdr/config.toml
```

Herdr session state, native agent conversations, macOS notification
permissions, and outer-terminal settings are machine-specific and are not
copied by this configuration.

## Adjustment Period

The main behavioral change is moving from this model:

```text
Many unrelated iTerm2 tabs -> manually inspect each one
```

to this model:

```text
One Herdr session -> feature workspaces group related service tabs
```

During the first week:

- Start with one feature workspace and two or three service tabs.
- Use a workspace for the feature, tabs for its services, and panes for logs,
  tests, and local processes.
- Create a separate worktree workspace only when a service needs an independent
  branch or parallel edit.
- Name important tabs and workspaces immediately.
- Let the sidebar and notifications replace repeated tab polling.
- Record which notifications were useful or disruptive.
- Check whether `Shift+Left` and `Shift+Right` survive the chosen terminal's
  key handling.
- Use `source ~/.zshrc` once in shells opened before the helper was installed.
- Confirm that mouse selection copies only the intended terminal text after
  Herdr mouse capture is disabled.

The setup should be adjusted based on actual interruption and resumption
experience, not on an assumed universal ADHD or autistic workflow.

## Related Decision Record

See [`docs/adr/0001-herdr-neurodivergent-workspace.md`](adr/0001-herdr-neurodivergent-workspace.md)
for the rationale, evidence, tradeoffs, and out-of-scope decisions behind this
setup.
