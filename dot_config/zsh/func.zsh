# vim: ft=zsh:foldlevel=1

#
#
# ~/.config/zsh/func.zsh
#
#


function print-ansi-colors() {
    printf   "\e[0;30m0 - Black   \e[1;30mBold Black     \e[0;90m 8 - Light Black  "
    printf "\n\e[0;31m1 - Red     \e[1;31mBold Red       \e[0;91m 9 - Light Red    "
    printf "\n\e[0;32m2 - Green   \e[1;32mBold Green     \e[0;92m10 - Light Green  "
    printf "\n\e[0;33m3 - Yellow  \e[1;33mBold Yellow    \e[0;93m11 - Light Yellow "
    printf "\n\e[0;34m4 - Blue    \e[1;34mBold Blue      \e[0;94m12 - Light Blue   "
    printf "\n\e[0;35m5 - Purple  \e[1;35mBold Purple    \e[0;95m13 - Light Purple "
    printf "\n\e[0;36m6 - Cyan    \e[1;36mBold Cyan      \e[0;96m14 - Light Cyan   "
    printf "\n\e[0;37m7 - White   \e[1;37mBold White     \e[0;97m15 - Light White  "
    printf "\n"
    printf "\n\e[0;35mPurple \e[0mis also often refered to as \e[0;35mMagenta"
    printf "\n\e[0mSource: https://gist.github.com/JBlond/2fea43a3049b38287e5e9cefc87b2124"
    printf "\n"
}

# ADB Wifi Connect and Set Port
adbw() { 
    # $1 = Random Wireless Debugging Port
    
    CHEWYTELE_IP="192.168.4.22"
    ADB_WIFI_PORT=55555

    adb connect $CHEWYTELE_IP:$1
    adb tcpip $ADB_WIFI_PORT
    adb disconnect
    adb connect $CHEWYTELE_IP:$ADB_WIFI_PORT
}

function man() {
    PAGER='nvim +Man!' \
    MANWIDTH=$(( (COLUMNS - 5) < 100 ? (COLUMNS - 5) : 100 )) \
    MANOPT='--no-justification --no-hyphenation' \
    BAT_THEME='ansi' \
    BAT_STYLE='snip' \
    batman $1
}

y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

fh() { # Fzf Command History
    print -z $( \
        ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | \
        fzf +s --tac --border --height 40% --reverse | \
        sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g' \
    )
}

function backlight() {
    brightnessctl \
        --class='backlight' \
        --device='intel_backlight' \
        --min-value 100 \
        --exponent "$@"
}
