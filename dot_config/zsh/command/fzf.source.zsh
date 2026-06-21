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

# {{{ ANSI Escape Array
declare -A cl
cl=(
# None            Bold            Dim             Italic          Underline
 [n]=$'\e[0m'    [b]=$'\e[1m'    [d]=$'\e[2m'    [i]=$'\e[3m'    [u]=$'\e[4m'
# Blink           Fast Blink      Standout        Conceal         Strikeout
 [blnk]=$'\e[5m' [fast]=$'\e[6m' [stnd]=$'\e[7m' [hide]=$'\e[8m' [strk]=$'\e[9m'

# Standard              Bright
 [blk]=$'\e[0;30m'     [BLK]=$'\e[0;90m'     # Black   
 [red]=$'\e[0;31m'     [RED]=$'\e[0;91m'     # Red     
 [grn]=$'\e[0;32m'     [GRN]=$'\e[0;92m'     # Green   
 [ylw]=$'\e[0;33m'     [YLW]=$'\e[0;93m'     # Yellow  
 [blu]=$'\e[0;34m'     [BLU]=$'\e[0;94m'     # Blue    
 [mag]=$'\e[0;35m'     [MAG]=$'\e[0;95m'     # Magenta 
 [cyn]=$'\e[0;36m'     [CYN]=$'\e[0;96m'     # Cyan    
 [wht]=$'\e[0;37m'     [WHT]=$'\e[0;97m'     # White   

# Standard Bold         Bright Bold 
 [b_blk]=$'\e[1;30m'   [b_BLK]=$'\e[1;90m'   # Black    
 [b_red]=$'\e[1;31m'   [b_RED]=$'\e[1;91m'   # Red      
 [b_grn]=$'\e[1;32m'   [b_GRN]=$'\e[1;92m'   # Green    
 [b_ylw]=$'\e[1;33m'   [b_YLW]=$'\e[1;93m'   # Yellow   
 [b_blu]=$'\e[1;34m'   [b_BLU]=$'\e[1;94m'   # Blue     
 [b_mag]=$'\e[1;35m'   [b_MAG]=$'\e[1;95m'   # Magenta  
 [b_cyn]=$'\e[1;36m'   [b_CYN]=$'\e[1;96m'   # Cyan     
 [b_wht]=$'\e[1;37m'   [b_WHT]=$'\e[1;97m'   # White    

# Standard Dim          Bright Dim 
 [d_blk]=$'\e[2;30m'   [d_BLK]=$'\e[2;90m'   # Black    
 [d_red]=$'\e[2;31m'   [d_RED]=$'\e[2;91m'   # Red      
 [d_grn]=$'\e[2;32m'   [d_GRN]=$'\e[2;92m'   # Green    
 [d_ylw]=$'\e[2;33m'   [d_YLW]=$'\e[2;93m'   # Yellow   
 [d_blu]=$'\e[2;34m'   [d_BLU]=$'\e[2;94m'   # Blue     
 [d_mag]=$'\e[2;35m'   [d_MAG]=$'\e[2;95m'   # Magenta  
 [d_cyn]=$'\e[2;36m'   [d_CYN]=$'\e[2;96m'   # Cyan     
 [d_wht]=$'\e[2;37m'   [d_WHT]=$'\e[2;97m'   # White    
)
# }}}
# {{{ Log Strings
declare -A log
log=(
    [tag_b]="$cl[b_WHT]["
    [tag_e]="$cl[b_WHT]]$cl[n]::"

        [root]="$cl[BLK]├$cl[n]"
     [branch1]="$cl[BLK]╰──$cl[n]"
    [branch1e]="$cl[BLK]╰─╴$cl[n]" 
    [branch2a]="$cl[BLK]├──╴$cl[n]"
    [branch2b]="$cl[BLK]╰┬╴$cl[n]" # Base
    [branch2p]="$cl[BLK]╰─┬$cl[n]" # Periphery
     [branch3]="$cl[BLK]├─┬"
        [vert]="$cl[BLK]│"
)
log+=(
    [Usage]="$log[tag_b]$cl[grn]Usage$log[tag_e]"
    [ERROR]="$log[tag_b]$cl[b_red]ERROR$log[tag_e]"
     [WARN]="$log[tag_b]$cl[b_YLW]WARN$log[tag_e]"
)
# }}}

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
