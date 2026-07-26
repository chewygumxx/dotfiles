#!/bin/false
# vim: expandtab:shiftwidth=4

#
#
# ~/.config/zsh/command/chezmoi.zshrc
#
#

[[ -o interactive          ]] || return
[[ -n "$commands[chezmoi]" ]] || return

setopt aliases

alias cz="chezmoi"
alias cza="cz add"
alias czr="cz re-add"
alias cze="cz edit --watch"
