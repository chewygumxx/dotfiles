#!/bin/false
# vim:set expandtab shiftwidth=4 filetype=zsh:
# SPDX-License-Identifier: GPL-3.0-only

#
#
# ~chewygumxx/dotfiles.git
# ::: :/home/dot_config/zsh/exact_env/claude.env.zsh
#
#

# Herdr also requires this. Like CODEX_HOME, it lives in ~/.local/var, where
# the chezmoi source deploys it (home/dot_local/var/claude). Keep it equal to
# ~/.config/environment.d/claude.conf and the default in wrap/claude.
export CLAUDE_CONFIG_DIR="${XDG_DATA_HOME:="$HOME/.local/share"}/claude"
