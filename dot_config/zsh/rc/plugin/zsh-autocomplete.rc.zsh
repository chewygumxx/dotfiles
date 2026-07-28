# vim:

#
#
# ~/.config/zsh/rc/plugin/zsh-autocomplete.rc.zsh
#
#

slug="marlonrichert/sh-autocomplete"
plugin="${slug##*/}"

if [[ ! -d "$zsh_dirs[plugin]/$plugin" ]]; then
    git clone "https://github.com/$slug.git" "$zsh_dirs[plugin]/$plugin"
fi

source "$zsh_dirs[plugin]/$plugin/$plugin.plugin.zsh" 2>/dev/null
unset plugin slug
