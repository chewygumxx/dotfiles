#!/bin/false
# vim: filetype=sh:expandtab:shiftwidth=4:textwidth=80

#
#
# ~/.config/zsh/command/gtrash.zshrc
#
#

#
# Depends on autoload/fpath accessible zsh files:
# - gtrash
# - rm-notice
#
# https://github.com/umlx5h/gtrash
# https://github.com/umlx5h/gtrash/blob/main/doc/configuration.md
#

[[ -o interactive         ]] || return
[[ -n "$commands[gtrash]" ]] || return

autoload -Uz gtrash rm-notice

alias rm="rm-notice"
alias del="gtrash put"
alias del-undo="gtrash restore-group"
