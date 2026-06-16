# vim: filetype=sh:expandtab:shiftwidth=4:tabstop=4:textwidth=80

#
#
# ~/.config/zsh/command/gtrash.source.zsh
#
#

#
# https://github.com/umlx5h/gtrash
# https://github.com/umlx5h/gtrash/blob/main/doc/configuration.md
#

if ! command -v gtrash &>/dev/null; then
    return
fi

function gtrash() {
    # Full path of home trash directory
    #   Default is what the XDG Trash Specification defines, either:
    #     - "$XDG_DATA_HOME/Trash"
    #     - "$HOME/.local/share/Trash"
    GTRASH_HOME_TRASH_DIR=$XDG_DATA_HOME/Trash 
    
    # Whether to always utilise home trash directory. Disposed files of external
    # media are first copied to home trash directory before remote deletion.
    #   Default: "false"
    GTRASH_ONLY_HOME_TRASH="false"
    
    # Whether to utilise home trash directory in the event trash directory of
    # external media is unavailable.
    #   Default: "false"
    GTRASH_HOME_TRASH_FALLBACK_COPY="true"
    
    # Whether `gtrash put` should emulate `rm` and respect recursive CLI options
    # including `-r`, `--recursive`, `-R`, and `-d`. Can also be set with 
    # `--rm-mode`.
    #   Default: "false"
    GTRASH_PUT_RM_MODE="false"

    /usr/bin/gtrash $@
}

alias rm="echo -e \"\e[0;32mgtrash \e[0mis installed, try the \e[0;34malias \e[0;32mdel\e[0;33m='\e[0;32mgtrash \e[0;35mput\e[0;33m'\"; false"

alias del="gtrash put"
alias delete="del"

alias del-peek="gtrash summary"
alias del-find="gtrash find"
alias del-grab="gtrash restore"
alias del-empty="gtrash find --rm"
