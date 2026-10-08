#!/usr/bin/env bash
# vim:set expandtab shiftwidth=4 filetype=bash:
# SPDX-License-Identifier: GPL-3.0-only

#
#
# ~chewygumxx/dotfiles.git
# ::: :/.claude/skills/chezmoi-sandbox/scripts/sandbox-apply.sh
#
#

# Applies this repository's chezmoi source into a throwaway directory instead of
# the real home: own destination, persistent state and cache, scripts excluded.
#
# Usage: sandbox-apply.sh [--in DIR] [chezmoi apply args...] [targets...]
#
#     --in DIR  Reuse an earlier sandbox (keeps its downloaded externals).
#
# Targets may be given as real home paths (~/.config/foo); they are mapped into
# the sandbox. The sandbox root is printed on the last line of stdout.

set -o errexit -o nounset -o pipefail

fail() {
    printf 'sandbox-apply: %s\n' "$*" >&2
    exit 1
}

command -v chezmoi >/dev/null 2>&1 || fail 'chezmoi not on PATH.'

source_dir=$(git -C "$(dirname -- "${BASH_SOURCE[0]}")" rev-parse --show-toplevel) ||
    fail 'Not inside the dotfiles repository.'

sandbox=''
if [[ ${1:-} == --in ]]; then
    [[ -d ${2:-} ]] || fail "--in needs an existing sandbox directory."
    sandbox=$(cd -- "$2" && pwd)
    shift 2
else
    sandbox=$(mktemp -d "${TMPDIR:-/tmp}/chezmoi-sandbox.XXXXXX")
fi
mkdir -p -- "$sandbox/home" "$sandbox/cache"

args=()
for arg in "$@"; do
    case $arg in
        "$HOME") args+=("$sandbox/home") ;;
        "$HOME"/*) args+=("$sandbox/home/${arg#"$HOME"/}") ;;
        "$sandbox/home"/*) args+=("$arg") ;;
        *) args+=("$arg") && continue ;;
    esac
    # chezmoi does not create a target's missing parents in an empty
    # destination, so applying ~/.config/foo alone needs ~/.config first.
    mkdir -p -- "$(dirname -- "${args[-1]}")"
done

flags=(
    --source "$source_dir"
    --destination "$sandbox/home"
    --persistent-state "$sandbox/state.boltdb"
    --cache "$sandbox/cache"
    --exclude=scripts
)

printf 'sandbox-apply: applying %s into %s\n' "$source_dir" "$sandbox/home" >&2
chezmoi apply "${flags[@]}" --no-tty --force "${args[@]}" ||
    fail "chezmoi apply failed; partial result left in $sandbox"

{
    printf 'sandbox-apply: %s files applied.\n' \
        "$(find "$sandbox/home" -type f -o -type l | wc -l)"
    printf 'Follow-up commands need the same flags, e.g.:\n'
    printf '    chezmoi managed --path-style=absolute'
    printf ' %q' "${flags[@]}"
    printf '\nDelete when done: rm -rf %q\n' "$sandbox"
} >&2

printf '%s\n' "$sandbox"
