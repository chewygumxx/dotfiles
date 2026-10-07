---
ctime: 2026-09-29
mtime: 2026-10-07
spdx: GPL-3.0-only
title: CLAUDE.md
description: >-
  Claude Code's guide to these chezmoi-managed dotfiles: prose rules, layout and
  conventions.
tags:
  - llm
  - claude
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/.claude/CLAUDE.md
   -
   -->

# CLAUDE.md

Continuously granularly commit as you work. Compose single-line commit messages
whenever appropriate. If the granular commit does indeed warrant further
context, include such within the commit message body.

When appropriate and worthwhile to compact, append the following
newline-delimited items to your response:

- A `/compact <summary>`
- Appraisal rating scaled 1-100
- Risk assessment rating scaled 1-100
- Terse single-sentence justification.

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

`template/` is not a source root either; it is a near-empty skeleton
(`.chezmoiignore` only), kept as a starting point for scaffolding a new one
later.

`.claude/` is chezmoi-ignored everywhere (see `home/.chezmoiignore`); it is
tooling for working in this repo, not something chezmoi ever applies to a
machine.

Within `home/`, the Zsh config (`home/dot_config/zsh/`) is itself modular and
worth understanding before editing it:

- `env/*.env.zsh`: environment variables, sourced first via `zsh_dirs`.
- `rc/*.rc.zsh`: core interactive setup (aliases, completion, prompt, history,
  etc.). `dot_zshrc` loads these in a deliberate order: `ls_colors` and
  `completion` first, then `function`, then everything else, then `util/*.rc.zsh`
  last. Preserve that ordering rationale (documented inline in `dot_zshrc`) if
  adding new `rc` files.
- `util/*.rc.zsh`: per-tool integration snippets (fzf, zoxide, nvm, chezmoi,
  etc.), loaded after core `rc/`.
- `func/*`: autoloadable Zsh functions, one file per function.
- `wrap/*`: thin command wrappers/shims (e.g. `claude`, `chezmoi`, `nvim`,
  `rm`, `gh`).
- `spec/*.rc.zsh`: third-party plugin specs.

## Conventions

- **No em dashes anywhere in this repository** (code, comments, commit
  messages, docs).
- **No AI co-author trailers**: never add a `Co-Authored-By: Claude ...`
  (or similar AI attribution) trailer to a commit message or pull request
  description unless the user explicitly asks for it on that specific
  commit/PR.
- **File headers**: nearly every tracked file starts with an editor modeline,
  an `SPDX-License-Identifier` line, and a boxed comment giving the repo slug and
  the file's repo-relative path (e.g. `::: :/home/dot_config/zsh/dot_zshrc`),
  using the line-comment syntax for that file's language. These headers are
  auto-maintained by the `sync-header-metadata` GitHub Action on every push/PR to
  `main` (see `.github/workflows/sync-header-metadata.yaml`), which commits
  corrections back (`chore: Sync header metadata`). When adding a new file,
  follow the existing header style from a sibling file of the same type rather
  than inventing one; CI will fix minor drift.
- **Indentation**: per `.editorconfig`, 4 spaces by default, 2 spaces for
  `*.md`. LF line endings, trailing whitespace trimmed, final newline inserted.
- **Commit messages**: Conventional Commits, enforced by `commitlint`
  (`.commitlintrc.mts`) via a `husky` `commit-msg` git hook (`.husky/commit-msg`,
  wired up by the `prepare` package script). `.commitlintrc.mts` defines:
  - Allowed types (error, blocking): `feat`, `fix`, `tweak`, `refactor`,
    `chore`, `style`, `docs`, `ci`, `build`, `test`, `revert`.
  - 50-char header limit (error), 72-char body line-wrap limit (error), subject
    must be start-case or sentence-case (warn), subject must not be empty
    (error).
  - A curated scope list (error, blocking) matching top-level config areas,
    e.g. `nvim`, `zsh`, `yazi`, `hypr`, `systemd`, `wezterm`, `herdr`, `claude`,
    `firefox`, `git`, `gh`, `gpg`, `ssh`, `nushell`, `termux`, `waybar`, `yay`,
    `btop`; multiple scopes may be combined with a `/` delimiter (e.g.
    `feat(zsh/nvim): ...`). Scope is optional; a commit with no scope at all
    (e.g. `build: ...`) always passes this rule.
  - Interactive commit authoring is available via `bun run commit`
    (`commitizen` configured via `package.json`'s `config.commitizen.path` to use
    the `@chewygumxx/cz-commitlint` adapter, a wrapper around
    `@commitlint/cz-commitlint`). Choices offered are always exactly
    the `type-enum`/`scope-enum` rule arrays above (never the extended
    `@commitlint/config-conventional` defaults, even though those get merged into
    the resolved config's `prompt.questions.*.enum` objects); each choice is
    decorated with the per-type/scope `description` (and `emoji`, if set) from
    `.commitlintrc.mts`'s own `prompt.questions` block.
  - The interactive list itself (`type`/`scope` selection) shows each choice's
    `fullName` (e.g. `Feature`) rather than the raw enum key (`feat`) as its
    label: `@commitlint/cz-commitlint` hardcodes the enum key into the label, so
    the `@chewygumxx/cz-commitlint` wrapper relabels each choice with its
    `title` before the list is shown, without patching the installed package.
    The commit header still gets the raw enum key regardless of what's shown in
    the list, since the selected choice's `value` (always the enum key) is what
    goes into the header, never its display label.
  - Enforced in CI on push to `main` and on PRs via
    `.github/workflows/commitlint.yaml`, which is passed `configFile:
./.commitlintrc.mts` explicitly; the action's own default
    (`./commitlint.config.mjs`) doesn't exist in this repo and would otherwise
    silently fall back to bare `@commitlint/config-conventional` with no error.
- **Repo metadata** (`.repo-metadata.jsonc`) is synced to the GitHub repo's own
  settings (description, topics, license) by
  `.github/workflows/apply-repo-metadata-jsonc.yaml` whenever that file changes
  on push.

## No build/test/lint tooling

There is no build step or test suite for this repository.
`package.json`/`bun.lock` exist solely to pull in `husky`,
`commitlint`, and `typescript` (see the commit-messages convention above) as
devDependencies, not as an application dependency tree. `.commitlintrc.mts` is
the one file with real typechecking: `tsconfig.json` scopes `tsc` to just that
file (TS's default `**/*` include glob skips dotfiles, so it has to be listed
explicitly), and `bun run typecheck` runs it; this only catches shape/typo
errors at editor- or CI-time; the commit-msg hook itself loads
`.commitlintrc.mts` via `jiti` (transpile-only, no type-checking) so a type
error there would still pass silently at commit time if `bun run typecheck`
isn't run separately. "Correctness" elsewhere in the repo means: the
shell/config files are syntactically valid for their target tool, chezmoi
source-attribute naming is correct, and file headers/commit messages follow the
conventions above. When in doubt about whether a config change works, check the
relevant tool's own docs/behavior (Zsh, chezmoi, Neovim, Hyprland, etc.) rather
than looking for a repo-local test command, since none exists otherwise.

<!-- vim:set expandtab shiftwidth=2 filetype=markdown: -->
