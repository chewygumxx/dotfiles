#!/bin/false
# vim: expandtab:shiftwidth=4

# 
# 
# ~/.config/zsh/env/directory.env.zsh
# 
# 

for xdg in XDG_RUNTIME_DIR XDG_{DATA,CACHE,CONFIG,STATE}_HOME; do
    if   [[ ! -v $xdg ]]; then
        print -u2 "$xdg has not been set"
        xdg_fail=1
    elif [[ ! -d "${(P)xdg}" ]]; then
        print -u2 "$xdg directory does not exist: ${(P)xdg}"
        xdg_fail=1
    fi
done
if (( xdg_fail )); then return 1 fi

typeset -A zsh_dirs=(
    [user]="$XDG_CONFIG_HOME/zsh"
    [user_comp]="$XDG_CONFIG_HOME/zsh/comp"
    [user_func]="$XDG_CONFIG_HOME/zsh/func"
    [user_env]="$XDG_CONFIG_HOME/zsh/env"
    [user_rc]="$XDG_CONFIG_HOME/zsh/rc"

    [cache]="$XDG_CACHE_HOME/zsh"
    [cache_comp]="$XDG_CACHE_HOME/zsh/completions"
    [cache_init]="$XDG_CACHE_HOME/zsh/init"  # Generated source files of utils
    [cache_zstylecomp]="$XDG_CACHE_HOME/zsh/zstylecomp"
    [cache_zvm]="$XDG_CACHE_HOME/zsh/zsh-vi-mode" # Plugin tempfiles

    [share]="$XDG_DATA_HOME/zsh"
    [share_func]="$XDG_DATA_HOME/zsh/functions"
    [share_comp]="$XDG_DATA_HOME/zsh/completions"
    [plugin]="$XDG_DATA_HOME/zsh/plugins"

    [state]="$XDG_STATE_HOME/zsh"
)

zsh_mkdir="$XDG_CACHE_HOME/.zsh_mkdir"
# Re-mkdir zsh directories if either:
#  - Missing
#  - Older than this file
if  [[ ! -f "$zsh_mkdir" || "$zsh_mkdir" -ot "${0}" ]]
then
    print "Creating zsh directories"
    mkdir -p "${(v)zsh_dirs[@]}"
    touch "$zsh_mkdir"
fi
unset zsh_mkdir

