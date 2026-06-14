# vim:ft=sh:tabstop=4:shiftwidth=4:noexpandtab:tw=0

#
#
# ~/.config/zsh/alias.zsh
#
#

setopt aliases



# Bluetooth
alias bt=bluetui
#alias bt-disc="bluetoothctl disconnect"
#chewyears_MAC='00:0A:45:31:3A:37'
#alias bt-ears="bluetoothctl connect $chewyears_MAC"
#chewytele_MAC='1C:F8:D0:6F:BA:30'
#alias bt-tele="bluetoothctl connect $chewytele_MAC"

# Prompt before overwriting
alias cp="cp --interactive"
alias mv="mv --interactive"

# Human readable
alias free='free -mebi'
alias df='df --human-readable'

# Show colour and case-insensitive
alias grep='grep	--color=auto -i'
alias egrep='egrep	--color=auto -i'

# Package Manager
alias pacman=$PACMAN_WRAP

# Editor
alias nano=$EDITOR

# Remove
alias rm="trash-put"

# SQLite
alias sqlite='sqlite3'

alias wget='wget --hsts-file="$XDG_DATA_HOME/wget-hsts"'

alias scr-lua="cd $HOME/scr/lua; nvim lua.scr.lua"
alias source-zsh="source $ZDOTDIR/.zshrc"

alias vpnup='sudo wg-quick up protonvpn'
alias vpndown='sudo wg-quick down protonvpn'
alias vpnstat='sudo wg show'

# Command --help Colorisation
alias -g -- -h='     -h    2>&1	| bat --language=help'
alias -g -- --help='--help 2>&1	| bat --language=help'
