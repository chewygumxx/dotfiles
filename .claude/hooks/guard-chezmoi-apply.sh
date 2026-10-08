#!/usr/bin/env bash
# vim:set expandtab shiftwidth=4 filetype=bash:
# SPDX-License-Identifier: GPL-3.0-only

#
#
# ~chewygumxx/dotfiles.git
# ::: :/.claude/hooks/guard-chezmoi-apply.sh
#
#

# Claude Code PreToolUse hook on Bash. Blocks chezmoi commands that write to
# the real home (apply, update, destroy, purge, init/edit with --apply) unless
# they are sandboxed with --destination, --persistent-state, --cache and
# --exclude=scripts, or are a --dry-run. --destination alone is not enough:
# chezmoi would still record run_onchange_ script hashes in the real persistent
# state. Scripts must be excluded because some resolve their output from the
# environment ($TERMINFO, $XDG_DATA_HOME) before $CHEZMOI_DEST_DIR, so they
# would write to the real home even from a sandbox.
#
# Exit status follows the hook contract:
#     0  Allowed
#     1  Execution error (non-blocking, user viewable)
#     2  Blocked: reason printed to stderr

set -o errexit -o nounset -o pipefail

command -v jq >/dev/null 2>&1 || {
    echo 'guard-chezmoi-apply: jq not on PATH.' >&2
    exit 1
}

command=$(jq -r '.tool_input.command // empty')
[[ $command == *chezmoi* ]] || exit 0

# Prefixes that may precede the command word in a simple command.
is_prefix() {
    case $1 in
        *=* | sudo | env | command | exec | time | nice | nohup | builtin) return 0 ;;
        *) return 1 ;;
    esac
}

# Checks one simple command (already split into words). Prints the reason and
# returns 1 when it must be blocked.
check_segment() {
    local -a words=("$@")
    local i=0 word prev='' writes=0 apply_flag=0 dry_run=0 dest=0 state=0 cache=0 no_scripts=0

    while ((i < ${#words[@]})) && is_prefix "${words[i]}"; do
        ((i += 1))
    done
    ((i < ${#words[@]})) || return 0

    # `sh -c "..."` and `eval "..."`: check the inner command, unquoted.
    local -a inner=()
    case ${words[i]##*/} in
        sh | bash | zsh | dash)
            for word in "${words[@]:i+1}"; do
                if ((${#inner[@]})) || [[ $word == -*c* && $word != --* ]]; then
                    inner+=("${word//[\"\']/}")
                fi
            done
            inner=("${inner[@]:1}")
            ;;
        eval)
            for word in "${words[@]:i+1}"; do
                inner+=("${word//[\"\']/}")
            done
            ;;
    esac
    if ((${#inner[@]})); then
        check_segment "${inner[@]}"
        return
    fi

    [[ ${words[i]##*/} == chezmoi ]] || return 0

    for word in "${words[@]:i+1}"; do
        case $word in
            apply | update | destroy | purge) writes=1 ;;
            init | edit) writes=2 ;;
            -a | --apply | --apply=true) apply_flag=1 ;;
            -n | --dry-run) dry_run=1 ;;
            -D | -D?* | --destination | --destination=*) dest=1 ;;
            --persistent-state | --persistent-state=*) state=1 ;;
            --cache | --cache=*) cache=1 ;;
            --exclude=*scripts* | -x*scripts*) no_scripts=1 ;;
            *scripts*) [[ $prev == -x || $prev == --exclude ]] && no_scripts=1 ;;
        esac
        prev=$word
    done

    ((writes == 2 && !apply_flag)) && writes=0
    ((writes)) || return 0
    ((dry_run)) && return 0
    ((dest && state && cache && no_scripts)) && return 0

    cat <<'EOF'
This chezmoi command would write to the real home directory or its state.
Sandbox it under a temp dir instead (or add --dry-run):

    tmp=$(mktemp -d)
    chezmoi apply --destination "$tmp/home" \
        --persistent-state "$tmp/state.boltdb" --cache "$tmp/cache" \
        --exclude=scripts [targets...]

Or use the /chezmoi-sandbox skill. Applying to the real home is for the
user to run themselves.
EOF
    return 1
}

# Split on command separators. Quoting is not parsed, so a separator inside a
# quoted string splits early: `bash -c "true; chezmoi apply"` still yields a
# segment led by chezmoi, while a quoted "chezmoi" in a grep or commit message
# never sits in command position.
status=0
while IFS= read -r segment; do
    # Quotes are dropped from each word so a split inside a quoted string
    # (`... "true; chezmoi apply"`) still matches its subcommand.
    read -r -a words <<<"${segment//[\"\']/}"
    ((${#words[@]})) || continue
    if ! reason=$(check_segment "${words[@]}"); then
        printf 'guard-chezmoi-apply: blocked `%s`\n%s\n' "${segment#"${segment%%[![:space:]]*}"}" "$reason" >&2
        status=2
        break
    fi
done < <(printf '%s\n' "$command" | sed -E 's/(\|\||&&|[;|&()`]|\$\()/\n/g')

exit $status
