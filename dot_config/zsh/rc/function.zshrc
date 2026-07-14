#!/bin/false
# vim: expandtab:shiftwidth=4

#
#
# ~/.config/zsh/native/function.zshrc
#
#

local user_function_dir="$ZDOTDIR/functions"

fpath+=(
    "$user_function_dir"
)

autoload -Uz $user_function_dir/*(N:t)
