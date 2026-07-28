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

alias cza="cz add --verbose --propmt --new"
alias czr="cz re-add"
alias czf="cz forget"
alias czd="cz destory"

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
