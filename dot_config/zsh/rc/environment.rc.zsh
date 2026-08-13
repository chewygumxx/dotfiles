#!/bin/false
# vim: expandtab:shiftwidth=4:filetype=zsh

# 
# 
# ~chewygumxx/dotfiles.git
# ::: :/dot_config/zsh/rc/util/environment.rc.zsh
# 
# 

#
# Interactive Shell Environment Variables
#

[[ -o interactive      ]] || return
#[[ ! -v TERMUX_VERSION ]] || return 


# Android
if (( $+commands[adb] )); then 
    export ANDROID_USER_HOME="$XDG_DATA_HOME/android"
fi

# GitHub
if (( $+commands[gh] )); then
    export GH_TELEMETRY="false"
    export DO_NOT_TRACK="true"
fi

# GnuPG
if (( $+commands[gpg] )); then
    export GNUPGHOME="$XDG_DATA_HOME/gnupg"
fi

# Go
if (( $+commands[go] )); then
    export GOROOT="/usr/lib/go"
    export GOPATH="$XDG_DATA_HOME/go"
    export GOBIN="$XDG_DATA_HOME/go/bin"
fi

# Gradle
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"

# Parallel
export PARALLEL_HOME="$XDG_DATA_HOME/parallel"

# Perl
export PERL_CPANM_HOME="$XDG_CACHE_HOME/cpanm"

# Python
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"

# Rust
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

# SQLite
if (( $+commands[sqlite3] )); then
    export SQLITE_HISTORY="$XDG_STATE_HOME/sqlite/history"
fi

# Terminfo
export TERMINFO="$XDG_DATA_HOME/terminfo"
export TERMINFO_DIRS="${TERMINFO}:/usr/share/terminfo"
