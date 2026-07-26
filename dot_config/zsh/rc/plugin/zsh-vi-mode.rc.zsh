# vim:

#
#
# ~/.config/zsh/rc/plugin/zsh-vi-mode.rc.zsh
#
#

#
# TODO(@chewygumxx): (Priority: Medium) 
# This plugin is both incredibly valued and pervasively problematic. It is
# worthwhile to fork and gut it of inconvienience.
#

# 
# This line of the plugin must be nullified for fzf CTRL-R:
#   zvm_bindkey viins '^R' history-incremental-search-backward
#

plugin="zsh-vi-mode"

if [[ ! -d "$ZSH_HOME_DIRS[PLUGIN]/$plugin" ]]; then
    git clone "https://github.com/jeffreytse/$plugin.git" \
        "$ZSH_HOME_DIRS[PLUGIN]/$plugin"
fi

function zvm_config() {
    # See https://github.com/jeffreytse/zsh-vi-mode#configuration-function
    
    ZVM_VI_HIGHLIGHT_BACKGROUND='#2d2857'
    ZVM_VI_HIGHLIGHT_FOREGROUND='#cad6ff'
    # ZVM_VI_HIGHLIGHT_EXTRASTYLE=bold,underline

    ZVM_CURSOR_STYLE_ENABLED=true
    ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
    ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK

    # ZVM_VI_SURROUND_BINDKEY
    # ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT

    ZVM_SYSTEM_CLIPBOARD_ENABLED=true
    ZVM_CLIPBOARD_COPY_CMD="wl-copy --trim-newline"
    ZVM_CLIPBOARD_PASTE_CMD="wl-paste --no-newline"

    ZVM_TMPDIR="${XDG_CACHE_HOME:-$HOME/.local/cache}/zsh-vi-mode/tempbuf"
    mkdir -p "$ZVM_TMPDIR"

    ZVM_OPEN_CMD="handlr open"
    ZVM_OPEN_URL_CMD="firefox --new-tab"
}

source "$ZSH_HOME_DIRS[PLUGIN]/$plugin/$plugin.plugin.zsh" 2>/dev/null
unset plugin

