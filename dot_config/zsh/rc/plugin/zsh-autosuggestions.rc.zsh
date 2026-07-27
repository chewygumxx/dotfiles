# vim:

#
#
# ~/.config/zsh/rc/plugin/zsh-autosuggestions.rc.zsh
#
#

plugin="zsh-autosuggestions"

if [[ ! -d "$zsh_dirs[plugin]/$plugin" ]]; then
    git clone "https://github.com/zsh-users/$plugin.git" \
        "$zsh_dirs[plugin]/$plugin"
fi

source "$zsh_dirs[plugin]/$plugin/$plugin.plugin.zsh" 2>/dev/null
unset plugin
