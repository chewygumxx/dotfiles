---
ctime: 2026-11-03
mtime: 2026-11-03
spdx: GPL-3.0-only
title: Codex Home Relocation
description: >-
  Moving Codex's mixed application root from ~/.codex to ~/.local/var/codex,
  with the paths rewritten inside it and the checks run afterwards.
tags:
  - dotfiles
  - filesystem
  - xdg
  - codex
  - report
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/docs/reports/2026-11-03-codex-home-relocation.md
   -
   -->

# Codex Home Relocation

Migration date: 2026-11-03, codex-cli 0.166.0. Follows the
[inventory][inventory] under the [specification][spec], after the [Bun
relocation][bun] moved the `codex` entry point.

## Placement

`~/.codex` moved to `~/.local/var/codex` (mode 700 parent), selected by
`CODEX_HOME`. Codex mixes configuration, credentials, SQLite stores,
transcripts, plugins and its app-server daemon in that root, so it is a
mixed-data exception. `sqlite_home` and `log_dir` were not set: they would split
out only part of the contents, and `log_dir` turns on the plaintext TUI log (see
the [research note][research]).

## Control

zsh-config `env/tools.env.zsh` exports `CODEX_HOME="$HOME/.local/var/codex"` for
every zsh invocation. Codex is launched only from shells: interactive panes and
herdr's `agent start`, which runs in a shell pane. The daemon inherits the
variable from the Codex process that starts it.

## Procedure

1. Quit the four idle Codex sessions through herdr (`/quit`), recording their
   resume IDs.
2. Stop the daemon with `codex app-server daemon stop` and terminate its
   leftover `pid-update-loop` process, then confirm that no process held a file
   under `~/.codex`.
3. Copy `~/.codex` to `~/arc/2026-11-03_codex-home-backup` with `cp -a` and
   confirm it identical with `diff -rq --no-dereference`.
4. Rename `~/.codex` to `~/.local/var/codex` (same ext4 filesystem).
5. Rewrite the absolute paths that pointed into the old root:
   - `hooks.json`: the herdr `SessionStart` hook command.
   - `config.toml`: the `[hooks.state]` key naming `hooks.json`, and the header
     comment.
   - `packages/app-server-daemon/current`: the symlink to the active release.
6. Delete the old Bun global tree the sessions had been running from.

`herdr integration install codex` honours `CODEX_HOME` and is idempotent, as a
throwaway-`HOME` probe showed, but it writes no hook trust state, so the hook
was edited in place instead.

## Verification

With `CODEX_HOME` set:

- `codex login status` reports `Logged in using ChatGPT`.
- `codex app-server --print-startup-config` succeeds.
- `codex app-server daemon start` runs the managed 0.166.0 binary from
  `~/.local/var/codex/packages`, with its control socket under the new root.
- `~/.codex` is not recreated.
- No file in the dotfiles source names `~/.codex`.

Not yet exercised, because Codex was on usage cooldown: a model turn, a resumed
session, and the hook firing. Session transcripts still mention the old path;
they are history and were left unchanged.

## Remaining exceptions

- The herdr hook's command changed, so its stored trust hash no longer matches.
  Codex will ask for the hook to be trusted once.
- The daemon's control socket and lock files sit in the persistent root rather
  than `XDG_RUNTIME_DIR`; Codex exposes no separate control.
- A launch route outside zsh would still start Codex against a new, empty
  `~/.codex`. zsh-config `b3d462a` (pushed and deployed) covers every shell, and
  at 08:41 `~/.codex` had not reappeared.

## Rollback

Stop every Codex process and the daemon, rename `~/.local/var/codex` back to
`~/.codex`, reverse the three path rewrites, and revert zsh-config `d36bdb5`.
Keep any data written since the migration; the backup in `~/arc` is only the
pre-migration state. Delete the backup once a resumed session and the hook have
been seen working.

Resume IDs recorded at shutdown:

```text
dorothy      01a19a67-39cd-74f2-86d5-98c5e90b4f89
dotfiles     01a19dd3-7749-7e10-981e-b4ccc6288b9c
zsh-config   01a19d16-76fa-7493-9fbc-9645034ba33e
nvim-config  01a19d00-fba1-78e1-b27e-a76ac344ede2
```

[inventory]: 2026-11-03-home-directory-inventory.md
[bun]: 2026-11-03-bun-global-relocation.md
[spec]: ../specs/2026-11-03-home-directory-structure-design.md
[research]: ../notes/2026-11-03_home-directory-research.md

<!-- vim:set expandtab shiftwidth=2 filetype=markdown: -->
