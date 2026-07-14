# vim: expandtab:shiftwidth=4:textwidth=80

#
#
# ~/.config/zsh/command/zoxide.zshrc
#
#

#
# Fuzzy frecency directory jumper
# https://github.com/ajeetdsouza/zoxide
# https://github.com/ajeetdsouza/zoxide#configuration
#

[[ -o interactive ]] || return
[[ -n "$commands[zoxide]" ]] || return

local __this_file="$0"

function __init_zoxide () {
    local _zo_exclude_dirs=(
        "$HOME"
    )
    export _ZO_EXCLUDE_DIRS=${(j|:|)_zo_exclude_dirs}

    local _zo_fzf_opts=(
        "$FZF_DEFAULT_OPTS"
        --preview-window=right,wrap
        --reverse
        --border
        --height 40%
        --scheme=history
    
        "--preview='eza --oneline --color=always --all --group-directories-first --tree --level 1 {2}'"
        --with-nth 2
    )
    export _ZO_FZF_OPTS=${(j: :)_zo_fzf_opts}

    local __zoxide_prefix="cd"
    local __zoxide_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zoxide/${__zoxide_prefix:-"z"}.init.zsh"

    # Regenerate init cache if:
    #  - Missing
    #  - Older than binary
    #  - Older than this file
    if  [[ ! -f "$__zoxide_cache" ]] ||\
        [[ "$__zoxide_cache" -ot "$commands[zoxide]" ]] ||\
        [[ "$__zoxide_cache" -ot "$__this_file" ]]
    then
        echo "Regenerating zoxide source cache"

        mkdir -p "${__zoxide_cache:h}"
        zoxide init zsh --cmd "${__zoxide_prefix:-"z"}" --hook pwd >| "$__zoxide_cache"
    fi

    source "$__zoxide_cache"
}; __init_zoxide; unset -f __init_zoxide

unset __this_file
