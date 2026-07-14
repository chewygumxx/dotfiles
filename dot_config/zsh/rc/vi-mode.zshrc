# vim: expandtab:shiftwidth=4

#
#
# ~/.config/zsh/native/vi-mode.zshrc
#
#

return # Disable in favour of plugin 'zsh-vi-mode'

[[ -o interactive ]] && [[ -n "$ZVM_VERSION" ]] || return

bindkey -v
export KEYTIMEOUT=5

# Change cursor shape per Vi mode
function zle-keymap-select {
    if  [[ ${KEYMAP} == vicmd ]] ||
        [[ $1 = 'block' ]]
    then
        echo -ne '\e[1 q'

    elif [[ ${KEYMAP} == main ]] ||
         [[ ${KEYMAP} == viins ]] ||
         [[ ${KEYMAP} = '' ]] ||
         [[ $1 = 'beam' ]]
    then
        echo -ne '\e[5 q'
    fi
}
zle -N zle-keymap-select


# Initiate `vi insert` as keymap (removable if `bindkey -V` set elsewhere)
zle-line-init() {
    zle -K viins 
    echo -ne "\e[5 q"
}
zle -N zle-line-init

echo -ne '\e[5 q'					# Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;}	# Use beam shape cursor for each new prompt.

# Ctrl+E: Edit Command Line in Neovim
autoload edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line

