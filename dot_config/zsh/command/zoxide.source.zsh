# vim: expandtab:shiftwidth=4:textwidth=80

#
#
# ~/.config/zsh/command/zoxide.source.zsh
#
#

#
# Fuzzy frecency directory jumper
# https://github.com/ajeetdsouza/zoxide
#

[[ -o interactive ]] || return
[[ -n "$commands[zoxide]" ]] || return

function __zoxide_init () {
    # https://github.com/ajeetdsouza/zoxide#environment-variables
    local _ZO_DATA_DIR=${XDG_DATA_HOME:-"$HOME/.local/share"}
    local _ZO_ECHO=0
    local _ZO_EXCLUDE_DIRS="$HOME"

    local __zoxide_prefix="cd"
    local __zoxide_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zoxide/${__zoxide_prefix:-"z"}.init.zsh"

    # Regenerate init cache if missing or older than binary
    if  [[ ! -f "$__zoxide_cache" ]] ||\
        [[ "$commands[zoxide]" -nt "$__zoxide_cache" ]]
    then
        mkdir -p "${__zoxide_cache%/*}"
        zoxide init zsh --cmd "${__zoxide_prefix:-"z"}" --hook pwd >| "$__zoxide_cache"
    fi

    source "$__zoxide_cache"
}; __zoxide_init; unset __zoxide_init
