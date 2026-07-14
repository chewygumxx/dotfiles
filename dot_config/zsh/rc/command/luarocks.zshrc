#!/bin/false
# vim: expandtab:shiftwidth=4

#
#
# ~/.config/zsh/command/luarocks.zshrc
#
#

#
# https://luarocks.org/docs
# https://github.com/luarocks/luarocks/blob/main/docs/index.md
#

[[ -o interactive           ]] || return
[[ -n "$commands[luarocks]" ]] || return

local __this_file="$0"
local __lua_version="5.1"

function __init_luarocks() {
    local __luarocks_cache="$XDG_CACHE_HOME/luarocks/${__lua_version:-"5.1"}.init.zsh"

    # Regenerate init cache if either:
    #  - Missing
    #  - Older than binary
    #  - Older than this file
    if  [[ ! -s "$__luarocks_cache" ]] ||
        [[ "$__luarocks_cache" -ot "$commands[luarocks]" ]] ||
        [[ "$__luarocks_cache" -ot "$__this_file" ]]
    then
        echo "Regenerating luarocks source cache"

        mkdir -p "${__luarocks_cache:h}"
        luarocks --lua-version "$__lua_version" path --bin >| "$__luarocks_cache"
    fi

    source "$__luarocks_cache"
}; __init_luarocks; unset -f __init_luarocks

unset __this_file __lua_version
