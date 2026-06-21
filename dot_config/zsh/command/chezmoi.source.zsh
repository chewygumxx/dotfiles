# vim: ft=sh:tabstop=4:shiftwidth=4:expandtab:tw=80

#
#
# ~/.config/zsh/command/chezmoi.source.zsh
#
#

# Aliases must be enabled before sourcing
#setopt aliases

command -v chezmoi &>/dev/null || return

alias cz="chezmoi"
alias cza="cz add"
alias cze="cz edit --watch"
alias czf="cz forget"
alias czr="cz re-add"

export CHEZMOI_SOURCE="${XDG_DATA_HOME}/chezmoi"
