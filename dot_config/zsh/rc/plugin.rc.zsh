#!/bin/false
# vim: expandtab:shiftwidth=4

# 
# 
# ~/.config/zsh/rc/plugin.rc.zsh
# 
# 

# Intentionally left set
plugins=(
    "marlonrichert/zsh-autocomplete"
    "zdharma-continuum/fast-syntax-highlighting"
    "zsh-users/zsh-autosuggestions"
    "jeffreytse/zsh-vi-mode"
    "chewygumxx/zsh-als"
)

for slug in $plugins; do
    local plugin="${slug##*/}"

    if [[ ! -d "$zsh_dirs[plugin]/$plugin" ]]; then
        git clone "https://github.com/$slug.git" "$zsh_dirs[plugin]/$plugin"
    fi
    
    if [[ -f "$zsh_dirs[conf]/rc/plugin/$plugin.rc.zsh" ]]; then
        source "$zsh_dirs[conf]/rc/plugin/$plugin.rc.zsh" 2>/dev/null
    fi

    if [[ ! -v PLUGIN_DISABLE ]]; then # Set in above ~zsh/rc/$plugin.ec.zsh
        source "$zsh_dirs[plugin]/$plugin/$plugin.plugin.zsh" 2>/dev/null
    else
        plugins=(${plugins:#$slug})
    fi
    unset PLUGIN_DISABLE
done

unset slug
