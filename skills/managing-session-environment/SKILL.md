---
name: managing-session-environment
description: >-
  Defines, changes and checks the user's session environment variables in this
  dotfiles repo, through one registry (home/.chezmoidata/environment.toml)
  rendered into systemd environment.d, zsh and ~/.ssh/config. Use before
  adding, changing, moving or removing a session-wide environment variable, a
  PATH entry, an XDG directory or a tool's home (CARGO_HOME, GNUPGHOME, ...);
  when a tool keeps creating a dot-directory in ~; when a variable differs
  between a terminal, a systemd service and a Hyprland-launched app; before
  touching ~/.config/environment.d, zsh's env/ files or
  SSH_AUTH_SOCK/IdentityAgent; when adding another shell (Nushell) as a
  consumer; or when .github/scripts/check-environment fails. Not for a CI
  workflow's env:, a project's .env, or a variable set inside one program's
  own config.
ctime: 2026-11-18
mtime: 2026-11-18
spdx: GPL-3.0-only
title: "Managing the session environment"
tags:
  - claude
  - skill
  - chezmoi
  - environment
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/skills/managing-session-environment/SKILL.md
   -
   -->

# Managing the session environment

Every session-wide environment variable is defined once, in
`home/.chezmoidata/environment.toml`, and generated into each consumer. Before
this registry the same variables were hand-written in systemd's
`environment.d`, zsh's `env/` and `~/.ssh/config`, and the copies drifted:
different `PAGER`s, different `PATH`s, tool homes a desktop app never saw, the
Linux ssh socket set on Android. The registry exists so a value is changed in
one place and cannot drift again; hand-editing a generated consumer undoes
that.

Design: `docs/spec/2026-11-18_environment-variable-registry-design.md`. Where
it and the data header or templates differ, the code wins.

## Which output reaches what

| Output | Reaches | Source |
| --- | --- | --- |
| zsh | Every zsh: terminals, scripts, ssh logins, TTYs, Termux. Also the login that starts Hyprland (ly's `setup.sh` re-executes under `$SHELL`), so Hyprland and everything it execs. | `home/dot_config/zsh/exact_env/00-environment.env.zsh.tmpl` |
| systemd | The systemd user manager and its units: waybar, portals, D-Bus-activated apps, `systemd-run`. | `home/dot_config/environment.d/zz-user-environment.conf.tmpl` |
| ssh | `IdentityAgent` in `~/.ssh/config`, from `SSH_AUTH_SOCK`. | `home/private_dot_ssh/config.tmpl` |

Hosts: `linux` is chewytop (the laptop), `android` is chewytele (Termux). The
registry varies by OS only; it cannot tell two Linux hosts apart. Termux has
no systemd, so `environment.d` is not deployed there
(`home/dot_config/.chezmoiignore`) and it gets only the zsh and ssh outputs.

Shared machinery: `home/.chezmoitemplates/environment/resolve` (picks each
value for `.chezmoi.os`, fills `${UID}`, validates, emits JSON), `.../systemd`
and `.../zsh` (render it). `.github/scripts/check-environment` renders every
output for both OSes and proves they agree.

## Does the variable belong in the registry?

A *consumer* is one of the outputs above, not a program. A variable belongs
when its program can be started in more than one way (a shell, a systemd
unit, Hyprland, ssh, Termux) and must see the same value each time. That is
why `GRADLE_USER_HOME`, `GH_TELEMETRY` and `DO_NOT_TRACK` are here even though
one program reads each.

It stays local when only one launch context ever needs it: an option for
interactive zsh (`FZF_DEFAULT_OPTS` in `exact_env/fzf.env.zsh`, zoxide in
`exact_util/zoxide.rc.zsh`), one unit's `Environment=`, WezTerm's `TERMINFO`,
a wrapper's `CLAUDE_CODE_*`. Values only known at runtime
(`CHEZMOI_SOURCE_DIR`) stay with `~/.local/bin/chezmoi-environment`. If the
tool has its own config file read in every context (`go env -w` writes one),
that can be the better home for a pure setting; say which you chose and why.

## The schema

The data file's header is the reference. In short:

```toml
[[environment.variables]]
name    = "CARGO_HOME"
value   = "${XDG_DATA_HOME}/cargo"
comment = "Why, if it is not obvious. Rendered above the line in every output."

[[environment.variables]]
name    = "SSH_AUTH_SOCK"
os      = { linux = "${XDG_RUNTIME_DIR}/ssh-agent-protonpass.socket", android = "${XDG_RUNTIME_DIR}/ssh-agent.socket" }
inherit = "ssh"

[environment.path]
prepend = ["${HOME}/.local/bin", "${CARGO_HOME}/bin", { dir = "${XDG_DATA_HOME}/npm/bin", os = ["linux"] }]
```

- **Order is evaluation order.** A value may reference `HOME`, `PREFIX`
  (Termux), `UID`, or a variable defined *above it* on the same OS; anything
  else fails the resolver, naming the variable.
- **Value syntax is literal text and `${NAME}`.** No bare `$`, quotes,
  backslashes or backticks: that subset is what zsh, environment.d and
  ssh_config all expand the same way, so one string renders into all three.
  References stay unexpanded until runtime, so an inherited `XDG_DATA_HOME`
  still moves everything under it. `${UID}` alone is filled in by chezmoi,
  since environment.d has no `UID`.
- **Write `${HOME}`, never `~`.** Nothing rejects `~`, and no consumer expands
  it inside the quotes the renderers emit, so `~/x` ships as a directory
  literally named `~`. Translate a user's `~/...` before writing it.
- **`os`** overrides `value` per `.chezmoi.os`. Keys are not validated: a typo
  such as `linx` silently drops the variable on that OS. A `PATH` entry's
  `os` must be a list (`["linux"]`), not a string.
- **`inherit`**: `false` (default) sets the value in every shell, nested ones
  included, so `PAGER=cat zsh -c ...` gets `less -R` back. `true` lets an
  inherited non-empty value win; use it where a caller's override should
  survive (the XDG entries). `"ssh"` lets an inherited value win only inside
  an ssh session, so a forwarded `ssh -A` agent survives while any other
  inherited agent is replaced; environment.d renders it like `false`.

## Recipes

**A tool keeps creating a dot-directory in ~.** Check first whether its
variable is already registered (`grep -n NAME home/.chezmoidata/environment.toml`);
if it is, the problem is delivery, see the next recipe. Otherwise add an entry
under "Per-Tool XDG Relocation", alphabetical but below anything it references,
pointing at `${XDG_DATA_HOME}/<pkg>` (or `XDG_CONFIG_HOME`, `XDG_STATE_HOME`,
`XDG_CACHE_HOME`, by what the directory holds). `~/.local/var/<pkg>` is a dead
convention; never introduce it. Outside the registry, where the XDG variables
may be unset, fall back to `$HOME/.local/share/<pkg>`, or in a chezmoi
template `joinPath .chezmoi.destDir ".local" "share" "<pkg>"`. If the
directory should exist ahead of the tool, follow the placeholder convention:
`home/dot_local/share/<pkg>/.chezmoiignore` (`private_<pkg>` for 0700, as
gnupg). Moving the user's existing data is a manual step: say so, don't do
it.

**A program doesn't see a registered variable.**
1. `chezmoi diff ~/.config/environment.d ~/.config/zsh/env`: an unapplied
   change is the usual cause.
2. Compare `tr '\0' '\n' </proc/<pid>/environ`, `systemctl --user
   show-environment` and a TTY shell, against the table at the top: which
   output should have reached it?
3. Processes keep the environment they started with; after an apply, the
   user re-logs in (or restarts the unit).
4. Some programs override the variable with their own setting (an IDE's
   "Gradle user home", say).

**Change, move or remove a variable.** Edit or delete the entry, then
`git grep` both its name and its old literal path. Other files may spell the
path out and must move with it: socket units (`ListenStream=` in
`ssh-agent-*.socket`), source directories that deploy into it
(`home/dot_local/share/<pkg>/`, placeholder `.chezmoiignore`s included),
wrappers' fallbacks (`wrap/claude` reads `CLAUDE_CONFIG_DIR`). Anything that
references the variable, a later entry or a `PATH` item, must change first or
the resolver fails. Running sessions keep the old value until re-login.

**Add a setting that is not a path** (`GOPROXY=off`). Same section as the
relocations, which already holds `DO_NOT_TRACK` and `GH_TELEMETRY`.

**Add a `PATH` directory.** Entries are listed highest precedence first.
Reference the tool's home (`${CARGO_HOME}/bin`) rather than spelling the path,
and limit it with `{ dir = ..., os = [...] }` when one OS should not get it.
zsh dedupes with `typeset -gU path`; environment.d prepends once per session.

**Add a consumer** (Nushell, say). First ask whether inheritance already
covers it: a nu started from zsh, Hyprland or systemd already has every
variable, and a renderer is only needed if nu becomes a login shell (TTY,
ssh, Termux); the spec records Nushell as deliberately not a consumer yet.
If it is needed, write a renderer in `home/.chezmoitemplates/environment/`
over `includeTemplate "environment/resolve" . | fromJson`. nu does not expand
`${NAME}`, so the renderer must translate references (to
`$"($env.NAME)/x"`), treat `PATH` as a list, and treat empty as unset for
`inherit = true`. Then a target file that includes it, a `check_<consumer>`
section in the check script, the target in `.husky/pre-commit`'s `env_files`,
any tool in the CI job, and the consumer list in the data header. The data
itself should need no change; if it seems to, stop and raise it. Scope
`nushell`.

**The check says a system file sorts after the systemd output.**
environment.d merges every directory's files by name and the last assignment
wins, so the output must sort last. `zz-` sorts after every numbered file
(Debian's and Arch's `99-environment.conf`, Ubuntu's `990-snapd.conf`), but a
system file such as `zzz-foo.conf` beats it. See what that file sets, then
rename the output to sort after it under `LC_ALL=C`: `git mv` the template,
add the old target to `home/.chezmoiremove` (the check enforces it), update
`systemd_conf=` in the check script, and `git grep` the old name (data
header, the zsh template's comment, `AGENTS.md`, this skill).

## Traps

- **environment.d is not `exact_`.** A renamed or deleted file there stays
  deployed, still overriding, unless `home/.chezmoiremove` lists it; the check
  fails on any file ever deleted from that directory and not listed. It also
  expects exactly one file there, so a per-service `.conf` belongs in that
  unit's `Environment=` instead.
- **The zsh output runs for every zsh**, including those scp, rsync and
  git-over-ssh start, which read stdout as protocol data. Parameter expansion
  and builtins only; nothing on stdout.
- **Keep the XDG entries**, even though systemd sets them in a graphical
  session: a TTY, a rescue shell, a container or Termux has nothing else, and
  every path would collapse to one like `/cargo`. Keep them `inherit = true`
  so an inherited value still wins.
- **zsh reads `/etc/zsh/zshenv` even with `-f`.** A test of a "bare" zsh must
  clear what it sets.
- **Raw `*.tmpl` files are Go template text.** The hook's and CI's `zsh -n`
  and `shuck` skip them; the check lints the rendered output instead.

## Verify

1. Run `.github/scripts/check-environment` (sections `resolve`, `systemd`,
   `zsh`, `ssh`; none given runs all). It needs `chezmoi`, `jq`, `zsh`,
   `shuck`, git history and systemd's
   `30-systemd-environment-d-generator`, so not Termux. Under the Android
   fixture `/etc/zsh/zshenv:22: command not found: id` on stderr is host
   noise. The pre-commit hook runs it when a registry file is staged; CI runs
   it on every PR and push to `main`.
2. **Some current values are pinned in the check as fixtures**: `PAGER`,
   `CARGO_HOME`, `XDG_RUNTIME_DIR`, `SSH_AUTH_SOCK`, the five leading XDG
   entries, the `PATH` list in `check_resolve` (the same for both OSes) and
   the `PATH` prefix in `check_systemd`. Changing one of those values is
   meant to fail: update the expectation in the same commit, per OS when an
   entry is OS-limited. Never delete the assertion to get green.
3. To read one output:
   `chezmoi --source . execute-template < home/dot_config/environment.d/zz-user-environment.conf.tmpl`,
   with `--override-data '{"chezmoi":{"os":"android"}}'` for Termux.
4. Never `chezmoi apply` against the real home to test; use the
   `chezmoi-sandbox` skill, and reuse one sandbox with `--in DIR`. Each fresh
   sandbox evaluates the externals, which call the GitHub API unauthenticated
   and can hit its rate limit (403). Then wait, or ask the user before handing
   chezmoi a token (`GITHUB_TOKEN`).
5. Before the user's own `chezmoi apply`, suggest `chezmoi diff`.

## Commits

`chezmoi` for the data file and shared templates; `systemd`, `zsh` or `ssh`
for one consumer; combined with `/` when a change spans several. Check script
changes have gone in as `test:`, hook and workflow changes as `ci:`, both
unscoped. Check `.commitlintrc.mts` before inventing a scope.

<!-- vim:set expandtab shiftwidth=2 filetype=markdown: -->
