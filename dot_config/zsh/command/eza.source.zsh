# vim: expandtab:shiftwidth=4

#
#
# ~/.config/zsh/command/eza.source.zsh
#
#

[[ -n "$commands[eza]" ]] || return

setopt aliases

alias l="eza --all --oneline --color=always --hyperlink --group-directories-first"
alias ls='l'

# Details
alias la='l --absolute'
alias ll='l --long --header --smart-group --mounts'
alias lll='ll --total-size'	

# Tree ^-^
alias lt="l --tree --git-ignore"
alias llt='ll --tree'
alias lllt='lll --tree'
alias ltd='lt --only-dirs'
