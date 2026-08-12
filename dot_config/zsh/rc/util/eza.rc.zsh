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
# Check if zsh wrapper function available

alias l="eza"
alias ll="l --long"
alias lll='ll --long --total-size'

alias ld='l --only-dirs --show-symlinks' # I never use GNU `ld`
alias lld='ll --only-dirs'
alias llld='lll --only-dirs'

# Tree ^-^
alias lt="l --tree" 
alias llt='ll --tree'
alias lllt='lll --tree'

alias ldt='ld --tree'
alias lldt='lld --tree'
alias llldt='llld --tree --follow-symlinks'


# -----------------
# Wrapper Function
# -----------------

() {
    local wrapfunc="eza_wrap"
    if (( $+functions[$wrapfunc] )); then
        typeset -ga eza_{opts,ignore_glob}
        eza_opts=(
            "--all"
            "--group-directories-first"
            "--color=always"
            "--hyperlink"
            "--git"
        )
        eza_ignore_glob=(
            "[0-9a-f][0-9a-f]"  # .git/objects/* subdirectories
            ".obsidian"
            ".zettel-notes"
            #".git"
        )

        alias l="$wrapfunc"

        alias la="l --unignore"
        alias lla="ll --unignore"
        alias llla='lll --unignore'
        
        alias lat="la --tree" 
        alias llat='lla --tree'
        alias lllat='llla --tree'
    fi
}
