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
alias -g -- -h='     -h    2>&1	| bat --language=help'
alias -g -- --help='--help 2>&1	| bat --language=help'

# Linters
alias lint-json="json-glib-validate"        # ?: biome, spectral, demjson
alias lint-toml="tombi lint"	    	    # ?:
alias lint-yaml="yamllint"                  # ?: yamllint, spectral

alias lint-css="stylelint"		            # ?: biome, stylelint,
alias lint-js=""                            # ?: eslint_d, biome, jslint, oxlint, quick-lint-js
									        #    standard
alias lint-lua="luacheck"			        # ?: selene
alias lint-py="ruff"			            # ?: pylint, pyflakes, ast-grep, pylint-common, graylint,
										    #    darkgraylib
alias lint-sql="sqruff lint"		        # ?: sqlfluff, sqruff,
alias lint-ts=""                            # ?: eslint_d, biome, tslint

alias lint-systemd="systemd-analyze verify"
alias lint-tldr="tldr-lint"
