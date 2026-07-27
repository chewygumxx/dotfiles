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

if [[ ! -d "$ZSH_HOME_DIRS[PLUGIN]/$plugin" ]]; then
    git clone "https://github.com/zsh-users/$plugin.git" \
        "$ZSH_HOME_DIRS[PLUGIN]/$plugin"
fi

fpath+=("$ZSH_HOME_DIRS[PLUGIN]/$plugin/src")

source "$ZSH_HOME_DIRS[PLUGIN]/$plugin/$plugin.plugin.zsh" 2>/dev/null
unset plugin
