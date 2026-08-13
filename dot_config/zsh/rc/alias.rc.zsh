#!/bin/false
# vim: expandtab:tabstop=4:shiftwidth=4:tw=0

#
#
# ~/.config/zsh/alias.rc.zsh
#
#

#
# Function file 'func/als' groups aliases
#

local __this_file="${(D)${${(%):-%N}:A}}"

setopt aliases

# Prompt before overwriting
alias cp="cp --interactive"
alias mv="mv --interactive"

# Human readable
alias free='free --mebi'
alias df='df --human-readable'
alias du='du --block-size=1K'

# Show colour and case-insensitive
alias grep='grep --color=auto -i'

# Git
alias ga='git add'
alias gs='git status' # Overwrites 'gs' of ghostscript. Never use it
alias gist='gh gist create'

alias y=yazi

# Synaptic Nexus
alias nex='unalias nex; source "$HOME/doc/synaptic-nexus/nex.rc.zsh"'

# Editor
() {
    (( $+aliases[edit]   )) && unalias edit
    (( $+functions[nvim] )) &&   alias edit="nvim"

    local cmd alias
    for cmd in "${VISUAL%% *}" "${EDITOR%% *}" nvim vim vi; do
        (( $+alias[edit]    )) && break
        (( $+commands[$cmd] )) && alias "edit=\builtin command $cmd"
    done

    for alias in e ed edit v vi vim nvim nivm hx kak nano emacs; do
        alias "$alias=${aliases[edit]}"
    done
}

if (( ! $+aliases[edit] )); then
    print -n -u2 "${__this_file}: [ERROR] "
    print    -u2 "Unable to resolve editor. Editor aliases not set"
fi

if (( $+commands[systemctl] )); then # chewytop
    # WireGuard ProtonVPN
    alias vpnup='sudo wg-quick up protonvpn'
    alias vpndown='sudo wg-quick down protonvpn'
    alias vpnstat='sudo wg show'

    # Package Manager
    alias pacman="yay"
    
    # Fix for bash/zsh completion when executing aliases via sudo
    # https://wiki.archlinux.org/title/Sudo#Passing_aliases
    alias sudo="sudo "
    
    # KDEConnect
    alias kdecon="kdeconnect-cli --device 1396134ad80c4647aa7c6b1f76d823e3"
    alias kdecon-cb="kdecon --send-clipboard"
    
    # Network
    alias impala='sudo impala'
    alias bt="bluetui"
    
    # SQLite
    alias sqlite='sqlite3'

elif [[ -v TERMUX_VERSION ]]; then
    (( $+commands[trash-put] )) && alias del="trash-put"

    # Package Manager
    alias pki="pkg install"
    alias pks="pkg search"
    
    # Clipboard
    alias cb-copy="termux-clipboard-set"
    alias cb-paste="termux-clipboard-get"
else
    print -u2 "${(D)${${(%):-%N}:A}}: Unable to discern whether" \
        "chewytop or chewytele"
    return 1
fi
