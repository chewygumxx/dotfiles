#!/bin/false
# vim: expandtab:shiftwidth=4

#
#
# ~/.config/zsh/native/function.zshrc
#
#

local user_zshfunc_dir="$ZDOTDIR/functions"

fpath+=("$user_zshfunc_dir")

autoload -Uz $user_zshfunc_dir/*(N:t)

unset user_zshfunc_dir
