#!/bin/false
# vim: expandtab:shiftwidth=4

# 
# 
# ~chewygumxx/dotfiles.git
# ::: :/dot_config/zsh/rc/util/eza.rc.zsh
# 
# 

#
# Zsh source file to prepare interactive utility 'eza'
# Optionally dependent on configurable wrapper function
#

[[ -o interactive  ]] || return
(( $+commands[eza] )) || return

__this_file="${(D)${${(%):-%N}:a}}"


typeset -ga __eza_opts=(
    "--all"
    "--oneline"
    "--group-directories-first"
    "--color=always"
    "--hyperlink"
    "--git"
)
typeset -ga __eza_ignore_glob=(
    "[0-9a-f][0-9a-f]"  # .git/objects/* subdirectories
    ".obsidian"
    ".zettel-notes"
    #".git"
)

setopt aliases

alias l="eza"
alias ll="l --long"
alias lll='ll --long --total-size'

alias ld='l --only-dirs --show-symlinks' # I never use GNU `ld`
alias lld='ll --only-dirs'
alias llld='lll --only-dirs'

alias la="l --unignore"
alias lla="ll --unignore"
alias llla='lll --unignore'

# Tree ^-^
alias lt="l --tree" 
alias llt='ll --tree'
alias lllt='lll --tree'

alias ldt='ld --tree'
alias lldt='lld --tree'
alias llldt='llld --tree --follow-symlinks'
    
alias lat="la --tree" 
alias llat='lla --tree'
alias lllat='llla --tree'

# -----------------
# Wrapper Function
# -----------------

if (( $+functions[$wrapfunc] )); then
fi

unset __this_file
