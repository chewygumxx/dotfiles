#!/bin/false
# vim: expandtab:shiftwidth=4:filetype=zsh:

#
#
# ~chewygumxx/dotfiles.git
# ::: :/dot_config/zsh/util/gtrash.rc.zsh
#
#

#
# Zsh source file to prepare interactive utility 'eza'.
# Optionally dependent on configurable wrapper and rm-notice function.
#
# https://github.com/umlx5h/gtrash
# https://github.com/umlx5h/gtrash/blob/main/doc/configuration.md
#

[[ -o interactive     ]] || return
(( $+commands[gtrash] )) || return


# -----------------
# Validate Wrapper
# -----------------

if (( ! $+functions[gtrash] )); then
    print -u2 -n "${(D)${${(%):-%N}:a}}: [WARN] "
    print -u2    "Unable to resolve gtrash wrapper function"
fi


# ------
# Alias
# ------

alias del="gtrash put"
alias del-undo="gtrash restore-group"

alias rm="rm-disable"
