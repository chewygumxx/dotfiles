# vim: expandtab:shiftwidth=4:textwidth=100

#
#
# ~/.config/zsh/prompt.zsh
#
#

#
# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
# https://zsh.sourceforge.io/Doc/Release/Parameters.html#index-PROMPT
# https://zsh.sourceforge.io/Doc/Release/Parameters.html#Parameters-Used-By-The-Shell-1
#

autoload -Uz add-zsh-hook

unsetopt single_line_zle  # For >>Right PS1

setopt prompt_subst    # Prompt subject to parameter expansion, command
                       # substitution, and arithmetic expansion

setopt prompt_percent  # %-Based escape sequences

function __define_ps1 () {
    # Escape sequences must be enclosed within `%{...%}` such that cursor position calculation is
    # not affected by zero width sequences
    # https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html#Visual-effects
    local __blink="%{"$'\e[5m'"%}"

    # PS1 - The Ubiquitious
    local __ps1=(
        "%F{#626262}[%f"
        "%F{#5f95fa}%D{%H}%f"
        "%F{#7171d3}:%f"
        "%F{#5f95fa}%D{%M}%f"
        "%F{#7171d3}:%f"
        "%F{#5f95fa}%D{%S}%f"
        "%F{#626262}]%f"
        " "

        # Shell level
        "%(2L.%F{#ec5f66}lvl=%L%f .)"

        # Background Jobs
        "%(1j.%F{#4db380}[%j] .)"

        # Current Working Directory
        # - If root, absolute from /
        # - If user, relative to $HOME 
        "%F{magenta}%(#.%d.%~)%f"

        "%(?..%F{red}%B %?%b%f)" # Exit Code (if not zero)

        # Caret/Privilege
        "%(#."
            $__blink "%F{red}%#%f"
        "."
            "%F{#4db380}>%f"
        ")"
    )

    PS1=${(j::)__ps1}
}; __define_ps1; unset __define_ps1

function __preexec_rps1() {
  time_invoked=$SECONDS
}
add-zsh-hook preexec __preexec_rps1

function __precmd_rps1() {
    RPS1=""

    if [[ -n $time_invoked ]]; then
        local time_exec=$(( $SECONDS - $time_invoked ))
        if [[ $time_exec -gt 10 ]]; then 
            # RPS1="%F{blue}${time_exec}s%f ${RPS1}"
            RPS1="%F{blue}${time_exec}s%f"
        fi
        unset time_invoked
    fi
}
add-zsh-hook precmd __precmd_rps1



