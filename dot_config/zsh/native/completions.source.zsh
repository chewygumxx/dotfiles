# vim:

#
#
# ~/.config/zsh/native/completions.source.zsh
#
#

autoload -Uz compinit
setopt list_types

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$zsh_home[cache]/compcache"

zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands

# {{{ ZLS_COLORS
    typeset -T ZLS_COLORS zls_colors :
    zls_colors=(
        "di=$color[bold];$color[blue]"      # Directory
        "fi=$color[none]"                   # Ordinary file
        "ex=$color[bold];$color[green]"     # Executable

        "so=$color[bold];$color[red]"       # Socket
        "pi=$color[yellow]"                 # Named pipe (FIFO)
        "bd=$color[bold];$color[yellow]"    # Block device
        "cd=$color[bold];$color[yellow]"    # Character device

        "ln=$color[italic];$color[cyan]"    # Symlink
        "or=$color[italic];$color[blink];$color[reverse]$color[red]"   # Broken symlink

        "tc=$color[faint]$color[magenta]"   # Filetype trailing character
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
# }}}
zstyle ":completion:*" list-colors $ZLS_COLORS

zmodload zsh/complist
bindkey -M menuselect '^h' vi-backward-char
bindkey -M menuselect '^k' vi-up-line-or-history
bindkey -M menuselect '^j' vi-down-line-or-history
bindkey -M menuselect '^l' vi-forward-char

_comp_options+=(globdots)

# Save extended_glob state
[[ -o extended_glob ]]; local_extglob=$?
    setopt extended_glob

    COMPDUMP="$zsh_home[cache]/zcompdump"
    # Glob explanation:
    #   N      Return an empty list if nothing found, instead of an error
    #   mh-24  Return files less than 24 hours old.
    if [[ -n $COMPDUMP(Nmh-24) ]]; then
        compinit -C -d  $COMPDUMP
    else
        compinit -d     $COMPDUMP
    fi

# Resume extended_glob state
(( local_extglob )) && unsetopt extended_glob

