#!/bin/false
# vim: expandtab:shiftwidth=4

#
#
# ~/.config/zsh/rc/util/chezmoi.rc.zsh
#
#

#
# Node Version Manager
#

[[ -o interactive          ]] || return
[[ ! -s "$NVM_DIR/nvm.sh"  ]] || return

# --no-use    Load nvm only when called
source "$NVM_DIR/nvm.sh"  --no-use     
