#!/bin/false
# vim:set expandtab shiftwidth=4 filetype=zsh:
# SPDX-License-Identifier: GPL-3.0-only

#
#
# ~chewygumxx/dotfiles.git
# ::: :/home/dot_config/zsh/exact_env/mise.env.zsh
#
#

[[ -o interactive ]] && return # util/mise.rc.zsh handles interactive
(($+commands[mise])) || return

path=(
    "$HOME/.local/share/mise/shims"
    $path
)
