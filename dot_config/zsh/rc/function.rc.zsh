#!/bin/false
# vim: expandtab:shiftwidth=4

#
#
# ~/.config/zsh/rc/function.rc.zsh
#
#

func_dirs=(
    "$zsh_dirs[user_func]"
    "$zsh_dirs[share_func]"
)

for dir in $func_dirs; do
    fpath+="$dir"
    autoload -Uz "$dir"/*(N:t)
done

unset func_dirs dir
