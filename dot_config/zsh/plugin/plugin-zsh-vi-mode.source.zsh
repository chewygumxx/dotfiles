# vim:

#
#
# ~/.config/zsh/plugin/plugin-zsh-vi-mode.source.zsh
#
#

: ${PLUGIN_DIR:="/usr/share/zsh/plugins"}
PLUGIN_NAME="zsh-vi-mode"

function zvm_config() {
    # See https://github.com/jeffreytse/zsh-vi-mode#configuration-function
    
    ZVM_VI_HIGHLIGHT_EXTRASTYLES=bold,underline
    # ZVM_VI_SURROUND_BINDKEY
    # ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
    ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
    ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
    ZVM_SYSTEM_CLIPBOARD_ENABLED=true
    ZVM_CLIPBOARD_COPY_CMD="wl-copy --trim-newline"
    ZVM_CLIPBOARD_PASTE_CMD="wl-paste --no-newline"
}

source $PLUGIN_DIR/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh
