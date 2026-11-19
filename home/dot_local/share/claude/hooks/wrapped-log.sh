#!/usr/bin/env bash
# vim:set expandtab shiftwidth=4 filetype=bash:
# SPDX-License-Identifier: GPL-3.0-only

#
#
# ~chewygumxx/dotfiles.git
# ::: :/home/dot_config/claude/hooks/wrapped-log.sh
#
#

# Stop hook: append an 80-column copy of Claude's last reply to a log.
# Fails with exit 1, never 2: on Stop, exit 2 forces Claude to continue.

fail() {
    local code=$1
    shift
    echo "wrapped-log hook: $*" >&2

    # Exit 2 is the blocking code (on Stop it forces Claude to continue),
    # so map it to 1; every other non-zero code is a plain notice.
    (( code == 2 )) && code=1
    exit "$code"
}

command -v jq > /dev/null 2>&1 || fail 127 "jq not found in PATH"
command -v prettier > /dev/null 2>&1 || fail 127 "prettier not found in PATH"

input=$(cat)
reply=$(jq -r '.last_assistant_message // empty' <<< "$input") \
    || fail $? "could not parse hook input"
[[ -n $reply ]] || exit 0
session=$(jq -r '.session_id // "unknown"' <<< "$input")

wrapped=$(prettier --stdin-filepath reply.md --log-level warn \
    --prose-wrap always --print-width 80 <<< "$reply") \
    || fail $? "prettier failed"

dir="${XDG_STATE_HOME:-$HOME/.local/state}/claude-wrapped"
mkdir -p "$dir" || fail $? "cannot create $dir"
printf '%s\n\n' "$wrapped" >> "$dir/$session.md" \
    || fail $? "cannot write $dir/$session.md"
