# vim: ft=zsh:foldlevel=0

#
#
# ~/.config/zsh/func.zsh
#
#


function print-ansi-colors() {
    __ansi16_fg=(
        $'\e[0;30m 0 - Black   '
        $'\e[1;30mBold Black   '
        $'\e[0;90m 8 - Bright  '
        $'\e[1;90mBright Bold'
        $'\n'
        $'\e[0;31m 1 - Red     '
        $'\e[1;31mBold Red     '
        $'\e[0;91m 9 - Bright  '
        $'\e[1;91mBright Bold'
        $'\n'
        $'\e[0;32m 2 - Green   '
        $'\e[1;32mBold Green   '
        $'\e[0;92m10 - Bright  '
        $'\e[1;92mBright Bold'
        $'\n'
        $'\e[0;33m 3 - Yellow  '
        $'\e[1;33mBold Yellow  '
        $'\e[0;93m11 - Bright  '
        $'\e[1;93mBright Bold'
        $'\n'
        $'\e[0;34m 4 - Blue    '
        $'\e[1;34mBold Blue    '
        $'\e[0;94m12 - Bright  '
        $'\e[1;94mBright Bold'
        $'\n'
        $'\e[0;35m 5 - Magenta '
        $'\e[1;35mBold Magenta '
        $'\e[0;95m13 - Bright  '
        $'\e[1;95mBright Bold'
        $'\n'
        $'\e[0;36m 6 - Cyan    '
        $'\e[1;36mBold Cyan    '
        $'\e[0;96m14 - Bright  '
        $'\e[1;96mBright Bold'
        $'\n'
        $'\e[0;37m 7 - White   '
        $'\e[1;37mBold White   '
        $'\e[0;97m15 - Bright  '
        $'\e[1;97mBright Bold'
        $'\n'
    )
    printf "%s" ${__ansi16_fg[@]}
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

    \rm -f -- "$tmp"
}

function backlight() {
    brightnessctl \
        --class='backlight' \
        --device='intel_backlight' \
        --min-value 100 \
        --exponent "$@"
}

function ffp() {
    # Append firefox preference setting to scratch file
    jo -s pref=$1 value=$2 -s comment=$3 \
        | tee --append ~/scr/ff-userjs.scr.jsonl \
        | jq  --indent 4 '.' \
        | bat --language=json
}

# SSH
function ssh-tele() {
     if ! [[ -S $SSH_AUTH_SOCK ]]; then
        echo "SSH socket not found"
        return
     fi
     ssh-add ~/.ssh/chewytop-tele

     ssh "ssh://${SSH_CHEWYTELE}" ${@}
}

function sftp-tele() {
     if ! [[ -S $SSH_AUTH_SOCK ]]; then
        echo "SSH socket not found"
        return
     fi
     ssh-add ~/.ssh/chewytop-tele

     sftp sftp://${SSH_CHEWYTELE}
}

function clipdump() {
    CLIPDUMP_DIR="/tmp/clipdump"
    mkdir -p $CLIPDUMP_DIR
    wl-paste --watch $HOME/scr/python/textdump.py | \
        tee --append $CLIPDUMP_DIR/$(date +"%Y-%m-%d_%H-%M-%S").clipdump.txt
}

function find-unicode() {
    UNICODE=$1 # U+0123
    if ! [[ $UNICODE =~ '^U\+[0-9ABCDEFabcdef]{4}$' ]]; then
        echo "Usage: $0 <unicode>"
        echo "       $0 U+1234"
        return
    fi

    fd -e ttf -e otf . '/usr/share/fonts' --exec echo $UNICODE | parallel \
        --colsep "^(U\+[0-9ABCDEFabcdef]{4}) (.*?)$" \
        'result=$(interrofont --glyph-for {2} {3})
        [[ $result != *"not in font"* ]] && echo "{3}: $result"'
        # With parallel --colsep, {1} is always the entire line
}

function pretty-array() {
    if [[ $# -eq 0 ]] || ! [[ -v $1 ]]; then
        echo "Usage: $0 <arrayvar>"
        echo "    Pretty prints an array with typeset -p1."
    fi
    typeset -p1 $@
}

function read-pipe() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: $0 <fifo>"
        echo "    Persistently reads FIFO file even after EOF"
        echo "    All other arguments ignored"
    elif ! [[ -p $1 ]]; then
        echo "$1: Unrecognised file (not FIFO)"
    fi

    while true; do stdbuf -oL cat $1; done
}

function sum-total() {
    # Reads numbers provided via stdin and prints sum total
    paste -sd+ | bc
}

function nvim() {
    target=$1

    if [[ ! ${#} -eq 1 ]]; then
        command nvim "$@"
    elif [[ -d "$target" ]]; then
        cd "$target"
    elif [[ ! -z "$(chezmoi managed "$target")" ]]; then
        chezmoi edit --watch "$target"
    else
        command nvim "$@"
    fi
}

