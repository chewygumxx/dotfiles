#!/bin/false
# vim: expandtab:shiftwidth=4

#
#
# ~/.config/zsh/rc/function.rc.zsh
#
#

fpath+=(
    "$zsh_dirs[conf]/func"
)

autoload -Uz "$zsh_dirs[conf]/func"/*(N:t)
