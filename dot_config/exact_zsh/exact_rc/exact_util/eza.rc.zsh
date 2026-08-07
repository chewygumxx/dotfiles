#!/bin/false
# vim: expandtab:shiftwidth=4

# 
# 
# ~/.config/zsh/rc/util/eza.rc.zsh
# 
# 

[[ -o interactive  ]] || return
(( $+commands[eza] )) || return 127

setopt aliases

# Check if autoloaded zsf function eza_wrap file available
if (( $+functions[eza_wrap] )); then
    typeset -ga eza_{opts,ignore_glob}
    eza_opts=(
        "--all"
        "--long"
        "--git"
        "--color=always"
        "--hyperlink"
        "--group-directories-first"
    )
    eza_ignore_glob=(
        "[0-9a-f][0-9a-f]"  # .git/objects/*
        ".obsidian"
        ".zettel-notes"
        #".git"
    )
    alias l="eza_wrap"
else
    alias l="eza"
fi

alias ll="l --long"
alias lll='ll --long --total-size'

alias la="l --unignore"
alias lla="ll --unignore"
alias llla='lll --unignore'

alias ld='l --only-dirs --show-symlinks' # I never use GNU `ld`
alias lld='ll --only-dirs'
alias llld='lll --only-dirs'

# Tree ^-^
alias lt="l --tree" 
alias llt='ll --tree'
alias lllt='lll --tree'

alias lat="la --tree" 
alias llat='lla --tree'
alias lllat='llla --tree'

alias ldt='ld --tree'
alias lldt='lld --tree'
alias llldt='llld --tree --follow-symlinks'
