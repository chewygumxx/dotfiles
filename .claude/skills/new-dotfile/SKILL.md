---
name: new-dotfile
description: >-
  Checklist for bringing a new file or config area under chezmoi in this repo:
  source-attribute naming, per-host ignores, file header, and the commitlint
  scope that its commits will need. Use when adding a config file, a new tool's
  config directory, a script under ~/.local/bin, a systemd unit, or an
  external.
ctime: 2026-10-09
mtime: 2026-10-09
spdx: GPL-3.0-only
tags:
  - claude
  - skill
  - chezmoi
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/.claude/skills/new-dotfile/SKILL.md
   -
   -->

# New dotfile

Work through each step; skip one only when it plainly does not apply.

## 1. Source path

Everything applied goes under `home/` (the `.chezmoiroot`). Never `root/`
(inert reference) or `template/`. Map the target path to source attributes,
prefixes stacking in chezmoi's order (`private_`, `readonly_`, `empty_`,
`executable_`, then `dot_`):

| Target | Source |
| --- | --- |
| `~/.config/foo/bar.toml` | `home/dot_config/foo/bar.toml` |
| `~/.local/bin/tool` (+x) | `home/dot_local/bin/executable_tool` |
| `~/.ssh/config` (0600 dir) | `home/private_dot_ssh/config` |
| symlink | `symlink_<name>` holding the target path only |
| rendered per host | append `.tmpl` |

`chezmoi add` on the real file does this naming for you; it only writes the
source dir, so it is safe to run. Check the result with
`chezmoi source-path <target>`.

- Existing `symlink_*` files hold a path, not content: the linters and
  pre-commit skip them, so don't "fix" their extension.
- Templates: `missingkey=error` is on, so every `.foo` must exist in data.
  Shared data lives in `home/.chezmoidata/*.toml`.

## 2. Externals

A downloaded binary or archive is an external, not a committed file:
`home/<dir>/.chezmoiexternals/<name>.toml.tmpl`, copied from a sibling such as
`home/dot_local/bin/.chezmoiexternals/print-quote.toml.tmpl`. Use
`refreshPeriod = {{ .externals.refreshPeriod | quote }}` (`$.externals` inside
`range`/`with`); never hardcode a period. Browser extensions instead go in
`home/.chezmoidata/web-extensions.toml`: read `docs/web-extensions.md` first.

## 3. Per-host ignores

`home/.chezmoiignore` matches **target** paths (no `dot_`/`executable_`) in
three blocks: ignored everywhere, ignored on chewytop (desktop), ignored on
chewytele (Termux, detected by `.chezmoi.destDir`). A desktop-only tool (any
Wayland/Hyprland, browser or systemd piece) needs an entry in the Termux block;
a Termux-only one in the chewytop block. Scripts are listed as
`.chezmoiscripts/<name>` without the `run_*_` prefix.

## 4. Header

The `header-metadata` plugin writes the house header into each new file on
Write, copied from the nearest headed sibling. Confirm the result: modeline
with the right `filetype=`, `SPDX-License-Identifier: GPL-3.0-only`, and the
boxed `~chewygumxx/dotfiles.git` / `::: :/<repo path>` lines in the file's
comment syntax (`#`, `--`, `//`, `/* */`, HTML comment after YAML frontmatter
in Markdown). Formats with no comments (plain `.json`) get none. A shebang, if
any, stays on line 1. CI's `sync-header-metadata` fixes path drift later.

## 5. Commit scope

A scope is optional, but `scope-enum` blocks any scope not listed, so
`feat(<tool>): ...` fails until `<tool>` is in `scopes.enum` in
`.commitlintrc.mts`. If it is missing, add an entry in alphabetical position,
matching neighbours:

```ts
{
    name: "<tool>",
    fullName: "<Proper Name>",
    description: "<Short Category>",
},
```

Commit that first (`build: Add <tool> commit scope`), then run
`bun run typecheck`. Then the config itself, e.g.
`feat(<tool>): Add <tool> config`: 50-char header limit, no em dashes, no AI
trailer.

## 6. Verify

- The `lint-on-edit` hook already linted the file on save; fix anything it
  reported.
- `chezmoi managed | grep <name>` (shows it is tracked and not ignored).
- Render it without touching the real home with the `chezmoi-sandbox` skill:
  `.claude/skills/chezmoi-sandbox/scripts/sandbox-apply.sh ~/<target>`, then
  inspect the file and its mode.
