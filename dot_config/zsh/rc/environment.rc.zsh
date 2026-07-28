#!/bin/false
# vim: expandtab:shiftwidth=4

# 
# 
# ~/.config/zsh/rc/util/env.rc.zsh
# 
# 

[[ -o interactive    ]] || return
[[ -v TERMUX_VERSION ]] && return

export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"
export SQLITE_HISTORY="$XDG_STATE_HOME/sqlite/history"

export GH_TELEMETRY="false"
export DO_NOT_TRACK="true"

export GNUPGHOME="$XDG_DATA_HOME/gnupg"

export TERMINFO="$XDG_DATA_HOME/terminfo"
export TERMINFO_DIRS="$XDG_DATA_HOME/terminfo:/usr/share/terminfo"

export GOROOT="/usr/lib/go"
export GOPATH="$XDG_DATA_HOME/go"
export GOBIN="$XDG_DATA_HOME/go/bin"

export PARALLEL_HOME="$XDG_DATA_HOME/parallel"

export ANDROID_USER_HOME="$XDG_DATA_HOME/android"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

export PERL_CPANM_HOME="$XDG_CACHE_HOME/cpanm"

export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
