---
ctime: 2026-11-18
mtime: 2026-11-18
spdx: GPL-3.0-only
title: Environment Variable Registry Implementation Plan
description: >-
  Task-by-task implementation of the environment variable registry: data file,
  resolver, systemd, zsh and ssh renderers, and the check that keeps them equal.
tags:
  - dotfiles
  - chezmoi
  - environment
  - implementation
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/docs/plan/2026-11-18_environment-variable-registry.md
   -
   -->

# Environment Variable Registry Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Every environment variable that more than one consumer needs is
defined once, in `home/.chezmoidata/environment.toml`, and rendered into
systemd environment.d, zsh and `~/.ssh/config`.

**Architecture:** A resolver template turns the data into a per-OS JSON list
(OS value chosen, `${UID}` baked, syntax and ordering validated). Two
renderer templates turn that list into environment.d and zsh syntax; one
target file per consumer includes its renderer. One check script renders every
output for Linux and Android and proves the outputs agree.

**Tech Stack:** chezmoi 2.74 templates (Go `text/template` + sprig), zsh,
systemd 262 `30-systemd-environment-d-generator`, shuck, GitHub Actions.

**Spec:** `docs/spec/2026-11-18_environment-variable-registry-design.md`

## Global Constraints

- Values contain only literal text and `${NAME}`; `NAME` is `HOME`, `PREFIX`,
  `UID`, or a registry variable defined earlier for the same OS. No `$`
  otherwise, no `"`, `'`, `` ` `` or `\`.
- `${UID}` is replaced by `.chezmoi.uid` at apply time, in every output.
- `inherit`: `false` (default), `true` (keep a non-empty inherited value), or
  `"ssh"` (keep an inherited value only when `SSH_CONNECTION` is set; zsh
  only; environment.d renders it as `false`).
- `PATH` is **prepended** in both outputs; zsh uses `typeset -gU path`.
- `PAGER` is `less -R`.
- On Android `SSH_AUTH_SOCK` is `${XDG_RUNTIME_DIR}/ssh-agent.socket`,
  `XDG_RUNTIME_DIR` falls back on `${PREFIX}/tmp`; on Linux `/run/user/${UID}`
  and `${XDG_RUNTIME_DIR}/ssh-agent-protonpass.socket`.
- The zsh output prints nothing to stdout and runs no commands.
- Never `chezmoi apply` against the real home: use
  `.claude/skills/chezmoi-sandbox/scripts/sandbox-apply.sh`.
- New files copy the header of a sibling of the same type. Commits are
  Conventional Commits, header ≤ 50 chars. Scopes used: `chezmoi` (data and
  templates), `systemd`, `zsh`, `ssh`; workflow and hook changes are type
  `ci`, unscoped.
- 4-space indent, 2 for Markdown; LF; final newline.

## Review Focus

1. A bare TTY, rescue shell, container or Termux with no XDG variables set:
   every path must be under `$HOME`, `/run/user/<uid>` or `$PREFIX`, never
   root-relative. Test in Tasks 2 and 3 (`bare_env_paths`).
2. `ssh -A` login: the forwarded `SSH_AUTH_SOCK` survives; a local shell that
   inherited some other agent gets the Proton Pass socket. Task 3
   (`ssh_inherit`).
3. Nested zsh (terminal in Neovim, zsh script inside zsh): `PATH` must not
   grow. Task 3 (`path_idempotent`).
4. Values containing spaces (`PAGER="less -R"`) must arrive whole in both
   outputs. Tasks 2 and 3 compare `PAGER` exactly.
5. An already-deployed old `~/.config/environment.d/base.conf` (or any of
   the replaced files) must be deleted on apply, or it silently keeps
   overriding. Task 2 (`stale_files_removed`, via sandbox).

---

## File Map

| File | Responsibility |
|---|---|
| `home/.chezmoidata/environment.toml` | The registry: schema header and every shared variable. |
| `home/.chezmoitemplates/environment/resolve` | Data → JSON `{"variables":[...],"path":[...],"byName":{...}}` for `.chezmoi.os`; validation with `fail`. |
| `home/.chezmoitemplates/environment/systemd` | Resolved JSON → environment.d lines. |
| `home/.chezmoitemplates/environment/zsh` | Resolved JSON → zsh lines. |
| `home/dot_config/environment.d/91-environment.conf.tmpl` | Header + `includeTemplate "environment/systemd"`. Replaces all 13 current files. |
| `home/dot_config/zsh/exact_env/00-environment.env.zsh.tmpl` | Header + `includeTemplate "environment/zsh"`. Replaces `base`, `tools`, `ssh` `.env.zsh`. |
| `home/private_dot_ssh/config.tmpl` | `IdentityAgent` from `byName.SSH_AUTH_SOCK`. |
| `.github/scripts/check-environment` | zsh script: renders all outputs for both OSes and asserts. The test suite for every task. |
| `.husky/pre-commit`, `.github/workflows/lint-config.yaml` | Skip raw `*.tmpl` in zsh lint; run the check script. |

Templates in `.chezmoitemplates` are referenced without extension:
`includeTemplate "environment/resolve" .`.

## Check Script Interface

`.github/scripts/check-environment [section...]` (zsh, `emulate -L zsh`,
`setopt err_return no_unset pipe_fail`). Sections: `resolve`, `systemd`,
`zsh`, `ssh`; no argument runs all. Exit 0 when all pass; on failure print
`check-environment: <section>: <what>` to stderr and exit 1.

Helpers every section uses (defined once, at the top):

- `render <os> <template-file>`: `chezmoi --source "$root"
  execute-template --override-data '{"chezmoi":{"os":"<os>"}}' <
  <template-file>`, where `$root` is `git rev-parse --show-toplevel`.
  (`--override-data` overriding `.chezmoi.os` is verified to work on 2.74.1.)
- `resolved <os>`: `render` of `{{ includeTemplate "environment/resolve" . }}`.
- Fixture homes: Linux `HOME=/home/t`, `PATH=/usr/bin`; Android
  `HOME=/data/data/com.termux/files/home`,
  `PREFIX=/data/data/com.termux/files/usr`, `PATH=$PREFIX/bin`.
- `expand_systemd <file> [VAR=val...]`: copy to a temp
  `$XDG_CONFIG_HOME/environment.d/`, run
  `env -i HOME=/home/t PATH=/usr/bin [VAR=val...] XDG_CONFIG_HOME=<tmp>
  /usr/lib/systemd/user-environment-generators/30-systemd-environment-d-generator`,
  print `NAME=value` lines.
- `expand_zsh <os> <file> [VAR=val...]`: `env -i <fixture> [VAR=val...] zsh -f
  -c 'source "$1"; shift; for n; print -r -- "$n=${(P)n}"' zsh <file> <names>`,
  names taken from `resolved <os>` plus `PATH`.

CI provides chezmoi as `mise exec "$CHEZMOI" -- chezmoi`, with
`CHEZMOI: aqua:twpayne/chezmoi@2.74.1` beside the existing `SHUCK` env; the
script calls plain `chezmoi`, so CI runs it under `mise exec "$CHEZMOI" "$SHUCK"
--`.

---

### Task 1: Registry data and resolver

**Files:**
- Create: `home/.chezmoidata/environment.toml`
- Create: `home/.chezmoitemplates/environment/resolve`
- Create: `.github/scripts/check-environment` (helpers + `resolve` section)

**Interfaces:**
- Produces: data key `.environment.variables` (array of `{name, value?, os?,
  inherit?, comment?}`) and `.environment.path.prepend` (array of string or
  `{dir, os = [..]}`).
- Produces: template `environment/resolve`, output JSON:
  `{"variables":[{"name":S,"value":S,"inherit":false|true|"ssh","comment":S}],
  "path":[S],"byName":{NAME:value}}`; values already OS-selected with `${UID}`
  replaced; entries absent on this OS omitted.

- [ ] **Step 1: Write the `resolve` section of the check script**

Assertions, with `jq` on `resolved linux` / `resolved android`:

```text
linux   .byName.XDG_RUNTIME_DIR == "/run/user/<id -u>"
linux   .byName.SSH_AUTH_SOCK   == "${XDG_RUNTIME_DIR}/ssh-agent-protonpass.socket"
android .byName.XDG_RUNTIME_DIR == "${PREFIX}/tmp"
android .byName.SSH_AUTH_SOCK   == "${XDG_RUNTIME_DIR}/ssh-agent.socket"
both    .byName.PAGER == "less -R"; .byName.CARGO_HOME == "${XDG_DATA_HOME}/cargo"
both    first five .variables[].name are XDG_CONFIG_HOME XDG_CACHE_HOME
        XDG_DATA_HOME XDG_STATE_HOME XDG_RUNTIME_DIR, each inherit == true
both    .byName.SSH_AUTH_SOCK's entry has inherit == "ssh"
both    .path == ["${HOME}/.local/bin", "${XDG_DATA_HOME}/mise/shims",
                  "${CARGO_HOME}/bin", "${GOBIN}", "${BUN_INSTALL_BIN}"]
```

Rejection cases, each rendered with an `--override-data` replacing
`environment` and expected to exit non-zero with the variable's name in
stderr:

```text
{"name":"A","value":"${NOPE}"}            unknown reference
{"name":"A","value":"${B}"},{"name":"B","value":"x"}   forward reference
{"name":"A","value":"$HOME/x"}            unbraced $
{"name":"A","value":"say \"hi\""}         quote
{"name":"A","value":"x","inherit":"yes"}  bad inherit
```

- [ ] **Step 2: Run it, expect FAIL** — `.github/scripts/check-environment resolve`
  fails: template `environment/resolve` not found.

- [ ] **Step 3: Write `environment.toml`**

Header as `web-extensions.toml`, documenting every field and the value syntax.
Entries in this order, each with a `comment` carrying the reason from the
current file where one exists (`tools.env.zsh` comments: Bun global dir trap,
`DO_NOT_TRACK=1`, `GOROOT` deliberately unset, npm `_logs`; `codex.conf.tmpl`:
one root):

| name | value (all OS unless noted) | inherit |
|---|---|---|
| `XDG_CONFIG_HOME` | `${HOME}/.config` | true |
| `XDG_CACHE_HOME` | `${HOME}/.cache` | true |
| `XDG_DATA_HOME` | `${HOME}/.local/share` | true |
| `XDG_STATE_HOME` | `${HOME}/.local/state` | true |
| `XDG_RUNTIME_DIR` | linux `/run/user/${UID}`, android `${PREFIX}/tmp` | true |
| `EDITOR` | `nvim` | |
| `VISUAL` | `${EDITOR}` | |
| `PAGER` | `less -R` | |
| `BROWSER` | `firefox` | |
| `TERMCMD` | `wezterm` | |
| `ANDROID_USER_HOME` | `${XDG_DATA_HOME}/android` | |
| `BUN_INSTALL` | `${XDG_DATA_HOME}/bun` | |
| `BUN_INSTALL_BIN` | `${XDG_DATA_HOME}/bun/bin` | |
| `BUN_INSTALL_CACHE_DIR` | `${XDG_CACHE_HOME}/bun` | |
| `BUN_INSTALL_GLOBAL_DIR` | `${XDG_DATA_HOME}/bun/global` | |
| `CARGO_HOME` | `${XDG_DATA_HOME}/cargo` | |
| `CLAUDE_CONFIG_DIR` | `${XDG_DATA_HOME}/claude` | |
| `CODEX_HOME` | `${XDG_DATA_HOME}/codex` | |
| `DO_NOT_TRACK` | `1` | |
| `DOTNET_CLI_HOME` | `${XDG_DATA_HOME}/dotnet` | |
| `GH_TELEMETRY` | `false` | |
| `GNUPGHOME` | `${XDG_DATA_HOME}/gnupg` | |
| `GOPATH` | `${XDG_DATA_HOME}/go` | |
| `GOBIN` | `${GOPATH}/bin` | |
| `GRADLE_USER_HOME` | `${XDG_DATA_HOME}/gradle` | |
| `HERMES_HOME` | `${XDG_DATA_HOME}/hermes` | |
| `IPYTHONDIR` | `${XDG_DATA_HOME}/ipython` | |
| `JUPYTER_CONFIG_DIR` | `${XDG_DATA_HOME}/jupyter` | |
| `NPM_CONFIG_CACHE` | `${XDG_CACHE_HOME}/npm` | |
| `NPM_CONFIG_USERCONFIG` | `${XDG_CONFIG_HOME}/npm/npmrc` | |
| `NUGET_PACKAGES` | `${XDG_DATA_HOME}/NuGetPackages` | |
| `OPENCLAW_STATE_DIR` | `${XDG_DATA_HOME}/openclaw` | |
| `PARALLEL_HOME` | `${XDG_DATA_HOME}/parallel` | |
| `PERL_CPANM_HOME` | `${XDG_CACHE_HOME}/cpanm` | |
| `PI_CODING_AGENT_DIR` | `${XDG_DATA_HOME}/pi/agent` | |
| `PYTHONSTARTUP` | `${XDG_CONFIG_HOME}/python/pythonrc` | |
| `PYTHON_HISTORY` | `${XDG_STATE_HOME}/python/history` | |
| `RUSTUP_HOME` | `${XDG_DATA_HOME}/rustup` | |
| `SQLITE_HISTORY` | `${XDG_STATE_HOME}/sqlite/history` | |
| `SSH_AUTH_SOCK` | linux `${XDG_RUNTIME_DIR}/ssh-agent-protonpass.socket`, android `${XDG_RUNTIME_DIR}/ssh-agent.socket` | `"ssh"` |

`[environment.path] prepend` as asserted in Step 1.

- [ ] **Step 4: Write `environment/resolve`**

Walk `.environment.variables` in order, keeping a `dict` of names defined so
far (seeded with `HOME`, `PREFIX`, `UID`). Per entry: pick
`index .os .chezmoi.os`, else `.value`, else skip. Validate with
`regexMatch` against `^([^$"'\\\x60]|\$\{[A-Za-z_][A-Za-z0-9_]*\})*$`; every
`regexFindAll` reference must be in the dict; `inherit` must be absent,
`true`, `false` or `"ssh"`. On any failure: `fail (printf
"environment.toml: %s: <reason>" .name)`. Then `replace "${UID}"
(toString .chezmoi.uid)`, add to the dict, append to the list. Path entries:
same OS filter (string = all, table = `has .chezmoi.os .os`) and reference
check against the full dict. Emit with `toJson`.

- [ ] **Step 5: Run, expect PASS** — `.github/scripts/check-environment resolve`

- [ ] **Step 6: Commit**

```bash
git add home/.chezmoidata/environment.toml home/.chezmoitemplates .github/scripts/check-environment
git commit -m "feat(chezmoi): Add environment variable registry"
```

### Task 2: systemd environment.d output

**Files:**
- Create: `home/.chezmoitemplates/environment/systemd`
- Create: `home/dot_config/environment.d/91-environment.conf.tmpl`
- Delete: the 13 files in `home/dot_config/environment.d/` (`91-xdg`, `base`,
  `bun`, `claude`, `codex`, `gnupg`, `hermes`, `ipython`, `jupyter`, `npm`,
  `openclaw`, `pi`, `ssh` `.conf.tmpl`)
- Modify: `home/.chezmoiremove` (Removed Everywhere): one line per deleted
  target, `.config/environment.d/<name>.conf  # Now 91-environment.conf`
- Modify: `home/dot_config/systemd/user/ssh-agent-{openssh,protonpass}.service`
  comment lines that cite `environment.d/ssh.conf` → cite the registry
- Test: `systemd` section of `.github/scripts/check-environment`

**Interfaces:**
- Consumes: `environment/resolve` (Task 1).
- Produces: deployed `~/.config/environment.d/91-environment.conf`.

- [ ] **Step 1: Write the `systemd` section**

Render `91-environment.conf.tmpl` for linux, then `expand_systemd`:
- `bare_env_paths`: with no XDG set, every resolved name is present; `PAGER`
  is exactly `less -R`; `CARGO_HOME=/home/t/.local/share/cargo`;
  `XDG_RUNTIME_DIR=/run/user/<id -u>`; `SSH_AUTH_SOCK` ends
  `/run/user/<id -u>/ssh-agent-protonpass.socket`; `PATH` starts
  `/home/t/.local/bin:` and ends `:/usr/bin`; no value field starts with `/`
  unless it starts `/home/t/`, `/run/user/` or `/usr/`.
- `xdg_inherit`: with `XDG_DATA_HOME=/x`, `CARGO_HOME=/x/cargo`.
- `stale_files_removed`: make a sandbox with `sandbox-apply.sh`, write
  `$sandbox/home/.config/environment.d/base.conf`, re-apply with `--in`,
  assert the file is gone.

- [ ] **Step 2: Run, expect FAIL** (template missing).

- [ ] **Step 3: Write `environment/systemd`** — one `# ` comment block per
  entry's `comment`; `NAME="value"`; `inherit == true` →
  `NAME="${NAME:-value}"`; `"ssh"` treated as `false`. Last line
  `PATH="<prepend joined by :>${PATH:+:$PATH}"`.

- [ ] **Step 4: Write `91-environment.conf.tmpl`** — header from
  `91-xdg.conf.tmpl` (filetype `conf`), a "Generated from
  home/.chezmoidata/environment.toml; edit that" block keeping the
  `91-` ordering rationale, then `{{ includeTemplate "environment/systemd" . }}`.
  Delete the 13 old files; add the `.chezmoiremove` lines; fix the two unit
  comments.

- [ ] **Step 5: Run, expect PASS** — `.github/scripts/check-environment resolve systemd`

- [ ] **Step 6: Commit** — `feat(systemd): Render environment.d from registry`

### Task 3: zsh output

**Files:**
- Create: `home/.chezmoitemplates/environment/zsh`
- Create: `home/dot_config/zsh/exact_env/00-environment.env.zsh.tmpl`
- Delete: `home/dot_config/zsh/exact_env/{base,tools,ssh}.env.zsh`
- Modify: `home/dot_config/zsh/exact_env/zsh_dirs.env.zsh:12-17` — the
  "sister file ~/.config/environment.d/base.conf" comment now names
  `00-environment.env.zsh` and the registry
- Modify: `.husky/pre-commit` zsh section and `lint-config.yaml` zsh job:
  exclude `':!**/*.tmpl'` from the raw `zsh -n`/`shuck check` file lists
- Test: `zsh` section of `.github/scripts/check-environment`

**Interfaces:**
- Consumes: `environment/resolve` (Task 1); `expand_systemd` (Task 2).
- Produces: deployed `~/.config/zsh/env/00-environment.env.zsh`.

- [ ] **Step 1: Write the `zsh` section**

For linux and android, render `00-environment.env.zsh.tmpl` to a temp
`*.env.zsh`; `zsh -n` and `shuck check --shell zsh` it (or copy it under a
path the repo `.shuck.toml` maps to zsh). Then `expand_zsh`:
- `bare_env_paths`: same assertions as Task 2 for linux; for android
  `XDG_RUNTIME_DIR=$PREFIX/tmp`, `SSH_AUTH_SOCK=$PREFIX/tmp/ssh-agent.socket`,
  every path under `$HOME`, `$PREFIX`.
- `agrees_with_systemd` (linux): every `NAME=value` line equals Task 2's
  `expand_systemd` output for the same name, with and without
  `XDG_DATA_HOME=/x`.
- `ssh_inherit`: with `SSH_CONNECTION='1 2 3 4' SSH_AUTH_SOCK=/tmp/fwd`,
  `SSH_AUTH_SOCK=/tmp/fwd`; with only `SSH_AUTH_SOCK=/tmp/other`, it is the
  Proton Pass socket.
- `path_idempotent`: sourcing the file twice leaves `PATH` equal to sourcing
  once.
- `silent`: sourcing prints nothing on stdout.

- [ ] **Step 2: Run, expect FAIL.**

- [ ] **Step 3: Write `environment/zsh`** — `# ` comment blocks;
  `export NAME="value"`; `inherit == true` → `: "${NAME:=value}"` newline
  `export NAME`; `"ssh"` → `if [[ -z "${SSH_CONNECTION:-}" || -z
  "${NAME:-}" ]]; then export NAME="value"; fi` (multi-line, carrying
  `ssh.env.zsh`'s comment). Last: `typeset -gU path` and
  `path=(<prepend, each quoted> $path)` (keep `base.env.zsh`'s comment on `-g`
  and `-U`).

- [ ] **Step 4: Write `00-environment.env.zsh.tmpl`** — header from
  `base.env.zsh` (`#!/bin/false`, filetype zsh), generated-file notice, then
  `{{ includeTemplate "environment/zsh" . }}`. Delete the three old files.
  Fix the `zsh_dirs.env.zsh` comment. Add the `*.tmpl` exclusions.

- [ ] **Step 5: Run, expect PASS** — `.github/scripts/check-environment`
  (`resolve systemd zsh`)

- [ ] **Step 6: Commit** — `feat(zsh): Render env from registry`

### Task 4: ssh client config

**Files:**
- Modify: `home/private_dot_ssh/config.tmpl:15-20`
- Test: `ssh` section of `.github/scripts/check-environment`

**Interfaces:**
- Consumes: `environment/resolve` → `byName.SSH_AUTH_SOCK`.

- [ ] **Step 1: Write the `ssh` section** — render `config.tmpl` for linux and
  android; the `IdentityAgent` line equals
  `IdentityAgent "<resolved byName.SSH_AUTH_SOCK>"`; android output still has
  `AddKeysToAgent yes`.
- [ ] **Step 2: Run, expect PASS already.** Today's hand-written lines
  happen to match the registry; this task is a refactor and the test is the
  guard that keeps them matching.
- [ ] **Step 3: Replace the two OS-specific `IdentityAgent` lines** with one
  `IdentityAgent {{ (includeTemplate "environment/resolve" . | fromJson).byName.SSH_AUTH_SOCK | quote }}`,
  leaving `AddKeysToAgent yes` under the android branch.
- [ ] **Step 4: Run, expect PASS.**
- [ ] **Step 5: Commit** — `feat(ssh): Take IdentityAgent from registry`

### Task 5: Wire the check in, sweep, sandbox-verify

**Files:**
- Modify: `.husky/pre-commit`: new `Environment` section; when any staged
  path matches `home/.chezmoidata/environment.toml`,
  `home/.chezmoitemplates/environment/*`, `home/dot_config/environment.d/*`,
  `home/dot_config/zsh/exact_env/*.tmpl`, `home/private_dot_ssh/config.tmpl`
  or `.github/scripts/check-environment`, run the script; skip with a
  message if `chezmoi` is not on PATH, as the other sections do.
- Modify: `.github/workflows/lint-config.yaml`: new `environment` job on
  ubuntu with zsh, `CHEZMOI` and `SHUCK` via mise, running the script.
- Modify: `.agents/skills/web-browsers/SKILL.md:110` — `BROWSER=firefox` now
  lives in `home/.chezmoidata/environment.toml`.
- Modify: `AGENTS.md` — one paragraph under Repository layout: shared
  variables live in `home/.chezmoidata/environment.toml`; never hand-edit
  `environment.d` or `zsh/env` for them; the check script.

- [ ] **Step 1:** `git grep -nE 'base\.env\.zsh|tools\.env\.zsh|ssh\.env\.zsh|environment\.d/(base|bun|claude|codex|gnupg|hermes|ipython|jupyter|npm|openclaw|pi|ssh|91-xdg)\.conf' -- ':!docs/report' ':!docs/note' ':!docs/plan/2026-11-03*' ':!docs/spec' ':!docs/plan/2026-11-18*'`
  — expected: only `.chezmoiremove` lines. Fix anything else.
- [ ] **Step 2:** Add the pre-commit section and the CI job; run
  `actionlint .github/workflows/lint-config.yaml` (expect no output) and
  `sh -n .husky/pre-commit`.
- [ ] **Step 3:** Full sandbox apply: `sandbox-apply.sh`; in the sandbox,
  `env -i HOME=$sandbox/home PATH=/usr/bin zsh -c 'print -r -- $CARGO_HOME $PAGER $SSH_AUTH_SOCK'`
  with `ZDOTDIR=$sandbox/home/.config/zsh` prints sandbox-home paths,
  `less -R`, the Proton Pass socket; `ls $sandbox/home/.config/environment.d`
  lists only `91-environment.conf`.
- [ ] **Step 4:** `.github/scripts/check-environment` — all sections PASS.
- [ ] **Step 5: Commit** — `ci: Check environment registry outputs` (CI +
  hook), and `docs: Document environment registry` (AGENTS.md, skill ref)
  separately.

<!-- vim:set expandtab shiftwidth=2 filetype=markdown: -->
