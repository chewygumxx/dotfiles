#!/bin/false
# vim: expandtab:shiftwidth=4

#
#
# ~/.config/zsh/rc/util/luarocks.rc.zsh
#
#

#
# https://luarocks.org/docs
# https://github.com/luarocks/luarocks/blob/main/docs/index.md
#

[[ -o interactive       ]] || return
(( $+commands[luarocks] )) || return

local __this_file="$0"

function __init_luarocks() {
    local __lua_version="5.1"
    local __luarocks_cache="$zsh_dirs[gensource]/luarocks.init.zsh"

    # regenerate init cache if either:
    #  - missing
    #  - older than binary
    #  - older than this file
    if  [[ ! -s "$__luarocks_cache" ]] ||
        [[ "$__luarocks_cache" -ot "$commands[luarocks]" ]] ||
        [[ "$__luarocks_cache" -ot "$__this_file" ]]
    then
        echo "Regenerating luarocks source cache"
        luarocks --lua-version "$__lua_version" path --bin >| "$__luarocks_cache"
    fi

    source "$__luarocks_cache"
}; __init_luarocks; unset -f __init_luarocks

unset __this_file
