#!/bin/false
# vim: expandtab:shiftwidth=4

#
#
# ~/.config/zsh/rc/util/fzf.rc.zsh
#
#

#
# The ubiquitous command-line fuzzy finder
# https://github.com/junegunn/fzf
# https://github.com/junegunn/fzf#environment-variables
#

[[ -o interactive  ]] || return
(( $+commands[fzf] )) || return

__fzf_interactive_opts=(
    "--reverse"
    "--border"
    "--height 40%"
)
__fzf_interactive_opts=${(j: :)__fzf_interactive_opts}
__fzf_command_fd=(
    "fd"
    "--hidden"
    "--strip-cwd-prefix=always"
    "--one-file-system"
)
__fzf_command_fd=${(j: :)__fzf_command_fd}

function __fzf_keybind () {
    #   CTRL-R
    #       Fuzzy-find command history
    #   CTRL-T
    #       Fuzzy-find files recursively from CWD
    #   ALT-C
    #       Fuzzy-find directories recursively from CWD and cd
    #
    #   https://github.com/junegunn/fzf#key-bindings-for-command-line

    #export FZF_CTRL_R_COMMAND="echo 'Custom commands not yet supported'"
    local __fzf_ctrl_r_opts=(
        "$__fzf_interactive_opts"
        "--scheme=history"
        "--with-nth 2.."
    )
    export FZF_CTRL_R_OPTS=${(j: :)__fzf_ctrl_r_opts}

    local __fzf_ctrl_t_command=(
        "$__fzf_command_fd"
    )
    export FZF_CTRL_T_COMMAND=${(j: :)__fzf_ctrl_t_command}
    local __fzf_ctrl_t_opts=(
        "$__fzf_interactive_opts"
        "--scheme=path"
    )
    export FZF_CTRL_T_OPTS=${(j: :)__fzf_ctrl_t_opts}

    local __fzf_alt_c_command=(
        "$__fzf_command_fd"
        "--type directory"
    )
    export FZF_ALT_C_COMMAND=${(j: :)__fzf_alt_c_command}
    local __fzf_alt_c_opts=(
        "$__fzf_interactive_opts"
        "--scheme=path"
    )
    export FZF_ALT_C_OPTS=${(j: :)__fzf_alt_c_opts}

}; __fzf_keybind; unset -f __fzf_keybind

function __fzf_completion () {
    # https://github.com/junegunn/fzf#fuzzy-completion

    export FZF_COMPLETION_TRIGGER='**'

    local __fzf_completion_opts=(
        "$__fzf_interactive_opts"
        "--scheme=path"
    )
    export FZF_COMPLETION_OPTS=${(j: :)__fzf_completion_opts}

    export FZF_COMPLETION_DIR_OPTS='--walker dir,follow'
    export FZF_COMPLETION_PATH_OPTS='--walker file,dir,follow,hidden'

    # TODO(@chewygumxx): (Priority: Low)
    #function _fzf_comprun() {
    #    local command=$1; shift
    #    
    #    case "$command" in
    #        cd)           fzf --preview 'tree -C {} | head -200'   "$@" ;;
    #        export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
    #        ssh)          fzf --preview 'dig {}'                   "$@" ;;
    #        *)            fzf --preview 'bat -n --color=always {}' "$@" ;;
    #    esac
    #}
}; __fzf_completion; unset -f __fzf_completion

unset __fzf_{interactive_opts,command_fd}


#
# Generate and initialise shell integration
# https://github.com/junegunn/fzf#setting-up-shell-integration
#

init_cache="$zsh_dirs[cache_init]/fzf.init.zsh"

# Regenerate init cache if either:
#  - Missing
#  - Older than fzf binary
#  - Older than this file
if  [[ ! -f "$init_cache" ]] ||\
    [[ "$init_cache" -ot "$commands[fzf]" ]] ||\
    [[ "$init_cache" -ot "${(%):-%N}" ]]
then
    echo "Regenerating fzf source cache"
    fzf --zsh >| "$init_cache"
fi

# Ensure fzf keybinds are not overridden by plugin 'zsh-vi-mode'
if [[ -n "${(M)plugins:#*zsh-vi-mode*}" ]]; then
    zvm_after_init_commands+=("source ${(q)init_cache}")
else
    source "$init_cache"
fi

unset init_cache
