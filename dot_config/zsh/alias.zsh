# vim: expandtab:tabstop=4:shiftwidth=4:tw=0

#
#
# ~/.config/zsh/alias.zsh
#
#

setopt aliases

# Bluetooth
alias bt=bluetui

# Prompt before overwriting
alias cp="cp --interactive"
alias mv="mv --interactive"

# Human readable
alias free='free --mebi'
alias df='df --human-readable'
alias du='du --block-size=1K'

# Show colour and case-insensitive
alias grep='grep	--color=auto -i'
alias pgrep='pgrep	--color=auto -i'

# Package Manager
alias pacman=$PACMAN_WRAP

# Editor
alias nano=$EDITOR

# Impala
alias impala='sudo impala'

# SQLite
alias sqlite='sqlite3'

# WireGuard ProtonVPN
alias vpnup='sudo wg-quick up protonvpn'
alias vpndown='sudo wg-quick down protonvpn'
alias vpnstat='sudo wg show'

# Command --help Colorisation
#
# Disabled due to global aliases expanding in the shell case match strings of
# sourced files
#alias -g -- -h='     -h    2>&1	| bat --language=help'
#alias -g -- --help='--help 2>&1	| bat --language=help'
#
function _zle_accept_line_help_bat() {
    if [[ $BUFFER == *\ (-h|--help) ]]; then
        BUFFER="${BUFFER} 2>&1 | bat --language=help"
    fi
    zle .accept-line
}
zle -N accept-line _zle_accept_line_help_bat

# Linters
alias lint-json="json-glib-validate"
alias lint-toml="tombi lint"
alias lint-yaml="yamllint"

alias lint-css="stylelint"
alias lint-js=""

alias lint-lua="luacheck"
alias lint-py="ruff"

alias lint-sql="sqruff lint"
alias lint-ts=""

alias lint-systemd="systemd-analyze verify"
alias lint-tldr="tldr-lint"
