#!/bin/false
# vim: expandtab:shiftwidth=4

#
#
# ~/.config/zsh/native/completions.zshrc
#
#

[[ -o interactive ]] || return

fpath+=(
    "$XDG_DATA_HOME/zsh/site-functions"
    "$XDG_CONFIG_HOME/zsh/completions"
)

autoload -Uz compinit
setopt list_types

COMPCACHE="$XDG_CACHE_HOME/zsh/compcache"

# TODO(@chewygumxx): (Priority: Low) cgxx_todo_zsh_first_install
# Compose a first-time zsh installaiton script to render these redundant.
# (Directory creation is already a core functionality of chezmoi.)
# (Will likely also require bespoke debugging tooling :/)
mkdir -p "$COMPCACHE"

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$COMPCACHE"
unset COMPCACHE

zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands

function __set_zls_colors () {
    autoload -Uz colors && colors

    typeset -Tg ZLS_COLORS zls_colors ':'
    zls_colors=(
        "di=$color[bold];$color[blue]"      # Directory
        "fi=$color[none]"                   # Ordinary file
        "ex=$color[bold];$color[green]"     # Executable
    
        "so=$color[bold];$color[red]"       # Socket
        "pi=$color[yellow]"                 # Named pipe (FIFO)
        "bd=$color[bold];$color[yellow]"    # Block device
        "cd=$color[bold];$color[yellow]"    # Character device
    
        "ln=$color[italic];$color[cyan]"    # Symlink
        "or=$color[italic];$color[blink];$color[reverse];$color[red]"   # Broken symlink
    
        "tc=$color[faint];$color[magenta]"   # Filetype trailing character
    )
    
    # Archive
    for ext in "7z" "gz" "rar" "tar" "zip"; do
        zls_colors+=("*.$ext=$color[red]")
    done
    
    # Audio
    for ext in "flac" "m4a" "mka" "mp2" "mp3" "ogg"; do
        zls_colors+=("*.$ext=$color[italic];$color[magenta]")
    done
    
    # Document
    for ext in "pdf" "doc" "docx"; do
        zls_colors+=("*.$ext=$color[cyan]")
    done
    
    # Image
    for ext in "avif" "bmp" "gif" "ico" "jfif" "jpg" "jpeg" "png" "svg" "tif" "tiff" "webp" "xcf"; do
        zls_colors+=("*.$ext=$color[magenta]")
    done
    
    # Source
    for ext in "css" "js" "lua" "py" "rs" "sql" "styl" "tsx" "zsh"; do
        zls_colors+=("*.$ext=$color[yellow]")
    done
    
    # Video
    for ext in "avi" "m4v" "mkv" "mov" "mp4" "mpeg" "mpg" "webm"; do
        zls_colors+=("*.$ext=$color[bold];$color[magenta]")
    done
    zstyle ":completion:*" list-colors $zls_colors
}; __set_zls_colors; unset -f __set_zls_colors

zmodload zsh/complist # Must be loaded before compinit call
bindkey -M menuselect '^h' vi-backward-char
bindkey -M menuselect '^k' vi-up-line-or-history
bindkey -M menuselect '^j' vi-down-line-or-history
bindkey -M menuselect '^l' vi-forward-char

_comp_options+=(globdots)


COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump"

# TODO(@chewygumxx): (Priority: Low) cgxx_todo_zsh_first_install
mkdir -p "${COMPDUMP:h}"

setopt extended_glob
# Glob explanation:
#   N      Return an empty list if nothing found, instead of an error
#   mh-24  Return files less than 24 hours old.
if [[ -n $COMPDUMP(Nmh-24) ]]; then
    compinit -C -d  $COMPDUMP
else
    compinit -d     $COMPDUMP
fi
unset COMPDUMP
