#!/usr/bin/env bash
# vim:set expandtab shiftwidth=4 filetype=bash:
# SPDX-License-Identifier: GPL-3.0-only

#
#
# ~chewygumxx/dotfiles.git
# ::: :/home/dot_config/herdr/local-plugins/wtree-relocate/on-worktree-created.sh
#
#

#
# Handle worktree.created
#
# Migrate the new checkout, created via herdr native dialog, to conform
# to the wqrktrunk specified by worktree-path and trigger create hooks.
#
# Output lands in `herdr plugin log list`.
#

set -euo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"

# Payload (herdr 0.9.5)
# trimmed: {
#    "event": "worktree_created",
#    "data":{
#        "workspace": {
#            "label":…,
#            "focused":…,
#            "worktree":{ "repo_root":… }
#        },
#        "worktree": {
#            "path":…,
#            "branch":…,
#            "open_workspace_id":…
#        }
#    }
# }
# herdr runs this with HERDR_SOCKET_PATH set. As such, the herdr calls
# below are expected to reach the session that fired the event.

{
    read -r src
    read -r branch
    read -r ws
    read -r primary
    read -r label
    read -r focused
} < <(jq -r '.data |
      .worktree.path // "",
      .worktree.branch // "",
      .worktree.open_workspace_id // "",
      .workspace.worktree.repo_root // "",
      .workspace.label // "",
      .workspace.focused // false' <<<"${HERDR_PLUGIN_EVENT_JSON:-"{}"}")

# Detached checkouts have no branch for worktrunk to template a path from
[[ -n "$src" && -d "$src" && -n "$branch" && -n "$primary" ]] || exit 0

# [Idempotency Guard]
# Empty when checkout already exists within worktrunk specified path:
# - Created compliantly by plugin `devashish2203/herdr-worktrunk`
# - Self-Trigger following event below
dest=$(wt -C "$src" step relocate "$branch" --dry-run --format=json |
    jq -r '.entries[0].to // empty')
[[ -n "$dest" ]] || exit 0

mkdir -p "$(dirname "$dest")" # Ensure destination directory exists
wt -C "$primary" step relocate "$branch"

# The workspace's shells sit in a directory that no longer exists
[[ -z "$ws" ]] || "$herdr" workspace close "$ws" >/dev/null

hook-fail() {
    echo "wtree-relocate: Failed to trigger $1-start hooks for: '$2'" >&2
}

# No TTY here: Unapproved project hooks fail rather than prompt.
# Open the workspace regardless and execute the following once
# per repo to fix:
#    `wt config approvals add`
wt -C "$dest" hook pre-start || hook-fail pre "$dest"

# Reopen as the dialog left it. Open would otherwise relabel it after the
# new directory and always take focus.
open_args=(
    --cwd "$primary"
    --path "$dest"
)
[[ -z "$label" ]] || open_args+=(--label "$label")
[[ $focused == true ]] &&
    open_args+=(--focus) ||
    open_args+=(--no-focus)

"$herdr" worktree open "${open_args[@]}" >/dev/null
wt -C "$dest" hook post-start || hook-fail post "$dest"
