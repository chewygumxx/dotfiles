#!/bin/false
# vim: expandtab:shiftwidth=4

# 
# 
# ~/.config/zsh/env/zsh_dirs.env.zsh
# 
# 

typeset -A zsh_dirs=(
    [conf]="$XDG_CONFIG_HOME/zsh"

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

init_dirs="$XDG_CACHE_HOME/.zsh_dirs_initialised"
# Re-mkdir zsh directories if either:
#  - Missing
#  - Older than this file
if  ! [[ "$init_dirs" -nt "${0}" ]]; then
    print "Creating zsh directories"
    mkdir -p "${(v)zsh_dirs[@]}"
    touch "$init_dirs"
fi
unset init_dirs
