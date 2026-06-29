# vim:

#
#
# ~/.config/zsh/command/tealdeer.source.zsh
#
#

[[ -o interactive ]] || return
[[ -n "$commands[tldr]" ]] || return
# [[ $(tldr --version | cut --delimiter=1 fields=1) == "tealdeer" ]] || return

function tldr() {
    if [[ ${#} -eq 0 ]]; then
        command tldr --list | fzf \
            --preview "tldr {1} --color=always" \
            --preview-window=right,70% \
            --bind "enter:become(tldr {1})"
    else
        command tldr $@
    fi
}
