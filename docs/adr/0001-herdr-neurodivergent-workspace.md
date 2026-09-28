# Herdr workspace for parallel agent work

Status: accepted

We use Herdr as the persistent workspace manager for coding agents because the
main problem is not starting parallel work; it is returning to the right piece
of work after attention shifts. The setup externalizes context in the sidebar,
keeps navigation close to the arrow-key mental model, delays non-urgent
notifications, and keeps the configuration in the shared dotfiles repository
so another macOS machine can reproduce it.

## Goal

Support a workflow where one feature can span multiple repositories, branches,
worktrees, tabs, and agents without requiring the operator to remember their
locations or repeatedly inspect every terminal.

The primary user needs are:

- Know which feature groups the work and which repository each service tab
  represents.
- Distinguish grouped worktrees from the parent repository.
- See whether an agent is working, blocked, done, idle, or unknown.
- See the agent or terminal-generated task title when one exists.
- Move between tabs with a small, memorable gesture.
- Avoid notifications becoming another source of sensory or attentional load.
- Reproduce the setup on another Mac without manually reconstructing it.

## Implemented

The tracked Herdr configuration provides:

- `Shift+Left` and `Shift+Right` for previous and next tab.
- `Ctrl+Alt+1..9` for indexed tab jumps.
- `Ctrl+Alt+Shift+1..9` for indexed workspace jumps.
- `Ctrl+B`, then `w`, to open the workspace navigator and focus another
  workspace with the arrow keys and `Enter`.
- `Ctrl+Alt+h/j/k/l` for pane movement.
- Mouse capture disabled so terminal-native selection and scrolling remain
  reliable.
- `herdr-feature` for one feature workspace with one service tab per repository.
- `herdr-worktree` for an explicitly labelled worktree workspace.
- OpenCode transcript line scrolling on `Ctrl+Alt+Up/Down`.
- Prefix bindings remain available through `Ctrl+B` as a fallback.
- CLI workspace listing and focus remain available when keyboard navigation is
  inconvenient: `herdr workspace list` and `herdr workspace focus <id>`.
- Sidebar rows for agent state, agent name, workspace, tab, pane, terminal
  title, and optional `$summary` metadata.
- Sidebar rows for workspace name, Git branch, and Git status.
- Symbolic state indicators so status is not communicated by color alone.
- Verbose five-state text hidden from the sidebar to reduce reading load while
  preserving the internal state model.
- Outer terminal titles containing host, workspace, tab, pane, and terminal
  title.
- System notifications delayed by five seconds.
- Sound enabled for Claude and OpenCode agents.
- Native agent session restore left enabled.
- Herdr-managed worktrees rooted at `~/.herdr/worktrees`.
- A tracked dotfiles config that is symlinked into `~/.config/herdr/`.

## Naming model

The terms in this setup have precise meanings:

- **Session**: Herdr's persistent server namespace.
- **Workspace**: the feature, repository, or worktree-level container.
- **Worktree**: a Git checkout that Herdr groups under its parent workspace.
- **Tab**: a service, agent session, or view within a workspace; tabs may use
  different repository paths when they belong to one feature.
- **Pane**: an individual terminal.
- **Agent**: a recognized coding-agent process inside a pane.
- **Terminal title**: text emitted by the pane application, usually including
  an agent-generated task title when that agent publishes one.
- **Summary**: optional display-only metadata reported through Herdr's CLI or
  agent skill, intended for a short current task or next action.

The UI may call workspaces "spaces" in its navigator. This is only a display
term; the CLI and configuration use `workspace` consistently.

For a multi-service feature, tabs are the high-level service contexts. Panes
are reserved for closely related processes within one service, such as its
server, logs, and tests.

## Decisions and tradeoffs

### Arrow-key navigation

Plain `Left` and `Right` remain pane-navigation aliases in Herdr and are not
reassigned to tabs. Reusing them would make the same gesture mean different
things depending on hidden mode. `Shift+Left` and `Shift+Right` are the chosen
tab gestures because they preserve the spatial model without taking the plain
arrows away from pane movement.

`Ctrl+Alt` indexed shortcuts remain available because Herdr documents that
modifier family as more likely to pass through macOS terminals safely than
plain `Alt` shortcuts. They are a fallback for direct tab selection, not the
primary learning path.

### Mouse and scrolling

Mouse capture is disabled because copying terminal text is a frequent workflow
and selection accuracy is more important than clickable Herdr borders for this
setup. OpenCode's line-scroll shortcuts provide a smooth viewport without
requiring Page Up/Page Down keys.

### Context over notification volume

The sidebar is the primary attention surface. System notifications are useful
when the operator is away from a workspace, but they are delayed five seconds
to filter transient state changes. Sound remains enabled because an auditory
signal can be useful when the terminal is not visible, but it is explicitly
scoped to the agents currently in use.

Herdr does not currently provide a documented general notification rate limit
or digest. If notifications remain overwhelming, the next reversible changes
are to disable sound, switch delivery to in-app Herdr toasts, increase the
delay, or turn popups off.

### Agent-generated titles

Herdr displays normalized terminal titles and can display custom metadata, but
it does not generate an AI summary itself. OpenCode currently publishes a
useful terminal title in the active session. Claude Code is supported by Herdr
and can use the same display surface when Claude emits a terminal title; title
availability and wording remain agent-dependent.

### Portability

The durable configuration belongs in dotfiles rather than Herdr's generated
session state. A new machine receives the config through the existing dotfiles
bootstrap, then installs the supported agent integrations. Herdr's live session
state, agent conversations, notification permissions, and OS-specific terminal
settings are intentionally not copied as configuration files.

## Evidence and design rationale

This setup treats ADHD and autistic traits as heterogeneous support needs, not
as a fixed interface specification. It follows evidence and clinical guidance
favoring external structure, predictable transitions, visible state, and
environmental modification. Research on interruptions and notifications also
supports delaying and reducing disruptive alerts, because interruption cost can
exist even when a notification is ignored.

Useful references:

- NICE, [ADHD: diagnosis and management](https://www.nice.org.uk/guidance/ng87).
- NICE, [Autism in adults](https://www.nice.org.uk/guidance/cg142).
- Mark, Gudith, and Klocke, [The cost of interrupted work](https://doi.org/10.1145/1357054.1357072).
- Stothart, Mitchum, and Yehnert, [The attentional cost of receiving a cell phone notification](https://doi.org/10.1037/xhp0000100).

These sources support environmental scaffolding and lower interruption cost;
they do not validate Herdr specifically or prove that any single keymap will
work for every ADHD or autistic person.

## Out of scope

- Automatically generating or judging the quality of agent task titles.
- Persisting pane screen history, because it can retain secrets and prompts.
- Automatically mirroring live Herdr sessions between Macs.
- Treating Herdr status as proof that an agent completed work correctly.
- Building a notification digest or rate limiter before observing actual use.
- Adding a literal `worktree: yes/no` token, since Herdr currently exposes
  worktree grouping and branch information rather than that exact sidebar token.

## Follow-up candidates

- Install the official Herdr agent skill on each machine if agents need to
  create panes, report summaries, or wait on sibling agents themselves.
- Add a small trusted plugin that reports explicit `repo`, `branch`, and
  `worktree` metadata if grouped indentation is not sufficiently clear.
- Run a one-week observation period and record missed notifications,
  unnecessary interruptions, and time-to-resume after switching tasks.
- Revisit `Shift+Left` / `Shift+Right` after testing in the actual outer terminal
  used on both Macs; terminal key handling can consume direct chords.
