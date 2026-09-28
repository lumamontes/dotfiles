# Herdr Open Decisions And Hands-On Checks

This file contains the parts of the Herdr setup that cannot be safely decided
from configuration alone. They require testing in the actual terminal, direct
observation of notification behavior, or a personal preference decision.

## 1. Test Arrow Shortcuts In iTerm2

The configured shortcuts are:

- `Shift+Left`: previous tab.
- `Shift+Right`: next tab.

Test them with at least two Herdr tabs open. If they do not work, inspect
iTerm2 key mappings and add forwarding rules for those two combinations. Keep
plain arrow keys available for pane navigation.

Acceptance criterion:

```text
I can move between nearby tabs without using the mouse or remembering a
multi-step prefix sequence.
```

## 2. Decide Whether Symbols Are Understandable

The sidebar hides the verbose five-state text and keeps symbolic indicators.
Use Herdr for several sessions and ask:

- Can I tell which agents need attention?
- Can I tell that a blocked agent is different from a completed agent?
- Do the symbols remain understandable when I am tired or switching tasks?

If symbols are insufficient, choose one of these directions:

- Show explicit `RUNNING`, `ATTENTION`, and `CLEAR` labels.
- Show `ATTENTION` only for blocked, done, and unknown states.
- Keep symbols but add a visible legend or a summary panel.

The current setup preserves Herdr's full internal state model regardless of
this presentation choice.

## 3. Verify Claude Code Titles

Open a Claude Code session inside Herdr and inspect the sidebar. Confirm:

- A useful terminal title appears.
- The title changes when the task changes, if Claude supports that behavior.
- The title is short enough to scan.
- The title does not expose sensitive prompt content.

If Claude does not publish useful titles, use a short manual pane name or have
the installed Herdr skill report a `$summary` value instead.

## 4. Test Notification Load

Run two small background tasks and observe:

- Number of macOS notifications.
- Number of sounds.
- Whether active work is interrupted.
- Whether blocked tasks are distinguishable from completed tasks.

Possible decisions:

- Keep system notifications and sound.
- Keep system notifications but disable sound.
- Use Herdr in-app toasts only.
- Disable notifications and rely on the sidebar.
- Build a digest or rate-limiting plugin later.

Herdr currently documents delay and active-tab suppression, but not a general
notification digest or rate limiter.

## 5. Validate The Installed Herdr Skill

The official Herdr skill is installed. Test it with a small two-agent exercise:

1. Ask one agent to create or inspect a sibling pane.
2. Ask it to wait for another agent.
3. Ask it to report a short summary.
4. Confirm it does not steal focus unexpectedly.

If the skill is useful, add its installation command to the setup checklist for
the second Mac. If it is not useful, keep Herdr as a visual workspace manager
without asking agents to control the layout.

## 6. macOS Portability Checks

The dotfiles repository carries the Herdr configuration, but the following
still require machine-specific setup:

- iTerm2 key forwarding.
- macOS notification permission.
- Agent authentication and login state.
- Herdr and agent integration installation.
- Native agent session storage.
- Any global skill installation.

On the second Mac, verify these explicitly rather than assuming the dotfiles
repository can copy them.

## 7. Deep-Work Notification Preference

Choose whether a dedicated deep-work mode is needed. Herdr does not currently
provide a complete built-in focus mode.

Possible approaches:

- Use macOS Focus mode manually.
- Disable Herdr sound temporarily with `HERDR_DISABLE_SOUND=1`.
- Switch Herdr delivery to `off` during deep work.
- Build a small command or plugin to toggle a quiet profile.

The choice depends on whether missing a blocked agent is worse than being
interrupted by a completion notification.

## 8. Microservices Task Organization

Herdr handles multiple repositories well, but it does not currently create a
first-class parent object for one task spanning several repositories.

The repository now includes a simple grouping helper. Create one feature
workspace with one tab per service:

```bash
herdr-feature "PAY-123 checkout" \
  frontend=~/www/checkout-web \
  bff=~/www/checkout-bff \
  backend=~/www/checkout-api
```

It creates the workspace and service tabs without changing focus. This keeps
the feature grouped without adding a manifest or task orchestration layer.

For a separate branch/worktree:

```bash
herdr-worktree "PAY-123 checkout" \
  ~/www/checkout-api \
  pay-123-checkout-api
```

The resulting workspace is explicitly labelled with `[worktree]`.

Use one tab per service for the main Claude session or service process, and
additional panes inside that tab for tests, logs, or local servers. This gives
one task a single visual group while preserving repository-specific paths and
statuses.

If this becomes a daily pattern, a future plugin could provide a real task
group row and aggregate status across services. That is not implemented yet.

## 9. Existing Terminal Migration

Live iTerm2 processes cannot be adopted by Herdr. Decide whether to:

- Finish existing sessions outside Herdr and start new work in Herdr.
- Resume Claude/OpenCode sessions inside newly created Herdr panes.
- Restart ordinary servers and test runners inside Herdr.

Do not close an old session until its work or native agent session has been
verified in the new pane.

## 10. One-Week Review

After one week, record:

- Tasks lost after switching contexts.
- Blocked agents missed.
- Notifications that were useful.
- Notifications that were disruptive.
- Whether workspace prefixes made multi-repository work understandable.
- Whether the sidebar or keyboard was the primary navigation tool.
- Whether a plugin is justified.
