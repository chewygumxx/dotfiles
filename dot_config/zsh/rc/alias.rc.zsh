# vim: expandtab:tabstop=4:shiftwidth=4:tw=0

#
#
# ~/.config/zsh/alias.rc.zsh
#
#

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

# Editor
: ${EDITOR:="nvim"}
alias     e="$EDITOR"
alias  edit="$EDITOR"
alias     v="$EDITOR"
alias    vi="$EDITOR"
alias   vim="$EDITOR"
alias  nvim="$EDITOR"
alias    hx="$EDITOR"
alias   kak="$EDITOR"
alias  nano="$EDITOR"
alias emacs="$EDITOR"

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

    alias new-dl='print -r "\"$(tail -1 $XDG_CACHE_HOME/inotify-net-firefox.log.txt)\""'

elif [[ -v TERMUX_VERSION ]]; then
    # Package Manager
    alias pki="pkg install"
    alias pks="pkg search"
    
    # Clipboard
    alias cb-copy="termux-clipboard-set"
    alias cb-paste="termux-clipboard-get"
    
    (( $+commands[trash-put] )) && alias del="trash-put"
else
    print -u2 "${0}: Unable to discern either chewytop or chewytele"
    return 1
fi
