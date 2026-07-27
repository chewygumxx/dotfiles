# vim:

#
#
# ~/.config/zsh/rc/plugin/zsh-completions.rc.zsh
#
#

#
# To be called before compinit
#

plugin="zsh-completions"

if [[ ! -d "$zsh_dirs[plugin]/$plugin" ]]; then
    git clone "https://github.com/zsh-users/$plugin.git" \
        "$zsh_dirs[plugin]/$plugin"
fi

fpath+=("$zsh_dirs[plugin]/$plugin")

source "$zsh_dirs[plugin]/$plugin/$plugin.plugin.zsh" 2>/dev/null
unset plugin
