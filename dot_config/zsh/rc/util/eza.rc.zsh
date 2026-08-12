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


# -----------------
# Wrapper Function
# -----------------

typeset -g __eza_wrapper="eza-wrapper"
if [[ -v __eza_wrapper ]] && (( ! $+functions[$__eza_wrapper] )); then
    print -u2 "${__this_file}: Unable to resolve eza wrapper function: $__eza_wrapper"
    print -u2 "${__this_file}: To disable this message, unset variable '__eza_wrapper' within ${__this_file}"
    unset __eza_wrapper
fi


# --------
# Options
# --------

typeset -ga __eza_opts=(
    "--all"
    "--long"
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

# --------
# Aliases
# --------

setopt aliases

# Standard
alias l="${__eza_wrapper:-"eza ${__eza_opts} --ignore-glob ${(qqj:|:)__eza_ignore_glob}"}"
alias ll="l --long"
alias lll='ll --long --total-size'

alias lt="l --tree" 
alias llt='ll --tree'
alias lllt='lll --tree'

# Directories
alias ld='l --only-dirs --show-symlinks' # I never use GNU `ld`
alias lld='ll --only-dirs'
alias llld='lll --only-dirs'

alias ldt='ld --tree'
alias lldt='lld --tree'
alias llldt='llld --tree --follow-symlinks'
    
# Unignore (wrapper exclusive)
if [[ -v __eza_wrapper ]]; then
    alias la="l --unignore"
    alias lla="ll --unignore"
    alias llla='lll --unignore'

    alias lat="la --tree" 
    alias llat='lla --tree'
    alias lllat='llla --tree'
fi
