#!/bin/false
# vim: expandtab:shiftwidth=4

#
#
# ~/.config/zsh/rc/util/chezmoi.rc.zsh
#
#

[[ -o interactive      ]] || return
(( $+commands[chezmoi] )) || return

setopt aliases

alias cz="chezmoi"
alias cze="cz edit --watch"

alias cza="cz apply"
alias czr="cz re-add"
alias czf="cz forget"
alias czd="cz destory"

#
# Directory 
#

hash -d cz="$XDG_DATA_HOME/chezmoi/dot_config"
hash -d czroot="$XDG_DATA_HOME/chezmoi"

# 
# Completions
#
comp_file="$zsh_dirs[cache_comp]/_chezmoi"

# Regenerate completions cache if either:
#  - Missing
#  - Older than chezmoi binary
#  - Older than this file
if  [[ ! -f "$comp_file" ]] ||\
    [[ "$comp_file" -ot "$commands[chezmoi]" ]] ||\
    [[ "$comp_file" -ot "${0}" ]]
then
    print "Regenerating chezmoi completion file"
    chezmoi completion zsh >>| "$comp_file"
fi

unset comp_file

# Completions will be available next shell
