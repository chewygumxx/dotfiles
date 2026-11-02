---
ctime: 2026-11-03
mtime: 2026-11-03
spdx: GPL-3.0-only
title: Home Directory Inventory
description: >-
  Read-only inventory of home entries outside the home directory specification,
  with proposed placements and the decisions they need.
tags:
  - dotfiles
  - filesystem
  - xdg
  - report
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/docs/reports/2026-11-03-home-directory-inventory.md
   -
   -->

# Home Directory Inventory

Inventory date: 2026-11-03. This report carries out step 1 of the
[implementation plan][plan] and proposes step 2 placements under the
[specification][spec]. Nothing was moved, deleted or reconfigured.

## Probes

All probes were read-only. Secret files were listed by name, size and mode only;
their contents were not read. `~/doc` was not inspected, as a permission rule
denies it.

```sh
ls -A ~                        # top-level entries, sizes, children
find ~/.<app> -maxdepth 2 -printf '%M %u %s %p%l\n'
<tool> --version               # versions below
env | grep -E '^(XDG_|CODEX_|HERMES|OPENCLAW|CLAUDE_CONFIG|BUN_)'
grep -ohE '(/home/chewygumxx|~)/[A-Za-z0-9._/-]+' <app config files>
grep -rnE 'BUN_INSTALL|CODEX_HOME|HERMES_HOME|OPENCLAW_|\.local/cache' \
    home root ~/dev/zsh-config
```

## Top level

The home holds 20 entries. The 41 skill-only directories recorded in the
[research note][research] no longer exist; only `.openclaw/skills` still links
into `~/.agents/skills`.

Entries matching the specification: `.cache`, `.config`, `.local`, `.ssh`,
`arc`, `dev`, `doc`, `net`, `ref`, `scr`, `sec`.

Entries outside it:

| Entry          | Size | Last write | Kind                          |
| -------------- | ---- | ---------- | ----------------------------- |
| `.agents`      | 752K | 2026-11-03 | Shared skill store            |
| `.bun`         | 12M  | 2026-10-02 | Stale download cache          |
| `.codex`       | 1.3G | live       | Mixed application root        |
| `.dsh`         | 76K  | 2026-10-11 | Mixed root, no binary on PATH |
| `.herdr`       | 20K  | 2026-10-16 | Three empty directories       |
| `.hermes`      | 3.1G | live       | Mixed root plus installed SW  |
| `.openclaw`    | 1.6M | live       | Config and state              |
| `eval`         | 73M  | 2026-10-31 | Personal project output       |
| `eval-bakeoff` | 412M | 2026-10-31 | Personal project output       |

## Per-entry findings

### `.herdr`

Contains only `worktrees/{claude-library,dorothy,zsh-config}`, all empty. herdr
0.9.5 defaults to `~/.herdr/worktrees`, but
`home/dot_config/herdr/config.toml.tmpl` now sets `~/dev/_worktree`, agreeing
with worktrunk. These are leftovers from before that setting.

Proposal: remove the empty tree with `rmdir`, then confirm herdr does not
recreate `~/.herdr`.

### `.bun`

Contains only `install/cache` (12M), untouched since 2026-10-02. With no
`BUN_INSTALL` set, Bun 1.4.2 currently keeps its cache, global packages and
global bin under `$XDG_CACHE_HOME/.bun`, so this directory was most likely
written by a launch route that lacked `XDG_CACHE_HOME`.

Proposal: delete it as a reconstructible cache.

A related and larger problem: `~/.cache/.bun/install/global` holds 2.0G of
installed tools, and `~/.cache/.bun/bin` is the entry point for `codex`,
`openclaw` and `skills`. Clearing `~/.cache` would uninstall them. Installed
software belongs in the data root. Proposal: point Bun's global directory and
bin at `~/.local/share/bun/` (or the bin at `~/.local/bin`), set in
`environment.d` so every launch route gets it. The variable names
(`BUN_INSTALL_GLOBAL_DIR`, `BUN_INSTALL_BIN`) must be verified against Bun 1.4.2
first; a probe of the binary was declined during this inventory.

### `.codex`

codex-cli 0.166.0, launched from the Bun global bin and by herdr. Contents mix
credentials (`auth.json`), configuration (`config.toml`, `hooks.json`,
`rules/`), SQLite stores with WAL sidecars (`state_5`, `logs_2`,
`thread_history_1`, `memories_1`, `goals_1`, `queue_1`), transcripts
(`sessions/`, `history.jsonl`), installed code (`packages/`, `plugins/`,
`skills/`) and caches.

Controls: `CODEX_HOME` for the whole root; `sqlite_home` and `log_dir` for
narrower placement (see the research note on `log_dir` side effects).

Dependency: `hooks.json` calls `/home/chewygumxx/.codex/herdr-agent-state.sh` by
absolute path; herdr's integration installer wrote it. Relocation must rewrite
that path or rerun the installer against the new root.

Proposal: `CODEX_HOME=~/.local/var/codex`. Four Codex agents are currently live
in herdr, so every one must be stopped before the move.

### `.hermes`

Hermes Agent v0.22.2. The largest and riskiest root: credentials (`.env`,
`auth.json`), configuration (`config.yaml`, `SOUL.md`), SQLite stores
(`state.db`, `kanban.db`, `shared-state.db`), logs, sessions, caches, a socket
(`gateway.sock`), and installed software (`hermes-agent/`, Node and npm under
`tools/`).

Control: `HERMES_HOME`. The unmanaged unit
`~/.config/systemd/user/hermes-gateway.service`, written by the Hermes
installer, sets `HERMES_HOME`, `WorkingDirectory`, `ExecStart` and `PATH` under
`~/.hermes`. `config.yaml` also names about 20 paths beneath `~/.hermes`
literally.

Proposal: `~/.local/var/hermes`, done last, after confirming whether the
installer regenerates the unit and whether `config.yaml` paths follow
`HERMES_HOME` or must be rewritten.

### `.openclaw`

OpenClaw 2026.10.9. `openclaw.json` (plus three `.bak` copies),
`state/openclaw.sqlite`, `agents/main`, `workspace/` (persona Markdown),
`migration/`, and `skills/` holding relative links
(`../../.agents/skills/<name>`).

Controls: `OPENCLAW_CONFIG_PATH` and `OPENCLAW_STATE_DIR`. `openclaw.json`
embeds `/home/chewygumxx/.openclaw/workspace` and `.../agents/main/agent`.

Proposal: `OPENCLAW_CONFIG_PATH=~/.config/openclaw/openclaw.json` and
`OPENCLAW_STATE_DIR=~/.local/var/openclaw`. The relative skill links break once
moved and must be recreated, and the embedded paths rewritten.

### `.agents`

The canonical store maintained by `skills` 1.7.4, written today. Codex, Copilot
CLI and Gemini CLI read `~/.agents/skills` as a cross-runtime location, so it
cannot be relocated without breaking them.

Proposal: keep it and record it as a compatibility exception in the spec.

### `.dsh`

No `dsh` command is on `PATH`. One profile, one session for a deepseek-harness
workspace beneath `~/doc`, storages, and `.credentials.yaml`. Last written
2026-10-11.

Proposal: decide whether the harness is still used. If not, archive under `arc/`
or delete; if so, identify its path control.

### `eval` and `eval-bakeoff`

Model evaluation runs, configs and results. These are personal material, not
application storage, and belong under `dev/` (or `scr/` if temporary). Configs
inside may embed absolute paths; check before moving.

## Cache root drift

The specification makes `~/.cache` the cache root, but two other trees remain in
use:

- `~/.local/cache` is live: chezmoi, zsh, yazi, wezterm, fsh, fontconfig, mesa,
  mozilla. Repo-side writers include `cache_dir` in
  `home/dot_config/yazi/yazi.toml`, `TUNNEL_LOGDIRECTORY` in
  `home/dot_config/systemd/user/cloudflared.service` (logs, so state rather than
  cache), the fallback in `home/.chezmoi.toml.tmpl` line 26, and the source
  entries under `home/dot_local/cache/` (cpanm, json-weather, npm, yazi, zsh).
  zsh-config's own references live in that repository.
- `~/.cache/.cache` is a nested tree of about 110 entries, apparently an earlier
  cache root moved inside the current one. It includes state-like items
  (`crontab`, `.bluetoothctl_history`, `_logs`) that need classification before
  the tree is deleted.

`~/.local/opt/tor-browser` is installed software in a directory the
specification does not name; either add `.local/opt` to the specification or
move it under `.local/share`.

## Suggested order

1. `.herdr` and `.bun`: stale, empty or reconstructible.
2. `eval`, `eval-bakeoff`, `.dsh`: user decisions, no configuration.
3. Bun global directory relocation, which moves the `codex` and `openclaw` entry
   points before their roots move.
4. `.openclaw`, then `.codex`.
5. Cache root consolidation, as its own change.
6. `.hermes`, last.

Each migration after step 2 gets its own task plan and report, per the plan's
steps 3 to 6.

## Progress

Rulings by the user, 2026-11-03: `.bun`, `.herdr` and `.dsh` may be deleted;
Hermes and OpenClaw need their own research before any move; every
`.local/cache` reference in this repository is to become `.cache`.

- `.bun`, `.herdr` and `.dsh`: deleted.
- Cache references in this repository now point at `~/.cache`: the chezmoi
  `cacheDir` fallback, yazi's `cache_dir`, cloudflared's log directory (`%C`)
  and the source tree, now `home/dot_cache/`. The live `~/.local/cache` and
  `~/.cache/.cache` trees are untouched.
- Bun globals: moved; see the [relocation report][bun].
- Codex: next. Every running Codex session must stop first.
- Hermes, OpenClaw: deferred for research.

A new entry, `.remember`, appeared at 07:25, created by the Claude Code
`remember` plugin 0.33.0. Its machine config (`~/.remember/config.json`) and
store root (`~/.remember/tmp`, and `~/.remember/<slug>` in external storage
mode) are fixed paths with no documented override, so it joins Hermes and
OpenClaw as needing research.

[bun]: 2026-11-03-bun-global-relocation.md
[spec]: ../specs/2026-11-03-home-directory-structure-design.md
[plan]: ../plans/2026-11-03-home-directory-structure.md
[research]: ../notes/2026-11-03_home-directory-research.md

<!-- vim:set expandtab shiftwidth=2 filetype=markdown: -->
