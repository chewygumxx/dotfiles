#!/usr/bin/env zsh
# vim:set expandtab shiftwidth=4 filetype=zsh:
# SPDX-License-Identifier: GPL-3.0-only

#
#
# ~chewygumxx/dotfiles.git
# ::: :/scripts/mise-install.zsh
#
#

: "${XDG_DATA_HOME:=$HOME/.local/share}"

export MISE_VERSION="${MISE_VERSION:-"2026.11.12"}"
export MISE_INSTALL_PATH="$XDG_DATA_HOME/mise"

export MISE_INSTALL_SKIP_IF_EXISTS=1
