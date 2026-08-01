#!/bin/false
# vim: expandtab:shiftwidth=4

# 
# 
# ~/.config/zsh/rc/ls_colors.rc.zsh
# 
# 

#
# Provides for `rc/completion.rc.zsh` and `rc/util/eza.rc.zsh`
#

autoload -Uz colors && colors

typeset -Tg LS_COLORS ls_colors ':'
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
for ext in "7z" "gz" "rar" "tar" "zip" "xz"; do
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
