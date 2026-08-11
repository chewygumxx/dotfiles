#!/bin/false
# vim: expandtab:shiftwidth=4

# 
# 
# ~/.config/zsh/rc/directory.rc.zsh
# 
# 

# Named directories variants of below are also set in /rc/util/chezmoi.rc.zsh
hash -d hypr="$XDG_CONFIG_HOME/hypr"
hash -d nvim="$XDG_CONFIG_HOME/nvim/lua"
hash -d wezt="$XDG_CONFIG_HOME/wezterm"
hash -d yazi="$XDG_CONFIG_HOME/yazi"
hash -d zsh="$ZDOTDIR"

if (( $+commands[systemctl] )); then
    hash -d ff="$HOME/net/firefox"

elif [[ -v TERMUX_VERSION ]]; then
    hash -d pref="$PREFIX"
    hash -d cgxx="/storage/emulated/0/_chewygumxx"

fi
