#!/usr/bin/env bash
# vim:set expandtab shiftwidth=4 filetype=bash:
# SPDX-License-Identifier: GPL-3.0-only

#
#
# ~chewygumxx/dotfiles.git
# ::: :/.claude/hooks/lint-on-edit.sh
#
#

# Claude Code PostToolUse hook on Write|Edit. Formats and lints the one file
# just written, using the same tools and exclusions as .husky/pre-commit, so a
# mistake surfaces at the edit rather than at commit time. Also checks what no
# other layer does: sh/bash via shellcheck, zsh via `zsh -n`, and chezmoi
# templates via `chezmoi execute-template`.
#
# Exit status follows the hook contract:
#     0  Clean, or file not checked
#     1  Execution error (non-blocking, user viewable)
#     2  Lint failure: tool output printed to stderr for Claude to fix

set -o errexit -o nounset -o pipefail

# Output is read back by Claude, not a terminal.
export NO_COLOR=1

# chezmoi template functions that read secrets or run commands. A template
# calling any of these, directly or through a .chezmoitemplates include, is
# never executed.
readonly UNSAFE_TEMPLATE_FUNCS='awsSecretsManager|azureKeyVault|bitwarden|dashlane|doppler|ejson|gopass|hcpVaultSecret|keepassxc|keeper|lastpass|onepassword|output|pass|passhole|protonPass|rbw|secret|vault'

fail() {
    printf 'lint-on-edit: %s\n' "$*" >&2
    exit 1
}

command -v jq >/dev/null 2>&1 || fail 'jq not on PATH.'

root=${CLAUDE_PROJECT_DIR:-$(pwd)}
file=$(jq -r '.tool_input.file_path // empty')

# Only regular files inside this repository, outside dependency and VCS dirs.
[[ -n $file && -f $file && ! -L $file ]] || exit 0
[[ $file == "$root"/* ]] || exit 0
rel=${file#"$root"/}
[[ $rel == node_modules/* || $rel == .git/* ]] && exit 0

# chezmoi's symlink_* "source" files hold a plain target path, not content.
name=${rel##*/}
[[ $name == symlink_* ]] && exit 0

cd -- "$root"

report=''
add_failure() {
    report+="$1"$'\n'
}

# Runs a check, recording its output under a heading when it fails.
check() {
    local heading=$1 output
    shift
    if ! output=$("$@" 2>&1); then
        add_failure "--- $heading"$'\n'"$output"
    fi
}

lint_lua() {
    command -v luafmt >/dev/null 2>&1 || return 0
    command -v luacheck >/dev/null 2>&1 || return 0

    check 'luafmt' luafmt --write "$rel"

    # luacheck resolves .luacheckrc relative to --config's directory rather
    # than walking up from the checked file, so find the nearest ancestor.
    local dir
    dir=$(dirname -- "$rel")
    while [[ $dir != . && ! -f $dir/.luacheckrc ]]; do
        dir=$(dirname -- "$dir")
    done
    if [[ -f $dir/.luacheckrc ]]; then
        check 'luacheck' luacheck --no-color --config "$dir/.luacheckrc" "$rel"
    else
        check 'luacheck' luacheck --no-color "$rel"
    fi
}

lint_toml() {
    command -v tombi >/dev/null 2>&1 || return 0
    check 'tombi format' tombi format --offline "$rel"
    check 'tombi lint' tombi lint --error-on-warnings --offline "$rel"
}

lint_json_yaml() {
    command -v bunx >/dev/null 2>&1 || return 0
    check 'prettier' bunx --bun --no-install prettier --write --log-level warn "$rel"
}

# Prints the action text ({{ ... }}) of template $1, newlines folded so
# multi-line actions match as one.
template_actions() {
    tr '\n' ' ' <"$1" | grep -oE '\{\{([^}]|\}[^}])*\}\}' || true
}

# Succeeds when template $1, or any template it includes, calls an unsafe
# function. Includes resolve by name against every .chezmoitemplates dir.
template_is_unsafe() {
    local -A seen=()
    local -a queue=("$1")
    local current include path

    while ((${#queue[@]})); do
        current=${queue[0]}
        queue=("${queue[@]:1}")
        [[ -n ${seen[$current]:-} ]] && continue
        seen[$current]=1

        if template_actions "$current" |
            grep -qE "(^|[^.\$A-Za-z0-9_])($UNSAFE_TEMPLATE_FUNCS)[A-Za-z]*([^A-Za-z0-9_]|\$)"; then
            return 0
        fi

        while IFS= read -r include; do
            while IFS= read -r path; do
                queue+=("$path")
            done < <(find home -path "*/.chezmoitemplates/$include" -type f 2>/dev/null)
        done < <(template_actions "$current" |
            grep -oE '(template|includeTemplate) +"[^"]+"' |
            sed -E 's/.*"([^"]+)"/\1/')
    done
    return 1
}

lint_template() {
    command -v chezmoi >/dev/null 2>&1 || return 0
    if template_is_unsafe "$rel"; then
        printf 'lint-on-edit: skipped %s (calls a secret or command function)\n' "$rel" >&2
        return 0
    fi
    check 'chezmoi execute-template' \
        timeout 30 chezmoi execute-template --source "$root" <"$rel" >/dev/null
}

lint_shell() {
    local shebang
    IFS= read -r shebang <"$rel" || true
    case $shebang in
        '#!'*zsh*)
            check 'zsh -n' zsh -n "$rel"
            ;;
        '#!'*/sh | '#!'*/bash | '#!'*/dash | '#!'*' sh' | '#!'*' bash' | '#!'*' dash')
            command -v shellcheck >/dev/null 2>&1 || return 0
            check 'shellcheck' shellcheck --severity=warning --format=gcc "$rel"
            ;;
    esac
}

case $name in
    *.tmpl) lint_template ;;
    *.lua) lint_lua ;;
    *.toml) lint_toml ;;
    *.json | *.jsonc | *.yaml | *.yml) lint_json_yaml ;;
    *) lint_shell ;;
esac

if [[ -n $report ]]; then
    printf 'lint-on-edit: %s failed checks, fix before continuing:\n%s' "$rel" "$report" >&2
    exit 2
fi
exit 0
