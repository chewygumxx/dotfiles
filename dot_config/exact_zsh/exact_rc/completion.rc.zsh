#!/bin/false
# vim: expandtab:shiftwidth=4

#
#
# ~/.config/zsh/rc/completion.rc.zsh
#
#

[[ -o interactive ]] || return

fpath+=(
    "$zsh_dirs[share_comp]"
    "$zsh_dirs[user_comp]"
)

() {
    local slug="zsh-users/zsh-completions"
    local plugin="${slug##*/}"

    if [[ ! -d "$zsh_dirs[plugin]/$plugin" ]]; then
        git clone "https://github.com/$slug.git" "$zsh_dirs[plugin]/$plugin"
    fi

    fpath+=( "$zsh_dirs[plugin]/$plugin/src" )
}

autoload -Uz compinit
setopt list_types

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$zsh_dirs[cache_zstylecomp]"

zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands
zstyle ":completion:*" list-colors $ls_colors

zmodload zsh/complist # Must be loaded before compinit call
bindkey -M menuselect '^h' vi-backward-char
bindkey -M menuselect '^k' vi-up-line-or-history
bindkey -M menuselect '^j' vi-down-line-or-history
bindkey -M menuselect '^l' vi-forward-char

_comp_options+=(globdots)

setopt extended_glob
# Glob explanation:
#   N      Return an empty list if nothing found, instead of an error
#   mh-24  Return files less than 24 hours old.
if [[ -n "$zsh_dirs[cache]"(Nmh-24) ]]; then
    compinit -C -d  "${zsh_dirs[cache]}/zcompdump"
else
    compinit -d     "${zsh_dirs[cache]}/zcompdump"
fi
