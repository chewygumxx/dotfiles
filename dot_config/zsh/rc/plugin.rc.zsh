#!/bin/false
# vim: expandtab:shiftwidth=4

# 
# 
# ~/.config/zsh/rc/plugin.rc.zsh
# 
# 

plugin_slugs=(
    "marlonrichert/zsh-autocomplete"
    "zdharma-continuum/fast-syntax-highlighting"
    "zsh-users/zsh-autosuggestions"
    "jeffreytse/zsh-vi-mode"
)

for slug in $plugin_slugs; do
    local plugin="${slug##*/}"

    if [[ -f "$zsh_dirs[user_rc]/plugin/$plugin.rc.zsh" ]]; then
        source "$zsh_dirs[user_rc]/plugin/$plugin.rc.zsh" 2>/dev/null
    fi

    if [[ ! -d "$zsh_dirs[plugin]/$plugin" ]]; then
        git clone "https://github.com/$slug.git" "$zsh_dirs[plugin]/$plugin"
    fi
    
    source "$zsh_dirs[plugin]/$plugin/$plugin.plugin.zsh" 2>/dev/null
done

unset plugin_slugs slug
