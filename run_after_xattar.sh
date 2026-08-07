#!/bin/sh
# vim: expandtab:shiftwidth=4

# 
# 
# ~chewygumxx/dotfiles.git:/run_after_xattar.sh
# 
# 

#
# Tags every chezmoi-managed file with an xattr, if the
# platform and destination filesystem support it. Logs skips and
# failures to a dedicated log.
#

set -eu

XATTR_NAME="${CHEZMOI_XATTR_NAME:-chezmoi}"

__this_file="run_after_xattar.sh"
state_home="${XDG_STATE_HOME:-${HOME}/.local/state}"
log_dir="${state_home}/chezmoi"
log_file="${log_dir}/xattr-tag.log"

log() {
    level="$1"; shift

	timestamp=$(date -u +'%Y-%m-%dT%H:%M:%SZ')

	printf '%s [%s] %s\n' "$timestamp" "$level" "$*" >> "$log_file" 2>/dev/null || true
	# Emit to stderr for chezmoi --verbose/--debug
	printf '%s: [%s] %s\n' "${__this_file}" "$level" "$*" >&2
}

if ! mkdir_stdouterr="$(mkdir -p "$log_dir" 2>&1)"; then
    log WARN "Failed to create log file directory"
    log WARN "$mkdir_stdourerr"
fi

# ---------------------
# Validate Environment
# ---------------------

if command -v setfattr >/dev/null 2>&1; then
	set_xattr() {
        user_xattr_name="$1"
        user_xattr_value="$2"
        file="$3"
		setfattr -n "user.$user_xattr_name" -v "$user_xattr_value" -- "$file"
	}
elif command -v xattr >/dev/null 2>&1; then
	set_xattr() {
        user_xattr_name="$1"
        user_xattr_value="$2"
        file="$3"
		xattr -w "$user_xattr_name" "$user_xattr_value" "$file"
	}
else
	log WARN "Neither 'setfattr' nor 'xattr' found"
	exit 0
fi

probe_file=$(mktemp "$CHEZMOI_DEST_DIR/.chezmoi_xattr_probe.XXXXXX")
: > "$probe_file" 2>/dev/null || {
	log WARN "Could not create probe file at ${probe_file}; skipping"
	exit 0
}
if ! set_xattr "$XATTR_NAME" "probe" "$probe_file" >/dev/null 2>&1; then
	log WARN "Destination filesystem at ${CHEZMOI_DEST_DIR} appears not to support xattrs; skipping"
	rm -f "$probe_file"
	exit 0
fi
rm -f "$probe_file"

log INFO 'xattr write support confirmed'


# -------------
# Apply xattar
# -------------

tag() {
    if [ "$1" = "managed" ] || [ "$1" = "unmanaged" ]; then
        paths="$(chezmoi "$1" --path-style=absolute --exclude=symlinks,remove,scripts)"
    elif [ "$1" = "ignored" ]; then
        paths="$(chezmoi "$1" -0 | xargs -0 printf "$CHEZMOI_DEST_DIR/%s\n")"
    else
        log ERROR "(tag) Tag provided not 'ignored', 'managed' or 'unmanaged': $1"
        exit 1
    fi

    run_log=$(mktemp)
    printf "%s" "$paths" | while IFS= read -r file; do
        # Validate either regular file or directory
        [ ! -f "$file" ] && [ ! -d "$file" ] && continue
        [ ! -L "$file" ] || continue
        
        if set_xattr_stdouterr="$(set_xattr "$XATTR_NAME" "$1" "$file" 2>&1)"; then
            echo OK    >> "$run_log"
            log  INFO  "Tag $1 success: ${file}"
        else
            echo FAIL  >> "$run_log"
            log  ERROR "Tag $1 FAILURE: ${file}"
            log  ERROR "$set_xattr_stdouterr"
        fi
    done

    tagged=$(grep -c '^OK$'   "$run_log" 2>/dev/null || echo 0)
    failed=$(grep -c '^FAIL$' "$run_log" 2>/dev/null || echo 0)
    rm -f "$run_log"

    log INFO "Tagging complete: ${tagged} tagged, ${failed} failed"
}

tag managed
tag ignored

if [ -e "$log_file" ]; then
    log INFO "See log file at: ${log_file}"
fi
