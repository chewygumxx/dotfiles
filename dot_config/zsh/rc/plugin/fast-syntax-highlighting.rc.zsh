#!/bin/false
# vim: expandtab:shiftwidth=4

#
#
# ~/.config/zsh/rc/plugin/fast-syntax-highlighting.rc.zsh
#
#

slug="zdharma-continuum/fast-syntax-highlighting"

plugin="${slug##*/}"

if [[ ! -d "$zsh_dirs[plugin]/$plugin" ]]; then
    git clone "https://github.com/$slug.git" "$zsh_dirs[plugin]/$plugin"
fi

source "$zsh_dirs[plugin]/$plugin/$plugin.plugin.zsh"

unset plugin slug
