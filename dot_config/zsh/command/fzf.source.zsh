# vim: expandtab:shiftwidth=4:textwidth=80
# vim: foldmethod=marker

#
#
# ~/.config/zsh/command/fzf.source.sh
#
#

#
# The ubiquitous command-line fuzzy finder
# https://github.com/junegunn/fzf
#

# 
# Intended to be sourced via:
# - .bashrc          (bash - interactive)
# - $BASH_ENV        (bash - non-interactive)
# - $ZDOTDIR/.zshenv (zsh  - all)
#


# {{{ Shell Validation
case $SHELL in
    */bash*)  ;;
    */zsh*)   ;;
    *)
        printf "%s " \
            "$log[ERROR] $cl[blu]Source File: $cl[b_WHT]fzf" \
            "\n" \
            "$log[root] Sourcing shell failed validation as neither" \
            "$cl[blu]bash $cl[n]nor $cl[blu]zsh" \
            "\n" \
            $log[branch1] \
            "$cl[n]Sourcing Shell:" \
            "$cl[red]$SHELL" \
            "$cl[n](consult source script)"
        return
        ;;
esac
# }}}
command -v fzf &>/dev/null || return

# {{{ FZF_DEFAULT_*
# https://github.com/junegunn/fzf#environment-variables

# FZF_DEFAULT_COMMAND
# Populates fzf list with an entry for each newline to stdout.
# Is *NOT* referenced for shell integration, neither keybinds nor completions.
#
#export FZF_DEFAULT_COMMAND="fd --unrestricted . ."

# FZF_DEFAULT_OPTS
# I use it for themes :3
#
export FZF_DEFAULT_OPTS="\
    --highlight-line \
    --color 'current-fg:#e8e0ff' \
    --color 'current-bg:#141337' \
    --color 'current-hl:#7408ff' \
    --color 'selected-bg:#090a24' \
    --color 'selected-fg:#cad6ff' \
    --color 'preview-fg:#cad6ff' \
    --color 'hl:#7408ff' \
    --color 'query:#cad6ff' \
    --color 'info:#7408cf' \
    --color 'border:#4e4581' \
    --color 'separator:#3d3470' \
    --color 'pointer:#7408ff' \
    --color 'marker:#7408cf' \
"

# FZF_DEFAULT_OPTS_FILE
# This would be perfect for themes.
#
#export FZF_DEFAULT_OPTS_FILE=$XDG_CONFIG_HOME/fzf/opts.env
# }}}

# 
# *** Interactive Exclusive ***
#
[[ $- == *i* ]] || return

# {{{ Keybinds
#   CTRL-R
#       Fuzzy-find command history
#   CTRL-T
#       Fuzzy-find files recursively from CWD
#   ALT-C
#       Fuzzy-find directories recursively from CWD
#
#   https://github.com/junegunn/fzf#key-bindings-for-command-line

__keybind_opt_common=(
    "--border"
    "--height 40%"
    "--reverse"
)

# {{{ FZF_CTRL_R_*
#export FZF_CTRL_R_COMMAND="echo 'Custom commands not yet supported'"

__fzf_ctrl_r_opts=(
    "--with-nth 2.."
)
# }}}

# {{{ FZF_CTRL_T_*
export FZF_CTRL_T_COMMAND="fd . . --hidden --exclude '.git' --print0"

__fzf_ctrl_t_opts=(
)
# }}}

# {{{ FZF_ALT_C_*
#export FZF_ALT_C_COMMAND=""

__fzf_alt_c_opts=(
)
# }}}

# {{{ Define Keybind Opts
__fzf_ctrl_r_opts+=( "${__keybind_opt_common[@]}" )
export FZF_CTRL_R_OPTS=$(printf "%s " "${__fzf_ctrl_r_opts[@]}" )

__fzf_ctrl_t_opts+=( "${__keybind_opt_common[@]}" )
export FZF_CTRL_T_OPTS=$(printf "%s " "${__fzf_ctrl_t_opts[@]}" )

__fzf_alt_c_opts+=( "${__keybind_opt_common[@]}" )
export FZF_ALT_C_OPTS=$(printf "%s " "${__fzf_alt_c_opts[@]}" )

unset \
    __keybind_opt_common \
    __fzf_ctrl_r_opts \
    __fzf_ctrl_t_opts \
    __fzf_alt_c_opts
# }}}
# }}}

# {{{ Fuzzy completion
# https://github.com/junegunn/fzf#fuzzy-completion
#
export FZF_COMPLETION_TRIGGER='**'
export FZF_COMPLETION_OPTS='--border --info=inline'
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
# }}}

# {{{ Setup
# https://github.com/junegunn/fzf#setting-up-shell-integration
#
case $SHELL in
    */bash*)
        _fzf_cache="${XDG_CACHE_HOME:-$HOME/.cache}/fzf/init.bash"
        _fzf_flag="--bash"
    ;;
    */zsh*)
        _fzf_cache="${XDG_CACHE_HOME:-$HOME/.cache}/fzf/init.zsh"
        _fzf_flag="--zsh"
    ;;
esac

# Regenerate init cache if missing or older than fzf binary
if [[ ! -f "$_fzf_cache" || "$(command -v fzf)" -nt "$_fzf_cache" ]]; then
    mkdir -p "${_fzf_cache%/*}"
    fzf $_fzf_flag >| $_fzf_cache
fi

source $_fzf_cache
unset _fzf_cache _fzf_flag
# }}}
