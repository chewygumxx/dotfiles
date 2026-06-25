# vim: expandtab:shiftwidth=4:textwidth=80

#
#
# ~/.config/zsh/command/fzf.source.zsh
#
#

#
# The ubiquitous command-line fuzzy finder
# https://github.com/junegunn/fzf
#

# https://github.com/junegunn/fzf#environment-variables

[[ -n "$commands[fzf]" ]] || return

function __fzf_default () {
    # FZF_DEFAULT_COMMAND
    # Populates fzf list with an entry for each newline to stdout.
    # Is *NOT* referenced for shell integration; neither keybinds nor completions.
    #
    #export FZF_DEFAULT_COMMAND="fd --unrestricted . ."

    # FZF_DEFAULT_OPTS
    # I use it for themes :3
    #
    __fzf_default_opts=(
        --highlight-line
        --color 'current-fg:#e8e0ff'
        --color 'current-bg:#141337'
        --color 'current-hl:#7408ff'
        --color 'selected-bg:#090a24'
        --color 'selected-fg:#cad6ff'
        --color 'preview-fg:#cad6ff'
        --color 'hl:#7408ff'
        --color 'query:#cad6ff'
        --color 'info:#7408cf'
        --color 'border:#4e4581'
        --color 'separator:#3d3470'
        --color 'pointer:#7408ff'
        --color 'marker:#7408cf'
    )
    export FZF_DEFAULT_OPTS=${(j: :)__fzf_default_opts}
    unset __fzf_default_opts

    # FZF_DEFAULT_OPTS_FILE
    # This would be perfect for themes.
    #
    #export FZF_DEFAULT_OPTS_FILE=$XDG_CONFIG_HOME/fzf/opts.env
}; __fzf_default; unset __fzf_default

# 
# *** Interactive Exclusive ***
#
[[ -o interactive ]] || return

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
    "--no-require-git" # Always respect global gitignore file
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

}; __fzf_keybind; unset __fzf_keybind

function __fzf_completion () {
    # https://github.com/junegunn/fzf#fuzzy-completion

    export FZF_COMPLETION_TRIGGER='**'

    local __fzf_completion_opts=(
        "$__fzf_interactive_opts"
        "--scheme=path"
    )
    export FZF_COMPLETION_OPTS=${(j: :)__fzf_completion_opts}
    unset __fzf_completion_opts

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
}; __fzf_completion; unset __fzf_completion

unset __fzf_{interactive_opts,command_fd}

function __fzf_init () {
    # https://github.com/junegunn/fzf#setting-up-shell-integration
    __fzf_cache="${XDG_CACHE_HOME:-$HOME/.cache}/fzf/init.zsh"

    # Regenerate init cache if missing or older than fzf binary
    if  [[ ! -f "$__fzf_cache" ]] ||\
        [[ "$commands[fzf]" -nt "$__fzf_cache" ]]
    then
        mkdir -p "${__fzf_cache%/*}"
        fzf --zsh >| $__fzf_cache
    fi

    source $__fzf_cache
    unset __fzf_cache
}; __fzf_init; unset __fzf_init
