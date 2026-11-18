---
name: managing-session-environment
description: >-
  Manages this dotfiles repo's shared session environment through one chezmoi
  registry (home/.chezmoidata/environment.toml), rendered into systemd
  environment.d, zsh and ~/.ssh/config. Use before adding, changing, moving or
  removing a session-wide environment variable, an XDG directory, a tool's
  home (CARGO_HOME, GNUPGHOME, ...) or a PATH entry, including OS-specific
  ones; when a tool keeps creating a dot-directory in ~; when a variable is
  missing from zsh, a systemd service or a Hyprland-launched app; before
  touching ~/.config/environment.d, zsh's env/ files or
  SSH_AUTH_SOCK/IdentityAgent; when adding a shell (Nushell) as a consumer; or
  when .github/scripts/check-environment fails. Not for a CI workflow's env:,
  a project's .env, or a setting confined to one program's own config.
ctime: 2026-11-18
mtime: 2026-11-18
spdx: GPL-3.0-only
title: "Managing the session environment"
tags:
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
`environment.d`, zsh's `env/` and `~/.ssh/config`, and the copies drifted.
Hand-editing a generated consumer brings that back, so change the registry.

References, one level deep: the registry's own header (the schema),
`docs/spec/2026-11-18_environment-variable-registry-design.md` (the design;
where it differs from the code, the code wins), and
`.github/scripts/check-environment` (the verifier).

## Which output reaches what

| Output | Reaches | Source |
| --- | --- | --- |
| zsh | Every zsh: terminals, scripts, ssh logins, TTYs, Termux. On chewytop also Hyprland and everything it execs, because ly's setup runs the login through zsh (observed: Hyprland's environment carries the zsh values). | `home/dot_config/zsh/exact_env/00-environment.env.zsh.tmpl` |
| systemd | The systemd user manager and the units it starts: waybar, portals, D-Bus-activated apps, `systemd-run`. Deployed only where chezmoi finds `systemctl`. | `home/dot_config/environment.d/zz-user-environment.conf.tmpl` |
| ssh | The `IdentityAgent` line of `~/.ssh/config`, rendered from `SSH_AUTH_SOCK`. | `home/private_dot_ssh/config.tmpl` |

Hosts: `linux` is chewytop (the laptop), `android` is chewytele (Termux, no
`systemctl`, so zsh and ssh only). The registry selects by `.chezmoi.os`
alone; it cannot single out one Linux host.

The templates under `home/.chezmoitemplates/environment/` do the work:
`resolve` picks each value for the OS, fills `${UID}`, validates and emits
JSON; `systemd` and `zsh` render that.

## Does the variable belong in the registry?

Use the registry when a value must reach more than one launch context (a
shell, a systemd unit, Hyprland, ssh, Termux) and ordinary inheritance cannot
be relied on to carry it. That is why `GRADLE_USER_HOME`, `GH_TELEMETRY` and
`DO_NOT_TRACK` are here although one program reads each.

Leave it local when one launch context is enough: an interactive-zsh option
(`FZF_DEFAULT_OPTS` in `exact_env/fzf.env.zsh`, zoxide in
`exact_util/zoxide.rc.zsh`), one unit's `Environment=`, WezTerm's `TERMINFO`,
a wrapper's `CLAUDE_CODE_*`. Runtime values (`CHEZMOI_SOURCE_DIR`) stay with
`~/.local/bin/chezmoi-environment`. A tool default that the tool's own config
holds for every launch (`go env -w`) can live there instead; when the user
asks for a session export, use the registry.

## The schema

```toml
[[environment.variables]]
name    = "CARGO_HOME"
value   = "${XDG_DATA_HOME}/cargo"
comment = "Why, if not obvious. Rendered above the line in the zsh and systemd outputs."

[[environment.variables]]
name    = "SSH_AUTH_SOCK"
os      = { linux = "${XDG_RUNTIME_DIR}/ssh-agent-protonpass.socket", android = "${XDG_RUNTIME_DIR}/ssh-agent.socket" }
inherit = "ssh"

[environment.path]
prepend = ["${HOME}/.local/bin", "${CARGO_HOME}/bin", { dir = "${XDG_DATA_HOME}/npm/bin", os = ["linux"] }]
```

- **Order is evaluation order.** A value may reference `HOME`, `PREFIX`
  (Termux), `UID`, or a variable defined above it on the same OS; anything
  else fails the resolver, naming the variable.
- **A value is literal text and `${NAME}`.** No bare `$`, quotes,
  backslashes or backticks: that subset expands identically in zsh,
  environment.d and ssh_config, so one string renders into all three, and an
  inherited `XDG_DATA_HOME` still moves everything under it at runtime.
  `${UID}` alone is filled in by chezmoi, as environment.d has no `UID`.
- **Write `${HOME}`, never `~`.** The resolver accepts `~`, but zsh and
  environment.d leave it literal inside the quotes the renderers emit, so
  `~/x` becomes a directory named `~`. Translate a user's `~/...`.
- **`os`**: a key matching `.chezmoi.os` overrides `value`; with no match,
  `value` applies if present, otherwise the variable is omitted on that OS.
  Keys are not validated, so a typo (`linx`) silently falls through. A `PATH`
  entry's `os` is a list (`["linux"]`).
- **`inherit`**: `false` (default) sets the value in every shell, nested ones
  included, so `PAGER=cat zsh -c ...` gets the registry `PAGER` back. `true`
  keeps a non-empty inherited value (the XDG entries), so a caller's override
  survives. `"ssh"` keeps an inherited value only when `SSH_CONNECTION` is
  set, in zsh; environment.d always assigns the registry value.

## Recipes

**A tool keeps creating a dot-directory in ~.** `grep -n` the tool's variable
in the registry first. If it is there (`GRADLE_USER_HOME` is), the problem is
delivery or an override: see the next recipe. Otherwise add an entry under
"Per-Tool XDG Relocation", alphabetical but below anything it references,
pointing at `${XDG_DATA_HOME}/<pkg>` (or `XDG_CONFIG_HOME`, `XDG_STATE_HOME`,
`XDG_CACHE_HOME`, by what the directory holds). Never `~/.local/var/<pkg>`, a
dead convention. To pre-create the directory, add
`home/dot_local/share/<pkg>/.chezmoiignore` (`private_<pkg>` for 0700, as
gnupg). Moving the user's existing data is manual: say so, don't do it.

**A process doesn't see a registered variable.**
1. Compare what this checkout would deploy with what is deployed. The
   configured chezmoi source may be another checkout, and a directory target
   shows nothing without `--recursive`, so from the repo root run
   `chezmoi --source . --use-builtin-diff --no-pager diff --recursive ~/.config/environment.d ~/.config/zsh/env ~/.ssh/config`.
2. Read the variable from the process's own startup environment
   (`tr '\0' '\n' </proc/<pid>/environ | grep NAME`) and trace its launcher
   against the table above. Compare with a fresh zsh and
   `systemctl --user show-environment`.
3. A process keeps the environment it started with. For a systemd unit, run
   `systemctl --user daemon-reload` (re-runs the environment generators),
   then restart the unit. For Hyprland-launched apps, a new login.
4. The program may override the variable itself (an IDE's "Gradle user
   home").

**Change, move or remove a variable.** Edit or delete the entry, then
`git grep` both its name and its old literal path, and move every hard-coded
copy with it: socket units (`ListenStream=` in `ssh-agent-*.socket`), source
directories deploying into it (`home/dot_local/share/<pkg>/`), wrappers'
fallbacks (`wrap/claude` reads `CLAUDE_CONFIG_DIR`). A later entry or a
`PATH` item referencing it must change first, or the resolver fails.

**Add a session export** (`GOPROXY=off` everywhere). A plain entry, no `os`,
default `inherit`, in the "Per-Tool XDG Relocation" section, which already
holds the non-path settings `DO_NOT_TRACK` and `GH_TELEMETRY`.

**Add a `PATH` directory.** Entries are listed highest precedence first.
Reference the tool's home (`${CARGO_HOME}/bin`) rather than spelling the path.
`{ dir = ..., os = ["linux"] }` limits it to Linux, which is every Linux host,
not chewytop alone; telling Linux hosts apart would need hostname support in
the resolver. zsh deduplicates `path`; the systemd renderer prepends without
deduplicating.

**Add a consumer** (Nushell). A nu started from zsh, Hyprland or systemd
already inherits every variable; a renderer is needed only where nu itself is
the login shell (TTY, ssh, Termux). Write one in
`home/.chezmoitemplates/environment/` over
`includeTemplate "environment/resolve" . | fromJson`. nu does not expand
`${NAME}`, so translate references (to `$"($env.NAME)/x"`), treat `PATH` as
a list and empty as unset for `inherit = true`. Then a target file including
it, a `check_<consumer>` section in the verifier, the target in
`.husky/pre-commit`'s `env_files`, any tool in the CI job, and the consumer
list in the registry header. Reuse the schema; if it cannot express what nu
needs, change it and say why.

**The verifier says a system file sorts after the systemd output.**
environment.d reads every directory's files by name and later assignments to
the same name win. The repo requires its file to sort after every system file
whether or not they overlap, so `zzz-foo.conf` fails the check even if it
sets unrelated names; read it anyway. Rename the output to sort after it under
`LC_ALL=C`: `git mv` the template, add the old target
(`.config/environment.d/zz-user-environment.conf`) to `home/.chezmoiremove`,
update `systemd_conf=` in the verifier, and `git grep` the old name (registry
header, the zsh template's comment, `AGENTS.md`, this skill). The verifier's
`.chezmoiremove` check reads git history, which does not hold a pending
rename yet, so check that line yourself before committing.

## Traps

- **`IdentityAgent` overrides `SSH_AUTH_SOCK`.** zsh keeps a forwarded
  `ssh -A` agent in the environment, but an `ssh` using the generated config
  still asks the registry's socket.
- **environment.d is not `exact_`.** A renamed or deleted file there stays
  deployed, still assigning, unless `home/.chezmoiremove` lists it. The
  verifier also expects exactly one file there, so a single unit's variable
  goes in that unit's `Environment=`.
- **The zsh output runs for every zsh**, including those scp, rsync and
  git-over-ssh start, which read stdout as protocol data: parameter
  expansion and builtins only, nothing on stdout.
- **Keep the XDG entries, as `inherit = true`.** A TTY, rescue shell,
  container or Termux has no systemd session to set them, and every path would
  collapse to one like `/cargo`.
- **Raw `*.tmpl` files are Go template text.** The hook's and CI's `zsh -n`
  and `shuck` skip them; the verifier lints the rendered zsh instead.

## Verify

Run `.github/scripts/check-environment` (sections `resolve`, `systemd`,
`zsh`, `ssh`) on Linux. It needs `chezmoi`, `jq`, `zsh`, `shuck` with a
writable cache, full git history and systemd's
`30-systemd-environment-d-generator`. It expands the Linux zsh and systemd
outputs and compares them, checks the Android zsh output on its own, and
compares the rendered `IdentityAgent` on both OSes; Android environment.d is
not expanded. Under the Android fixture,
`/etc/zsh/zshenv:22: command not found: id` is host noise. The pre-commit
hook runs it against the working tree when a registry file is staged, and
skips if a tool is missing; CI runs it on every PR and push to `main`.

**Some current values are pinned in the verifier**: `PAGER`, `CARGO_HOME`,
`XDG_RUNTIME_DIR`, `SSH_AUTH_SOCK`, the five leading XDG entries, the `PATH`
list in `check_resolve` (one list asserted for both OSes) and the expanded
`PATH` prefix in `check_systemd`. Changing one of those is meant to fail:
update the expectation in the same commit, per OS once an entry is
OS-limited. Never delete an assertion to get green.

To read one output:
`chezmoi --source . execute-template < home/dot_config/environment.d/zz-user-environment.conf.tmpl`,
with `--override-data '{"chezmoi":{"os":"android"}}'` for Termux. To see a
deployment without touching the real home, run
`skills/chezmoi-sandbox/scripts/sandbox-apply.sh <targets>`. Never
`chezmoi apply` against the real home to test, and suggest `chezmoi diff`
before the user's own apply.

Commit scopes: `chezmoi` for the registry and shared templates; `systemd`,
`zsh` or `ssh` for one consumer; see `AGENTS.md` for the rest.

<!-- vim:set expandtab shiftwidth=2 filetype=markdown: -->
