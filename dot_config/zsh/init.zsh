# vim: expandtab:tabstop=4:shiftwidth=4:textwidth=80:
# vim: foldmethod=marker

#
#
# ~/.config/zsh/zshrc
#
#

#  
#  ~/.config/environment.d/env.conf contains:
#      export ZDOTDIR=/home/chewygumxx/.config/zsh
#
#  Symlinked: ./.zshrc -> this
#



# Shell Interactivity Check
[[ $- != *i* ]] && return     

ZSH_CACHE="$XDG_CACHE_HOME/zsh"
[[ -d $ZSH_CACHE ]] || mkdir -p $ZSH_CACHE

# Debugging profiler
#zmodload zsh/zprof             


# {{{ Options
    setopt interactive_comments
    zle_highlight=('paste:none')
    # {{{ History
        HISTFILE="$ZSH_CACHE/history"

        # SAVEHIST > HISTSIZE
        HISTSIZE=20000000
        SAVEHIST=21000000
        
        # Upon shell exit: Append to history file      
        # Records both time invoked and execution time
        setopt inc_append_history_time  
                                        
        # Despite Zsh documentation of the INC_APPEND_HISTORY_TIME        
        # inferring a following setopt EXTENDED_HISTORY is redundant, it                                  
        # seems (somehow?) it does need to be setopt-ed for timestamping.
        setopt extended_history         
                                        
        # Upon SHELL exit: Append to history file, rather than rewrite
       #setopt append_history
        
        # Share a live, common history among all active shells
       #setopt share_history
        
        # TODO(@chewygumxx):
        #   I don't understand why I'm interested in atuin's history database
        #   I have absolutely no use for it 
    # }}}
# }}}
# {{{ Sources
    source $ZDOTDIR/prompt.zsh
    source $ZDOTDIR/alias.zsh
    source $ZDOTDIR/func.zsh

    CMD_ASSIST_LIST=(
        "eza"
        "chezmoi"
        "firefox"
    )
    for CMD_ASSIST in $CMD_ASSIST_LIST; do
        source $ZDOTDIR/command/${CMD_ASSIST}.source.zsh
    done

    PLUGIN_LIST=(
        "fast-syntax-highlighting"
        #"zsh-autocomplete"
        "plugin-zsh-vi-mode"
    )
    for PLUGIN in $PLUGIN_LIST; do
        source $ZDOTDIR/plugin/${PLUGIN}.source.zsh
    done

    # {{{ [Defunct] Direct source of system *.plugin.zsh 
    # PLUGIN_DIR="/usr/share/zsh/plugins"
    # PLUGIN_LIST=(
    #     "fast-syntax-highlighting"
    #    #"zsh-autocomplete"
    #     "zsh-vi-mode"
    # )
    # for PLUGIN in $PLUGIN_LIST; do
    #     source $PLUGIN_DIR/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh 2>/dev/null
    # done
    # }}}
# }}}
# {{{ Auto Completion
    autoload -Uz compinit

    zstyle ':completion:*' menu select

    # "Completion-System.html#:~:text=cache%2Dpath%20%C2%B6"
    # TODO(@chewygum): Finish this
    zstyle ':completion:*' cache-path   "$ZSH_CACHE/compcache"
    zmodload zsh/complist

    _comp_options+=(globdots)

    # Save extended_glob state
    [[ -o extended_glob ]]; local_extglob=$?
        setopt extended_glob

        COMPDUMP="$ZSH_CACHE/zcompdump"
        # Glob explanation:
        #   N      Return an empty list if nothing found, instead of an error
        #   mh-24  Return files less than 24 hours old.
        if [[ -n $COMPDUMP(Nmh-24) ]]; then
            compinit -C -d  $COMPDUMP
        else
            compinit -d     $COMPDUMP
        fi

    # Resume extended_glob state
    (( local_extglob )) && unsetopt extended_glob
# }}}

# {{{ fzf
    # The ubiquitous fuzzy finder, invoked here for
    #   CTRL-R
    #       Search command history
    #   CTRL-T
    #       Search recursively from CWD
    if command -v fzf &>/dev/null; then
        eval "$(fzf --zsh)"
    fi
# }}}
# {{{ zoxide
    # Fuzzy frecency directory jumper
    #   According to repository README, must be invoked *after* compinit.
    #   https://github.com/ajeetdsouza/zoxide#:~:text=Zsh-,Add,compinit,-%2E
    #
    if command -v zoxide &>/dev/null; then
        eval "$(zoxide init --cmd cd zsh)"
    fi
# }}}

# {{{ luarocks
    # Exports environment variables
    #   LUA_PATH
    #   LUA_CPATH
    #   PATH (appends to)
    #
    # TODO(@chewygumxx):
    #   Disabled, replaced with a source file that is updated via luarocks
    #   version switch hook TODO(@chewygumxx)
    #eval $(luarocks path --bin)
    [ -s "$XDG_CONFIG_HOME/luarocks/env.sh" ] &&
        source "$XDG_CONFIG_HOME/luarocks/env.sh"
# }}}
# {{{ nvm
    # Node Version Manager
    # --no-use    Load nvm only when called
    [ -s "$NVM_DIR/nvm.sh" ] &&
        source "$NVM_DIR/nvm.sh"  --no-use     
# }}}

#
# *** Post-Startup
#

print-quote
