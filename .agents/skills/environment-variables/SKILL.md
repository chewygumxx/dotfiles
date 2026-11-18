---
name: environment-variables
description: >-
  How this dotfiles repo defines environment variables: one registry,
  home/.chezmoidata/environment.toml, rendered into systemd environment.d, zsh
  and ~/.ssh/config. Use before adding, changing, moving or removing any
  environment variable, a PATH entry, an XDG directory or a tool's home
  (CARGO_HOME, GNUPGHOME, CLAUDE_CONFIG_DIR, ...), before touching
  ~/.config/environment.d, zsh's env/ files or SSH_AUTH_SOCK/IdentityAgent,
  when relocating a tool out of ~ for XDG compliance, when a variable differs
  between a terminal and a desktop-launched app, or when
  .github/scripts/check-environment fails.
ctime: 2026-11-18
mtime: 2026-11-18
spdx: GPL-3.0-only
title: "Environment variables"
tags:
  - claude
  - skill
  - chezmoi
  - environment
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/.agents/skills/environment-variables/SKILL.md
   -
   -->

# Environment variables

Every environment variable that more than one consumer needs is defined once,
in `home/.chezmoidata/environment.toml`, and generated into each consumer.
Before this registry the same variables were hand-written in systemd's
`environment.d`, zsh's `env/` and `~/.ssh/config`, and the copies drifted:
different `PAGER`s, different `PATH`s, tool homes a desktop app never saw, the
Linux ssh socket set on Android. The registry exists so that a value is changed
in one place and cannot drift again. Hand-editing a generated consumer undoes
that, so don't.

Design and rationale:
`docs/spec/2026-11-18_environment-variable-registry-design.md`.

## Does the variable belong in the registry?

It belongs when **more than one consumer needs it and ordinary inheritance
cannot be relied on to deliver it**. In practice: anything a program might read
whether it was started from a shell, by systemd, by Hyprland, over ssh or on
Termux. XDG directories, `PATH`, `EDITOR`/`PAGER`/`BROWSER`, a tool's
home or cache directory, `SSH_AUTH_SOCK`.

It stays with its one program when only that program reads it: fzf and zoxide
options in `home/dot_config/zsh/exact_util/`, `Environment=` lines in a single
systemd unit, WezTerm's `TERMINFO`, a wrapper's local `CLAUDE_CODE_*`. Runtime
values chezmoi cannot know at apply time (`CHEZMOI_SOURCE_DIR`) stay with
`~/.local/bin/chezmoi-environment`.

When unsure, ask: if a desktop-launched app and a TTY shell disagreed on this
value, would something break or write to the wrong place? If yes, registry.

## Where things live

| Path | Role |
| --- | --- |
| `home/.chezmoidata/environment.toml` | The registry. Its header documents the schema; read it. |
| `home/.chezmoitemplates/environment/resolve` | Picks each value for `.chezmoi.os`, fills `${UID}`, validates, emits JSON. |
| `home/.chezmoitemplates/environment/systemd` | Renders environment.d syntax. |
| `home/.chezmoitemplates/environment/zsh` | Renders zsh. |
| `home/dot_config/environment.d/zz-user-environment.conf.tmpl` | systemd consumer, the only file in that directory. |
| `home/dot_config/zsh/exact_env/00-environment.env.zsh.tmpl` | zsh consumer, sourced first by `.zshenv` for every zsh. |
| `home/private_dot_ssh/config.tmpl` | `IdentityAgent` from `SSH_AUTH_SOCK`. |
| `.github/scripts/check-environment` | Renders every consumer for Linux and Android and proves they agree. |

## The schema, briefly

```toml
[[environment.variables]]
name    = "CARGO_HOME"
value   = "${XDG_DATA_HOME}/cargo"
comment = "Why, if it isn't obvious. Rendered above the line in every output."

[[environment.variables]]
name    = "SSH_AUTH_SOCK"
os      = { linux = "${XDG_RUNTIME_DIR}/ssh-agent-protonpass.socket", android = "${XDG_RUNTIME_DIR}/ssh-agent.socket" }
inherit = "ssh"

[environment.path]
prepend = ["${HOME}/.local/bin", "${CARGO_HOME}/bin", { dir = "${PREFIX}/opt/bin", os = ["android"] }]
```

- **Order is evaluation order.** A value may reference only `HOME`, `PREFIX`
  (Termux), `UID`, or a variable defined *above it* on the same OS. The
  resolver fails on a forward reference, naming the variable.
- **Value syntax is deliberately tiny:** literal text and `${NAME}`. No bare
  `$`, no quotes, backslashes or backticks, no `:-` written by hand. This is
  the subset zsh, systemd's environment.d and ssh_config all expand the same
  way, which is what lets one string render into all three. References stay
  unexpanded until runtime, so an inherited `XDG_DATA_HOME` still moves
  everything under it. `${UID}` is the one exception: chezmoi fills it in,
  because environment.d has no `UID`.
- **`os`** overrides `value` per `.chezmoi.os` (`linux`, `android`). An OS
  with neither gets no variable at all.
- **`inherit`**: `false` (default, always set), `true` (an inherited
  non-empty value wins; used for the XDG variables), `"ssh"` (an inherited
  value wins only inside an ssh session; used for `SSH_AUTH_SOCK` so a
  forwarded `ssh -A` agent survives while any other inherited agent is
  replaced).

## Common changes

**Relocate a tool for XDG compliance.** Add an entry under "Per-Tool XDG
Relocation", alphabetical within that section but below every variable it
references. Prefer, in order: `${XDG_DATA_HOME}/<pkg>` (or `XDG_CONFIG_HOME`,
`XDG_STATE_HOME`, `XDG_CACHE_HOME`, by what the directory actually holds), then
`${HOME}/.local/share/<pkg>`. Inside a chezmoi template where neither works,
use `joinPath .chezmoi.destDir ".local" "share" "<pkg>"`. `~/.local/var/<pkg>`
is a dead convention; never introduce it. Moving the tool's existing data on
disk is a separate, manual step: say so rather than doing it.

**Change a value.** Edit the entry. Both outputs and `~/.ssh/config` follow on
the next apply.

**Add a `PATH` directory.** Add it to `[environment.path].prepend`, after any
variable it references is defined. zsh dedupes with `typeset -gU path`;
environment.d prepends once per session.

**Remove a variable.** Delete the entry. Nothing else is needed: the consumer
files are regenerated without it.

**Add a new consumer** (Nushell, say). Write a renderer in
`home/.chezmoitemplates/environment/` that consumes
`includeTemplate "environment/resolve" . | fromJson`, a target file that
includes it, and a `check_<consumer>` section in the check script. The data
file should need no change; if it seems to, the schema is wrong, so stop and
raise it.

## Traps that already bit

- **environment.d sort order.** Files from every directory are merged by name
  and the last assignment wins. Debian and Arch ship `99-environment.conf`
  (`/etc/environment`, which on Ubuntu sets an absolute `PATH`) and Ubuntu
  ships `990-snapd.conf`. That is why the output is `zz-`: no number prefix
  sorts last everywhere. Keep it that way; the check asserts it.
- **environment.d is not `exact_`.** Rename or delete a file there and the old
  one stays deployed, still overriding, unless `home/.chezmoiremove` lists it.
  The check fails if any file ever deleted from that source directory is
  missing from `.chezmoiremove`.
- **The zsh output runs for every zsh**, including the ones scp, rsync and
  git-over-ssh start, which read stdout as protocol data. Parameter expansion
  and builtins only; nothing on stdout.
- **Bare contexts have no systemd environment:** a TTY, a rescue shell, a
  container, Termux. The `inherit = true` XDG fallbacks are what stop every
  path collapsing to `/cargo` there. Never drop them.
- **zsh always reads `/etc/zsh/zshenv`, even with `-f`.** Tests of a "bare"
  zsh must clear what it sets.
- **Raw `*.tmpl` files are Go template text.** The zsh lint (`zsh -n`,
  `shuck`) skips them in the hook and CI; the check lints the rendered output
  instead.

## Verify

1. Run `.github/scripts/check-environment` (sections: `resolve`, `systemd`,
   `zsh`, `ssh`). It needs `chezmoi`, `jq`, `zsh` and `shuck`. A stderr line
   `/etc/zsh/zshenv: command not found: id` under the Android fixture is
   host noise. The pre-commit hook runs it whenever a registry file is staged,
   and CI's `Environment Registry` job runs it on every PR.
2. To see one output:
   `chezmoi --source . execute-template < home/dot_config/environment.d/zz-user-environment.conf.tmpl`,
   adding `--override-data '{"chezmoi":{"os":"android"}}'` for Termux.
3. Never `chezmoi apply` against the real home to test. Use the
   `chezmoi-sandbox` skill. Its fresh sandboxes evaluate the externals, which
   call the GitHub API unauthenticated and can hit its rate limit (403); if
   so, apply from a copy of `home/` with the `.chezmoiexternals` directories
   removed, targeting only `~/.config/environment.d`, `~/.config/zsh` and
   `~/.ssh/config`.
4. Before the user's own `chezmoi apply`, suggest `chezmoi diff`.

## Commits

Scope by what changed: `chezmoi` for the data file and shared templates,
`systemd`, `zsh` or `ssh` for a consumer; combine with `/` when one change
spans several. Check `.commitlintrc.mts` before inventing a scope.

<!-- vim:set expandtab shiftwidth=2 filetype=markdown: -->
