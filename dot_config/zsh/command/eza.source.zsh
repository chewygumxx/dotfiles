# vim: ft=zsh:tabstop=4:shiftwidth=4:expandtab:tw=80

#
#
# ~/.config/zsh/command/eza.source.sh
#
#

# Aliases must be enabled before sourcing
#setopt aliases

command -v eza &>/dev/null || return

__opts_general=(
    "--all"
    "--group-directories-first"
    "--oneline"
    "--color=always"
    "--hyperlink"
)
alias l="eza $(printf '%s ' "${__opts_general[@]}")"
unset __opts_general
alias ls='l'

# Details
alias la='l --absolute'
alias ll='l --long --header --smart-group --mounts'
alias lll='ll --total-size'	

# Tree ^-^
alias lt='l --tree'
alias llt='ll --tree'
alias lllt='lll --tree'
alias ltd='lt --only-dirs'

