# vim:

#
#
# ~/.config/zsh/command/tealdeer.source.zsh
#
#

if ! command -v tldr &>/dev/null; then
    return
fi

function tldr() {
    if [[ ${#} -eq 0 ]]; then
        /usr/bin/tldr --list | fzf \
            --preview "tldr {1} --color=always" \
            --preview-window=right,70% \
            --bind "enter:become(tldr {1})"
    else
        /usr/bin/tldr $@
    fi
}
