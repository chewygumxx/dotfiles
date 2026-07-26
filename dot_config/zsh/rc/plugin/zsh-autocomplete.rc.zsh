# vim:

#
#
# ~/.config/zsh/rc/plugin/zsh-autocomplete.rc.zsh
#
#

plugin="zsh-autocomplete"

if [[ ! -d "$ZSH_HOME_DIRS[PLUGIN]/$plugin" ]]; then
    git clone "https://github.com/marlonrichert/$plugin.git" \
        "$ZSH_HOME_DIRS[PLUGIN]/$plugin"
fi

source "$ZSH_HOME_DIRS[PLUGIN]/$plugin/$plugin.plugin.zsh" 2>/dev/null
unset plugin
