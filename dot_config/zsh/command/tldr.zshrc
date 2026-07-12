# vim:

#
#
# ~/.config/zsh/command/tldr.zshrc
#
#

#
# Compatible with:
# https://github.com/tldr-pages/tlrc
# https://github.com/tealdeer-rs/tealdeer
#

[[ -o interactive ]] || return
[[ -n "$commands[tldr]" ]] || return

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
