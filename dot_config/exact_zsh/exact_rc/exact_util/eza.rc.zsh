#!/bin/false
# vim: expandtab:shiftwidth=4

# 
# 
# ~/.config/zsh/rc/util/eza.rc.zsh
# 
# 

[[ -o interactive  ]] || return
(( $+commands[eza] )) || return 127

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

setopt aliases

alias l="eza_wrap"
alias ll="l --long"
alias lll='ll --long --total-size --all'

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

function eza_wrap () {
    local -a opts=( "${eza_opts[@]}" )
    local -a args=()
    local -i ignore=1
    local -i long=0

    while (( $# )); do
        case "$1" in
            -u|--unignore) ignore=0; shift;;
            -l|--long)     long+=1;  shift;;
            -*)  opts+=( "$1"     ); shift;;
            *)   args+=( "${1:a}" ); shift;; # Show absolute filepath for --tree
        esac
    done


    (( ignore )) && opts+=( "--ignore-glob" "${(j:|:)eza_ignore_glob}" )

    if   (( long == 1)); then;
        opts+=( "--header" "--mounts" "--no-user")
    elif (( long >= 2)); then;
        opts+=( "--header" "--mounts" "--group" "--smart-group" )
    else
        opts+=( "--no-permissions" "--no-user" "--no-filesize" "--no-time")
    fi

    \command eza "${opts[@]}" "${args[@]}"
}
