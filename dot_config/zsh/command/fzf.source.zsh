# vim: expandtab:shiftwidth=4

#
#
# ~/.config/zsh/command/fzf.source.zsh
#
#

if ! command -v fzf &>/dev/null; then
    return
fi

#export FZF_DEFAULT_COMMAND="fd --unrestricted . ."

# Declared via $ZDOTDIR/.zshenv for programs that execute in non-interactive shells
#export FZF_DEFAULT_OPTS

typeset -T FZF_CTRL_R_OPTS fzf_ctrl_r_opts ' '
fzf_ctrl_r_opts=(
    --border
    --height 40%
    --reverse
    --highlight-line
    --with-nth 2..
)
export FZF_CTRL_R_OPTS

typeset -T FZF_CTRL_T_OPTS fzf_ctrl_t_opts ' '
fzf_ctrl_t_opts=(
    --border
    --height 40%
    --reverse
    --highlight-line
)
export FZF_CTRL_T_OPTS

# The ubiquitous fuzzy finder, invoked here for
#   CTRL-R
#       Search command history
#   CTRL-T
#       Search recursively from CWD
eval "$(fzf --zsh)"


