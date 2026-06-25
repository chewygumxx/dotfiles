# vim: filetype=sh:expandtab:shiftwidth=4:textwidth=80

#
#
# ~/.config/zsh/command/gtrash.source.sh
#
#

#
# https://github.com/umlx5h/gtrash
# https://github.com/umlx5h/gtrash/blob/main/doc/configuration.md
#

[[ -n "$commands[gtrash]" ]] || return

# {{{ ANSI Escape Array
declare -A cl
cl=(
# None
 [n]=$'\e[0m'

# Standard        
 [blk]=$'\e[0;30m' # Black   
 [red]=$'\e[0;31m' # Red     
 [grn]=$'\e[0;32m' # Green   
 [ylw]=$'\e[0;33m' # Yellow  
 [blu]=$'\e[0;34m' # Blue    
 [mag]=$'\e[0;35m'  [MAG]=$'\e[1;35m' # Magenta 
 [cyn]=$'\e[0;36m' # Cyan    
 [wht]=$'\e[0;37m' # White   
)
# }}}

# Full path of home trash directory
#
# Default is what the XDG Trash Specification defines, either:
#   - "$XDG_DATA_HOME/Trash"
#   - "$HOME/.local/share/Trash"
export GTRASH_HOME_TRASH_DIR=$XDG_DATA_HOME/Trash 

# Whether to always utilise home trash directory.
# If true, disposed files of external media are first copied to home trash
# directory before their remote deletion.
#
# Default: "false"
export GTRASH_ONLY_HOME_TRASH="false"

# Whether to utilise home trash directory in the event trash directory of
# external media is unavailable.
#
# Default: "false"
export GTRASH_HOME_TRASH_FALLBACK_COPY="true"

# Whether `gtrash put` should emulate `rm` and enforce recursive CLI options
# including `-r`, `--recursive`, `-R`, and `-d`.
# Can also be set with `--rm-mode`.
# 
# Default: "false"
export GTRASH_PUT_RM_MODE="false"

function rm() {
    __echo_rm_redirect=(
        "$cl[grn]gtrash $cl[n]is installed, try the $cl[blu]alias "
        "$cl[grn]del$cl[ylw]='$cl[blu]gtrash $cl[MAG]put$cl[ylw]'"
        $'\n'
    )
    printf "%s" "${__echo_rm_redirect[@]}"
    unset __echo_rm_redirect
}

alias del="gtrash put"
alias del-undo="gtrash restore-group"
