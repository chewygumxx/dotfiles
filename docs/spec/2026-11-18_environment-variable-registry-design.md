---
ctime: 2026-11-18
mtime: 2026-11-18
spdx: GPL-3.0-only
title: Environment Variable Registry Design
description: >-
  One chezmoi data file as the single definition of every environment variable
  that more than one consumer needs, rendered into systemd environment.d, zsh
  and the ssh client config, with per-OS values.
tags:
  - dotfiles
  - chezmoi
  - environment
  - specification
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/docs/spec/2026-11-18_environment-variable-registry-design.md
   -
   -->

# Environment Variable Registry Design

Status: implemented, 2026-11-18 (PR #6). Where this document and the data
file's header or the templates differ, the code wins.

## Intent

Shared environment variables are written by hand in several places, and the
copies have drifted:

- `PAGER` is `less -RN` in `zsh/exact_env/base.env.zsh` and `less -R` in
  `environment.d/base.conf.tmpl`.
- zsh prepends `~/.local/bin`, mise shims, cargo, go and bun to `PATH`;
  environment.d appends only `~/.local/bin` and bun.
- About twenty tool homes (`CARGO_HOME`, `GOPATH`, `RUSTUP_HOME`,
  `DO_NOT_TRACK`, ...) exist only in zsh, so a program launched by systemd or
  Hyprland never sees them. `BUN_INSTALL`, `HERMES_HOME`, `OPENCLAW_STATE_DIR`,
  `PI_CODING_AGENT_DIR` and `NPM_CONFIG_USERCONFIG` exist only in
  environment.d, so a TTY login, an ssh session or Termux never sees them
  (and npm there never reads `~/.config/npm/npmrc`).
- The Proton Pass socket path is spelled out three times (`ssh.env.zsh`,
  `ssh.conf.tmpl`, `~/.ssh/config`), and `ssh.env.zsh` sets the Linux socket
  on Android too, where `~/.ssh/config` names a different one.
- Comments point at files that no longer exist (`claude.conf.tmpl` cites
  `zsh/env/claude.env.zsh`).

The goal is one authoritative definition under `home/.chezmoidata/`, from which
every consumer's file is generated, so a value is changed once and cannot drift.

## Scope

A variable belongs in the registry when **more than one consumer needs it and
ordinary inheritance cannot be relied on to deliver it**. That covers:

- the XDG base directories, including `XDG_RUNTIME_DIR`;
- `PATH` additions;
- general defaults: `EDITOR`, `VISUAL`, `PAGER`, `BROWSER`, `TERMCMD`;
- per-tool home and relocation variables (everything now in
  `tools.env.zsh` and the per-tool `environment.d/*.conf.tmpl` files);
- `SSH_AUTH_SOCK`.

### Non-goals

- Variables with a single consumer stay where they are: fzf and zoxide options
  in `zsh/exact_util/`, `Environment=` lines in `cloudflared.service`,
  WezTerm's `TERMINFO` in `terminfo.lua`, `CLAUDE_CODE_PROJECT_DIR_NAME` in
  `wrap/claude`.
- `CHEZMOI_SOURCE_DIR` and `CHEZMOI_WORKING_TREE` are only known at runtime
  and stay with `~/.local/bin/chezmoi-environment`.
- Programs that merely *read* a registry variable (luarocks, npmrc, yay,
  waybar, `rc/directory.rc.zsh`, ...) are not rewritten. Their reads keep
  working because the registry now delivers the variable everywhere.
- `root/` stays inert reference material; `root/etc/zsh/zshenv` and
  `root/etc/zshenv` keep their hand-written XDG/`ZDOTDIR` bootstrap.
- `.zshenv` keeps its own `XDG_CONFIG_HOME` fallback: it needs it to find
  `env/` before any registry file has run.
- Nushell (`env.nu` is an unmodified stub) is not a consumer yet. Adding a
  renderer for it later must need no change to the data.

### Anti-goals

- A registry that still needs a hand edit in a consumer file to change a
  value: then it is one more copy, not the source.
- Losing the runtime fallbacks the zsh files were deliberately given. A bare
  TTY, a rescue shell, a container or Termux, with no systemd user
  environment, must still get correct, non-root-relative paths.
- Baking the home directory into values where the consumer can expand it
  itself.

## Approaches

| | Approach | Trade-off |
|---|---|---|
| **A** | Values written with `${VAR}` references, expanded by each consumer at runtime. | Values are restricted to the syntax all consumers share; keeps runtime fallbacks. |
| B | chezmoi resolves every value to an absolute path at apply time. | Simplest data and templates, but ignores a changed `XDG_*` at runtime and loses the fallbacks. |
| C | chezmoi renders one environment.d file; zsh parses it at startup. | One artifact, but every zsh start parses systemd syntax, Termux included, and ssh still needs its own rendering. |

**Chosen: A.** zsh, systemd environment.d and ssh_config all expand
`${NAME}`; zsh and environment.d also expand `${NAME:-default}`, nested
included (verified against systemd 262's
`30-systemd-environment-d-generator`: `"${UNSET:-${HOME}/.local/share}"`
expands). So one value string renders nearly verbatim into each consumer.

## Design

### Data file

`home/.chezmoidata/environment.toml`, read in templates as `.environment`. Its
header documents the schema, as `web-extensions.toml` does.

```toml
[[environment.variables]]
name    = "XDG_DATA_HOME"
value   = "${HOME}/.local/share"
inherit = true  # An inherited non-empty value wins

[[environment.variables]]
name  = "CARGO_HOME"
value = "${XDG_DATA_HOME}/cargo"

[[environment.variables]]
name    = "SSH_AUTH_SOCK"
inherit = "ssh"
os      = { linux = "${XDG_RUNTIME_DIR}/ssh-agent-protonpass.socket", android = "${XDG_RUNTIME_DIR}/ssh-agent.socket" }

[environment.path]
prepend = [
    "${HOME}/.local/bin",
    "${XDG_DATA_HOME}/mise/shims",
    # ...
]
```

Fields of each `[[environment.variables]]` entry:

- `name`: the variable.
- `value`: the value on every OS.
- `os`: a table keyed by `.chezmoi.os` (`linux`, `android`), overriding
  `value` on that OS. An OS with neither a matching `os` key nor a `value` does
  not get the variable at all.
- `inherit` (default `false`): when to keep a value already in the
  environment and use this one only as the fallback.
  - `true`: whenever the inherited value is non-empty. Set for the XDG
    variables, which is today's `: ${XDG_*:=...}` behaviour.
  - `"ssh"`: only inside an ssh session, i.e. when `SSH_CONNECTION` is set.
    Set for `SSH_AUTH_SOCK`. This keeps today's `ssh.env.zsh` behaviour: a
    forwarded `ssh -A` agent survives, and any other inherited agent is
    replaced. The zsh renderer emits the `SSH_CONNECTION` test. environment.d
    renders it like `false`, because the user manager never runs inside an
    ssh session. *(Builder's-check call: it preserves behaviour that was chosen
    on purpose, rather than silently relaxing it.)*
- An optional comment field, rendered above the variable in each output, so
  the reasons now kept in `tools.env.zsh` comments survive (the Bun
  `XDG_CACHE_HOME` trap, `DO_NOT_TRACK=1` rather than `true`, why `GOROOT` is
  unset). Implemented as `comment`, rendered into zsh and systemd.
- `require = "dir"` *(added after review)*: zsh exports the variable only
  if it names an existing directory and otherwise keeps it as a shell
  variable, so later references still expand. Used for `XDG_RUNTIME_DIR`,
  which the XDG spec wants unset rather than pointing nowhere.

`[environment.path]` holds `prepend`, an ordered list of directories put in
front of the inherited `PATH`. An entry is a string, for every OS, or a table
`{ dir = "...", os = ["android"] }` limited to the OSes listed. No current
entry needs the table form. *(Builder's-check call.)*

### Value syntax

A value is literal text plus `${NAME}` references. `NAME` is `HOME`,
`PREFIX` (Termux), or a registry variable defined **earlier in the file**.

One reference is resolved by chezmoi, not the consumer: `${UID}`. The Linux
`XDG_RUNTIME_DIR` fallback is `/run/user/${UID}`, and environment.d has no
`UID` to expand, so the renderers substitute `.chezmoi.uid` for it in every
output. A uid is fixed per host, so baking it loses nothing, and it is what
`91-xdg.conf.tmpl` and `ssh.conf.tmpl` do today. *(Builder's-check call.)* On
Android, `XDG_RUNTIME_DIR` falls back on `${PREFIX}/tmp`; Termux sets `PREFIX`
for every process it starts, sshd's sessions included.
Array order is evaluation order; both environment.d and zsh evaluate top to
bottom, so the XDG entries come first. Nothing else is allowed: no `$NAME`
without braces, no `:-` written by hand (the renderer emits it from
`inherit`), no command substitution, no quotes, no bare `{` or `}`, no `~`.
`PREFIX` is defined on Android only, and `os` keys must be GOOS values. The
renderer rejects anything else with `fail`, naming the variable.

### Renderers

A shared template per output format under `home/.chezmoitemplates/` reads
`.environment`, selects each entry's value for `.chezmoi.os`, and writes:

| Consumer | Target | Output |
|---|---|---|
| systemd | `~/.config/environment.d/<one file>.conf` | `NAME="value"`; with `inherit`, `NAME="${NAME:-value}"`. `PATH="a:b${PATH:+:$PATH}"`. |
| zsh | `~/.config/zsh/env/<one file>.env.zsh` | `export NAME="value"`; with `inherit`, `: "${NAME:=value}"` then `export NAME`. `typeset -gU path; path=(a b $path)`. |
| ssh | `~/.ssh/config` | `IdentityAgent "<SSH_AUTH_SOCK value for this OS>"`, unexpanded: ssh expands it from its own environment, which both other outputs have filled with every registry variable. `AddKeysToAgent yes` on Android stays hand-written. |

The single environment.d file replaces all thirteen current
`environment.d/*.conf.tmpl`. The single zsh file replaces `base.env.zsh`
and `tools.env.zsh`, and the `SSH_AUTH_SOCK` part of `ssh.env.zsh`. Both
outputs carry the repo header, a "generated from
`home/.chezmoidata/environment.toml`, edit that" notice, and per-variable
comments.

`PATH` changes in two deliberate ways: environment.d now **prepends**, as zsh
always has, and both get the union of today's directories.

### Removals

`environment.d` is not an `exact_` directory, so every replaced
`environment.d/*.conf` is listed in `home/.chezmoiremove`, or the old files
stay deployed and keep overriding. `zsh/exact_env` is `exact_`, so its removed
files go on their own.

## Constraints

- **File order.** `.zshenv` sources `env/*.env.zsh` in glob order. The
  generated zsh file must sort before every other `env/` file in every locale.
  environment.d merges all directories' files sorted by name; the generated
  file must sort after every system-supplied file. That includes
  `99-environment.conf`, Debian's and Arch's link to `/etc/environment`, and
  Ubuntu's `990-snapd.conf`, so no number prefix is safe: the file is
  `zz-user-environment.conf`. *(Corrected after the final review and the
  first CI run: on Ubuntu, `/etc/environment` sets an absolute `PATH`, which
  replaced the prepend.)*
- **Lint.** `.husky/pre-commit` and `lint-config.yaml` run `zsh -n` and
  `shuck check` over every file in the zsh tree; a `.tmpl` there is Go
  template text, not zsh. Template files are excluded from those raw checks,
  and the rendered output is checked instead (e.g. through `chezmoi
  execute-template`), so the generated zsh is still parsed before it ships.
- **Termux.** No systemd, and `XDG_RUNTIME_DIR` is `${PREFIX}/tmp`. The
  environment.d target is already ignored where `systemctl` is absent
  (`home/dot_config/.chezmoiignore`); the zsh and ssh outputs carry the Android
  values.
- **Every zsh start.** The zsh output runs for every zsh, so stdout stays
  silent (it is the protocol stream for scp, rsync and git over ssh), and no
  command is run: parameter expansion and `export` only.
- **Headers.** New files take the header style of their siblings.
- **Commits.** Scopes `chezmoi` for the data file and shared templates,
  `systemd`, `zsh`, `ssh` for a consumer (combinable with `/`). Check
  `scope-enum` for any new one first.

## Initial values

Every variable now defined in either place goes in, with the union of
consumers. Where the two disagree, these are the values taken:

| Variable | zsh today | environment.d today | Registry |
|---|---|---|---|
| `PAGER` | `less -RN` | `less -R` | `less -R`: no line-number gutter |
| `PATH` | 5 dirs, prepended | 2 dirs, appended | zsh's 5, prepended |
| `SSH_AUTH_SOCK` on Android | Proton Pass socket | n/a | `ssh-agent.socket`, as `~/.ssh/config` |

## Verification

- Render for this host with the `chezmoi-sandbox` skill's
  `sandbox-apply.sh`, never against the real home, and diff the sandbox's
  environment.d and zsh output against each other: the same names, the same
  values once expanded.
- Expand the environment.d output with `30-systemd-environment-d-generator`
  under `env -i` with a temporary `XDG_CONFIG_HOME`, and source the zsh output
  under `env -i HOME=...`, with and without the XDG variables set; both must
  give no root-relative path.
- Render the Android branch too, and check its `SSH_AUTH_SOCK`,
  `XDG_RUNTIME_DIR` and ssh `IdentityAgent`.

## Left to the builder

- Output file names, within the ordering constraints.
- The comment field's name, and how the comment renders in each syntax.
- How the lint exclusion and the rendered-output check are wired into the
  hook and CI.
- How the Android branch is rendered on a Linux host for verification.

## Follow-up

An agent skill documenting this architecture follows implementation. Its
source lives in a new top-level `skills/<skill-name>/`, installed for Claude
Code and Codex with:

```sh
npx skills add "./skills/<skill-name>" --agent claude-code codex --yes
```

<!-- vim:set expandtab shiftwidth=2 filetype=markdown: -->
