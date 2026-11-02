---
ctime: 2026-11-03
mtime: 2026-11-03
spdx: GPL-3.0-only
title: Bun Global Package Relocation
description: >-
  Moving Bun's global packages out of the cache root into the data root, with
  their links in ~/.local/bin, and the controls that turned out to work.
tags:
  - dotfiles
  - filesystem
  - xdg
  - bun
  - report
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/docs/reports/2026-11-03-bun-global-relocation.md
   -
   -->

# Bun Global Package Relocation

Migration date: 2026-11-03, Bun 1.4.2 (via mise). Follows the
[inventory][inventory] under the [specification][spec].

## Paths

| Item     | Old                            | New                         |
| -------- | ------------------------------ | --------------------------- |
| Packages | `~/.cache/.bun/install/global` | `~/.local/share/bun/global` |
| Links    | `~/.cache/.bun/bin`            | `~/.local/bin`              |
| Cache    | `~/.cache/.bun/install/cache`  | unchanged                   |
| Stale    | `~/.bun/install/cache`         | deleted                     |

## Probes

Bun's [bunfig reference][bunfig] documents `install.globalDir` and
`install.globalBinDir` in a global `$XDG_CONFIG_HOME/.bunfig.toml`, with
`BUN_INSTALL_GLOBAL_DIR` and `BUN_INSTALL_BIN` as equivalents. Each was tried
with `bun add -g is-number@7.0.0` under a throwaway `HOME` and `env -i`:

| Control                                     | Global dir used            |
| ------------------------------------------- | -------------------------- |
| `$XDG_CONFIG_HOME/.bunfig.toml`, `~/` paths | `$XDG_CACHE_HOME/.bun/...` |
| `~/.bunfig.toml`, `~/` paths                | `$XDG_CACHE_HOME/.bun/...` |
| `$XDG_CONFIG_HOME/.bunfig.toml`, absolute   | `$XDG_CACHE_HOME/.bun/...` |
| `BUN_INSTALL_GLOBAL_DIR`, `BUN_INSTALL_BIN` | the requested directories  |

Ruling: Bun 1.4.2 ignores the bunfig keys, so the environment variables are the
only control. No bunfig is managed.

## Changes

- zsh-config `env/tools.env.zsh` exports
  `BUN_INSTALL_GLOBAL_DIR="$XDG_DATA_HOME/bun/global"` and
  `BUN_INSTALL_BIN="$HOME/.local/bin"`; `env/base.env.zsh` drops
  `$XDG_CACHE_HOME/.bun/bin` from `PATH`. `~/.local/bin` was already first.
- Only shells run `bun add -g`, so no `environment.d` entry is needed.

## Migration

The old `package.json` (dependency ranges and `trustedDependencies`) and
`bun.lock` were copied into the new directory before reinstalling, so the
lockfile kept every version:

```sh
G=~/.local/share/bun/global
mkdir -p "$G"
cp ~/.cache/.bun/install/global/{package.json,bun.lock} "$G/"
BUN_INSTALL_GLOBAL_DIR="$G" BUN_INSTALL_BIN="$HOME/.local/bin" \
    bun add -g '@openai/codex@^0.166.0' '@opencode/cli@^2.2.5' \
    'openclaw@^2026.10.9' 'skills@^1.7.4'
```

## Verification

- `bun.lock` in the new directory is byte-identical to the old one.
- `codex` 0.166.0, `openclaw` 2026.10.9, `opencode` 2.2.5, `skills` and
  `add-skill` 1.7.4 resolve through `~/.local/bin` into the new directory and
  report those versions.
- No configuration referenced `~/.cache/.bun/bin`; only herdr's session history
  mentions it.

## Completion

- The old `~/.cache/.bun/install/global` and `~/.cache/.bun/bin` were deleted
  once the Codex sessions running from them had stopped, during the [Codex
  relocation][codex].
- The zsh-config change is pushed and deployed (zsh-config `b3d462a`), so new
  shells set both variables.

## Rollback

Reinstate the `PATH` entry, unset both variables, and remove
`~/.local/share/bun/global` with the six links in `~/.local/bin`. The old tree
still works while it exists; otherwise rerun the install above without the
variables.

[inventory]: 2026-11-03-home-directory-inventory.md
[spec]: ../specs/2026-11-03-home-directory-structure-design.md
[bunfig]: https://bun.com/docs/runtime/bunfig
[codex]: 2026-11-03-codex-home-relocation.md

<!-- vim:set expandtab shiftwidth=2 filetype=markdown: -->
