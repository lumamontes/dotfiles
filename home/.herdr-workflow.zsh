# Helpers for grouping one feature across several service repositories.

herdr-feature() {
  if (( $# < 3 )); then
    print "usage: herdr-feature <feature-label> <tab=repo> [tab=repo ...]" >&2
    return 2
  fi

  local feature_label="$1"
  local first="$2"
  local first_name="${first%%=*}"
  local first_repo="${first#*=}"
  local repo_spec tab_name repo
  local response workspace_id first_tab_id
  shift 2

  if [[ "$first" != *=* || -z "$first_name" || -z "$first_repo" ]]; then
    print "herdr-feature: service tabs must use tab=repo" >&2
    return 2
  fi
  if [[ ! -d "$first_repo" ]]; then
    print "herdr-feature: repository not found: $first_repo" >&2
    return 1
  fi

  first_repo="${first_repo:A}"
  response="$(herdr workspace create \
    --cwd "$first_repo" \
    --label "$feature_label" \
    --focus)" || return
  workspace_id="$(print -r -- "$response" | jq -r '.result.workspace.workspace_id')"
  first_tab_id="$(print -r -- "$response" | jq -r '.result.tab.tab_id')"

  if [[ -z "$workspace_id" || "$workspace_id" == "null" ]]; then
    print "herdr-feature: Herdr did not return a workspace id" >&2
    return 1
  fi

  herdr tab rename "$first_tab_id" "$first_name" || return

  for repo_spec in "$@"; do
    tab_name="${repo_spec%%=*}"
    repo="${repo_spec#*=}"
    if [[ "$repo_spec" != *=* || -z "$tab_name" || -z "$repo" ]]; then
      print "herdr-feature: service tabs must use tab=repo" >&2
      return 2
    fi
    if [[ ! -d "$repo" ]]; then
      print "herdr-feature: repository not found: $repo" >&2
      return 1
    fi

    repo="${repo:A}"
    herdr tab create \
      --workspace "$workspace_id" \
      --cwd "$repo" \
      --label "$tab_name" \
      --no-focus || return
  done
}

herdr-worktree() {
  if (( $# < 3 )); then
    print "usage: herdr-worktree <task-label> <repo> <branch>" >&2
    return 2
  fi

  local task_label="$1"
  local repo="$2"
  local branch="$3"
  local repo_name

  if [[ ! -d "$repo" ]]; then
    print "herdr-worktree: repository not found: $repo" >&2
    return 1
  fi

  repo="${repo:A}"
  repo_name="${repo:t}"
  herdr worktree create \
    --cwd "$repo" \
    --branch "$branch" \
    --label "$task_label / $repo_name [worktree]" \
    --focus
}
