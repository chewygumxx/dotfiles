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
# worktree.created handler: move a checkout made by herdr's native dialog to
# worktrunk's worktree-path, then run the create hooks the dialog skipped.
# Output lands in `herdr plugin log list`.
#

set -euo pipefail

herdr=${HERDR_BIN_PATH:-herdr}

# Payload (herdr 0.9.5), trimmed:
#   {"event":"worktree_created","data":{
#    "workspace":{"label":…,"focused":…,"worktree":{"repo_root":…}},
#    "worktree":{"path":…,"branch":…,"open_workspace_id":…}}}
# herdr runs this with HERDR_SOCKET_PATH set, so the herdr calls below reach
# the session that fired the event.
{
    read -r src
    read -r branch
    read -r ws
    read -r primary
    read -r label
    read -r focused
} < <(jq -r '.data
    | .worktree.path // "", .worktree.branch // "",
      .worktree.open_workspace_id // "", .workspace.worktree.repo_root // "",
      .workspace.label // "", .workspace.focused // false' \
    <<<"${HERDR_PLUGIN_EVENT_JSON:-"{}"}")
# Detached checkouts have no branch for worktrunk to template a path from
[[ -n $src && -d $src && -n $branch && -n $primary ]] || exit 0

# Empty when the checkout already sits at the template path: created by the
# herdr-worktrunk plugin, or this event firing again after the reopen below.
dest=$(wt -C "$src" step relocate "$branch" --dry-run --format=json \
    | jq -r '.entries[0].to // empty')
[[ -n $dest ]] || exit 0

# relocate doesn't create the destination's parent (e.g. <repo>/.wtree)
mkdir -p "$(dirname "$dest")"
wt -C "$primary" step relocate "$branch"

# The workspace's shells sit in a directory that no longer exists
[[ -z $ws ]] || "$herdr" workspace close "$ws" >/dev/null

# No TTY here: unapproved project hooks fail rather than prompt. Open the
# workspace regardless; `wt config approvals add` once per repo fixes it.
wt -C "$dest" hook pre-start \
    || echo "wtree-relocate: pre-start hooks failed in $dest" >&2

# Reopen as the dialog left it; open would otherwise relabel it after the
# new directory and always take focus
open_args=(--cwd "$primary" --path "$dest")
[[ -z $label ]] || open_args+=(--label "$label")
if [[ $focused == true ]]; then
    open_args+=(--focus)
else
    open_args+=(--no-focus)
fi
"$herdr" worktree open "${open_args[@]}" >/dev/null
wt -C "$dest" hook post-start \
    || echo "wtree-relocate: post-start hooks failed in $dest" >&2
