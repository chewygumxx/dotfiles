# vim: ft=sh:tabstop=4:shiftwidth=4:expandtab:tw=80

#
#
# ~/.config/zsh/command/chezmoi.source.zsh
#
#

setopt aliases

[[ -n "$commands[chezmoi]" ]] || return

alias cz="chezmoi"
alias cza="cz add"
alias czr="cz re-add"
alias cze="cz edit --watch"
