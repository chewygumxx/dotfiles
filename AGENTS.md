---
ctime: 2026-09-29
mtime: 2026-11-07
spdx: GPL-3.0-only
title: Repository Agentic Instructions
description: >-
  Agentic instructions regatrding the prose rules, layout and
  conventions of this dotfiles configuration repository.
tags:
  - agents
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/AGENTS.md
   -
   -->

# Repository Agentic Instructions

<!-- TODO: This AGENTS.md desperately needs refactoring -->

<!-- TODO: The below is README.md documentation -->

## What this repository is

A [chezmoi](https://www.chezmoi.io)-managed dotfiles repository
(`chewygumxx/dotfiles`). It holds Zsh, Neovim, Hyprland, WezTerm, Yazi, and
other tool configuration for Linux and Android/Termux hosts, plus a small set
of standalone shell scripts and chezmoi externals.

## Repository layout

There are two chezmoi source-root-shaped directories in this repo, but only one
is actually wired up:

- `home/`: the active source root. `.chezmoiroot` points here, and
  `home/.chezmoi.toml.tmpl` sets `sourceDir` for it. Applied to `$HOME` via
  `chezmoi apply`/`chezmoi init` as the normal user. Files follow chezmoi's
  source-attribute naming: `dot_config` maps to `~/.config`, `dot_local` maps to
  `~/.local`, `private_dot_ssh` maps to `~/.ssh` (restricted perms),
  `executable_*` maps to `+x` files, `symlink_*` maps to symlinks, `run_*` (in
  `.chezmoiscripts/`) maps to one-shot/change scripts, and
  `.chezmoiignore`/`.chezmoiremove`/`.chezmoiexternals/*.toml` control ignored
  files, removals, and externally-fetched binaries respectively.
- `root/`: root-owned, system-level files (`/etc/...`), laid out as if it were
  a second source root (paths map directly, e.g. `root/etc/fstab` corresponds to
  `/etc/fstab`, since there's no `dot_` prefixing needed outside `$HOME`).
  Nothing in the repo currently applies it though: no
  `.chezmoiroot`/`.chezmoi.toml.tmpl` for it, no script or CI step references it.
  Treat it as inert reference material laid out in chezmoi's naming convention,
  not as something chezmoi will act on as-is.

### Paired `.*` and `dot_*` dev-tool configs

Some config dirs under `home/` hold what looks like a duplicate pair, e.g.
`home/dot_config/hypr/dot_luacheckrc` and `home/dot_config/hypr/.luacheckrc`.
They are one file: the `.*` name is a tracked git symlink to its `dot_*`
sibling (`.luacheckrc -> dot_luacheckrc`). Each name has its own job:

- `dot_*` is the real file, and the copy chezmoi deploys (`dot_luacheckrc`
  becomes `~/.config/hypr/.luacheckrc`), so the tools also work when editing
  the deployed config.
- `.*` exists only for working in the repo. chezmoi ignores source entries
  that start with `.` (other than `.chezmoi*`), so it is never deployed. The
  tools look for their config by its real dot name in the source tree: the
  pre-commit hook walks up for the nearest `.luacheckrc`, luafmt reads
  `.luafmt.toml`, and LuaLS reads `.luarc.json`.

Pairs exist in `home/dot_config/{hypr,luarocks,wezterm,yay,yazi}/`
(`git ls-files -s | grep ^120000` lists every tracked symlink). Never delete
either name as a duplicate, never turn the symlink into a copy, and edit the
`dot_*` file. A new Lua config dir gets the same pair: copy a sibling's
`dot_*` files and add the symlinks with `ln -s dot_<name> .<name>`.

<!-- TODO: The above is README.md documentation -->

<!-- TODO: The below content should be specified either closer to the path they
     are significant or elsewhere -->

Externals take their `refreshPeriod` from `home/.chezmoidata/externals.toml`
(`{{ .externals.refreshPeriod }}`, or `$.externals` inside `range`/`with`),
which `gitHub.refreshPeriod` in `home/.chezmoi.toml.tmpl` also includes;
never hardcode one.

Zsh and Neovim config are **not in this repo**: `zsh-config.toml.tmpl` and
`nvim-config.toml.tmpl` in `home/.chezmoiexternals/` clone
`chewygumxx/zsh-config` and `chewygumxx/nvim-config` as git-repo externals.
nvim-config is cloned straight into `~/.config/nvim`. zsh-config keeps its
runtime in a `zsh/` subdirectory, so it is cloned into
`~/.local/share/zsh-config`, and `home/dot_config/symlink_zsh` links that
`zsh/` child in as `~/.config/zsh`, the `ZDOTDIR`. Change them in those repos.

Browser extensions for Firefox and ungoogled-chromium are declared once in
`home/.chezmoidata/web-extensions.toml` and installed by the
`.chezmoiexternals` templates inside the Firefox profile and
`dot_local/share/chromium/`; read `docs/note/2026-10-08_web-extensions.md`
before changing any of it. Never `chezmoi apply` those targets against the
real home to test them: use
`.claude/skills/chezmoi-sandbox/scripts/sandbox-apply.sh`, which
adds `--destination`, `--persistent-state`, `--cache` and `--exclude=scripts`
under a temp dir (scripts would otherwise write to the real home even from a
sandbox).

<!-- TODO: The above content should be specified either closer to the path they
     are significant or elsewhere -->

<!-- The following content until EOF is appropriate to be recorded here
   -->

## Conventions

### Commit Granularity and Message Linting

Continuously granularly commit as you work. Compose single-line commit messages
whenever appropriate. If the granular commit considerably warrants further
context than what a single-line commit message can provide, then include such
within the commit message body.

- Conventional Commits, enforced by `commitlint`
  (`.commitlintrc.mts`) via a `husky` `commit-msg` git hook (`.husky/commit-msg`,
  wired up by the `prepare` package script). `.commitlintrc.mts` defines:
  - Allowed types (error, blocking): `feat`, `fix`, `tweak`, `refactor`,
    `chore`, `style`, `docs`, `ci`, `build`, `test`, `revert`.
  - 50-char header limit (error), 72-char body line-wrap limit (error), subject
    must be start-case or sentence-case (warn), subject must not be empty
    (error).
  - A curated scope list (error, blocking) matching top-level config areas,
    e.g. `zsh`, `yazi`, `hypr`, `systemd`, `wezterm`, `herdr`, `claude`,
    `firefox`, `git`, `gh`, `gpg`, `ssh`, `nushell`, `termux`, `waybar`, `yay`,
    `btop`; multiple scopes may be combined with a `/` delimiter (e.g.
    `feat(zsh/hypr): ...`). Scope is optional; a commit with no scope at all
    (e.g. `build: ...`) always passes this rule. A new config area needs its
    scope added before its first scoped commit (see the `new-dotfile` skill).
  - `bun run commit` is interactive commitizen authoring, for the user (it
    needs a TTY). Via the `@chewygumxx/cz-commitlint` adapter it offers only
    the `type-enum`/`scope-enum` values above, labelled by their `title`; the
    header always gets the raw enum key.
  - Enforced in CI on push to `main` and on PRs via
    `.github/workflows/commitlint.yaml`, which is passed
    `configFile: ./.commitlintrc.mts` explicitly; the action's own default
    (`./commitlint.config.mjs`) doesn't exist in this repo and would otherwise
    silently fall back to bare `@commitlint/config-conventional` with no error.

### Standard File Header

Nearly every tracked file starts with an editor modeline, an
`SPDX-License-Identifier` line, and a boxed comment giving the repo slug and
the file's repo-relative path
(e.g. `::: :/home/dot_config/wezterm/wezterm.lua`), using the line-comment
syntax for that file's language. Markdown differs: YAML frontmatter (`ctime`,
`mtime`, `spdx`, `title`, `description`, `tags`), then an HTML-comment path
box, with the modeline on the last line. These headers are auto-maintained by
the `sync-header-metadata` GitHub Action on every push/PR to `main` (see
`.github/workflows/sync-header-metadata.yaml`), which commits corrections back
(`chore: Sync header metadata`). When adding a new file, follow the existing
header style from a sibling file of the same type rather than inventing one; CI
will fix minor drift. The `header-metadata` plugin writes this header into each
new file on Write.

### Indentation

Per `.editorconfig`, 4 spaces by default, 2 spaces for `*.md`. LF line endings,
trailing whitespace trimmed, final newline inserted.

### Repo Metadata

`.repo-metadata.jsonc` is synced to the GitHub repo's own settings
(description, topics, license) by `.github/workflows/sync-repo-metadata.yaml`
whenever that file changes on push.

## Checks

There is no build step or test suite. `package.json`/`bun.lock` only pull in
dev tooling (husky, commitlint, commitizen, prettier, remark, typescript).
Linting runs in three places:

- `.husky/pre-commit` (staged files): luafmt then luacheck (nearest
  `.luacheckrc`), tombi format/lint, prettier on JSON/YAML; `symlink_*` files
  skipped. The formatters rewrite in place and re-stage, so JSON written by a
  tool at 2-space indent is committed at `.editorconfig`'s 4. There is no
  biome. `.github/workflows/lint-config.yaml` runs the same checks in CI.
- `bun run typecheck`: `tsconfig.json` scopes `tsc` to `.commitlintrc.mts`
  alone (TS's default `**/*` glob skips dotfiles). The commit-msg hook loads
  that file via `jiti` (transpile-only), so a type error there passes silently
  at commit time unless this is run.

<!-- vim:set expandtab shiftwidth=2 filetype=markdown: -->
