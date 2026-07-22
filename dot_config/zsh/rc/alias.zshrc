# vim: expandtab:tabstop=4:shiftwidth=4:tw=0

#
#
# ~/.config/zsh/alias.zshrc
#
#

setopt aliases

# Fix for bash/zsh completion when executing aliases via sudo
# https://wiki.archlinux.org/title/Sudo#Passing_aliases
alias sudo="sudo "

# Bluetooth
alias bt="bluetui"

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
alias pacman="yay"

# Editor
alias     v="$EDITOR"
alias    vi="$EDITOR"
alias   vim="$EDITOR"
alias  nvim="$EDITOR"
alias    hx="$EDITOR"
alias   kak="$EDITOR"
alias  nano="$EDITOR"
alias  edit="$EDITOR"
alias emacs="$EDITOR"

# Impala
alias impala='sudo impala'

# SQLite
alias sqlite='sqlite3'

# GitHub CLI
alias gist='gh gist'

# WireGuard ProtonVPN
alias vpnup='sudo wg-quick up protonvpn'
alias vpndown='sudo wg-quick down protonvpn'
alias vpnstat='sudo wg show'

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
