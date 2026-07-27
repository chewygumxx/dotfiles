#!/bin/false
# vim: expandtab:shiftwidth=4

#
#
# ~/.config/zsh/rc/function.rc.zsh
#
#

fpath+=("$ZDOTDIR/func")

autoload -Uz "$ZDOTDIR/func"/*(N:t)
