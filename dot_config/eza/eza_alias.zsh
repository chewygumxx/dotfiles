# vim:ft=sh:tabstop=4:shiftwidth=4:noexpandtab:tw=0

#
#
# ~/.config/eza/eza_alias.zsh
#
#

setopt aliases

# List files of cwd
alias l='eza --oneline --all --group-directories-first'
alias ls='l'

# Show details
alias la='l --absolute'
alias ll='l --long --header'
alias lll='ll --total-size'	

# Tree
alias lt='l --tree'
alias llt='ll --tree'
alias lllt='lll --tree'
alias ltd='lt --only-dirs'
