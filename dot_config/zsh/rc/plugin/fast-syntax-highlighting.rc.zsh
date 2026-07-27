# vim:

#
#
# ~/.config/zsh/rc/plugin/fast-syntax-highlighting.rc.zsh
#
#

plugin="fast-syntax-highlighting"

if [[ ! -d "$zsh_dirs[plugin]/$plugin" ]]; then
    git clone "https://github.com/zdharma-continuum/$plugin.git" \
        "$zsh_dirs[plugin]/$plugin"
fi

source "$zsh_dirs[plugin]/$plugin/$plugin.plugin.zsh" 2>/dev/null
unset plugin
