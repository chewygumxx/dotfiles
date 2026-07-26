#!/bin/false
# vim: expandtab:shiftwidth=4

#
#
# ~/.config/zsh/rc/function.rc.zsh
#
#

local user_zshfunc_dir="$ZDOTDIR/func"

fpath+=("$user_zshfunc_dir")

autoload -Uz $user_zshfunc_dir/*(N:t)

unset user_zshfunc_dir
