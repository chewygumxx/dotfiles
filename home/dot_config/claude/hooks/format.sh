#!/usr/bin/env bash
# vim:set expandtab shiftwidth=4 filetype=bash:
# SPDX-License-Identifier: GPL-3.0-only

#
#
# ~chewygumxx/dotfiles.git
# ::: :/home/dot_config/claude/hooks/format.sh
#
#

# PostToolUse hook: hard-wrap Markdown files at 80 columns.
# Claude Code surfaces only the first line of stderr, so every error
# message below is a single line.

fail() {
    local code=$1
    shift
    echo "format hook: $*" >&2

    # Exit 2 is the blocking code (on Stop it forces Claude to continue),
    # so map it to 1; every other non-zero code is a plain notice.
    (( code == 2 )) && code=1
    exit "$code"
}

command -v jq > /dev/null 2>&1 || fail $? "jq not found in PATH"

file=$(jq -r '.tool_input.file_path // empty') \
    || fail $? "could not parse hook input"
[[ $file == *.md && -f $file ]] || exit 0

command -v prettier > /dev/null 2>&1 || fail $? "prettier not found in PATH"

prettier --log-level warn --prose-wrap always --print-width 80 \
    --write "$file" || fail $? "prettier failed on $file"

