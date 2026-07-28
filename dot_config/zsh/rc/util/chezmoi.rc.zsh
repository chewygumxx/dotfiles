#!/bin/false
# vim: expandtab:shiftwidth=4

#
#
# ~/.config/zsh/rc/util/chezmoi.rc.zsh
#
#

[[ -o interactive      ]] || return
(( $+commands[chezmoi] )) || return

setopt aliases

alias cz="chezmoi"
alias cze="cz edit --watch"

alias cza="cz add --verbose --new"
alias czr="cz re-add"
alias czf="cz forget"
alias czd="cz destory"

#
# Directory 
#

#$hash -d cz="$XDG_DATA_HOME/chezmoi"
#$hash -d cz_zsh="$XDG_DATA_HOME/chezmoi/dot_config/zsh"
#$hash -d cz_nvim="$XDG_DATA_HOME/chezmoi/dot_config/nvim/lua"
#$hash -d cz_yazi="$XDG_DATA_HOME/chezmoi/dot_config/yazi"

function zsh_dir_fn_chezmoi () {
    emulate -L zsh
    setopt extended_glob

    local -a match mbeing mend
    case $1 in
        d)
            for dir in "$XDG_DATA_HOME/chezmoi/"{dot_{config,local}/,}; do
                if [[ $2 = (#b)$dir/([^/]##)* ]]; then
                    reply=("cz:$match[1]")
                    return 0
                fi
            done
        ;;
        n)
            if [[ $2 = (#b)cz:(?*) ]]; then
                for dir in "$XDG_DATA_HOME/chezmoi/"{dot_{config,local}/,}$match[1]; do
                    if [[ -d "$dir" ]]; then
                        reply=( "$dir" )
                        return 0
                    fi
                done
            fi
        ;;
        c) ;;
    esac
    return 1
}; zsh_directory_name_functions+=(zsh_dir_fn_chezmoi)

# 
# Completions
#
comp_file="$zsh_dirs[cache_comp]/_chezmoi"

# Regenerate completions cache if either:
#  - Missing
#  - Older than chezmoi binary
#  - Older than this file
if  [[ ! -f "$comp_file" ]] ||\
    [[ "$comp_file" -ot "$commands[chezmoi]" ]] ||\
    [[ "$comp_file" -ot "${0}" ]]
then
    print "Regenerating chezmoi completion file"
    chezmoi completion zsh >>| "$comp_file"
fi

unset comp_file

# Completions will be available next shell
