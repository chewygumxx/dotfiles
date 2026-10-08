---
name: chezmoi-sandbox
description: >-
  Apply this repo's chezmoi source into a throwaway directory (own destination,
  persistent state and cache, scripts excluded) to test what a change produces
  without touching the real home. Use when verifying templates, externals,
  .chezmoiignore/.chezmoiremove changes or browser extension installs, or when
  the chezmoi apply guard blocks a command.
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
   - ::: :/.claude/skills/chezmoi-sandbox/SKILL.md
   -
   -->

# chezmoi sandbox

Never `chezmoi apply` against the real home to test a change. The
`guard-chezmoi-apply` hook blocks it anyway. Apply into a sandbox instead.

## Apply

```sh
.claude/skills/chezmoi-sandbox/scripts/sandbox-apply.sh [--in DIR] [targets...]
```

- Targets may be written as real paths (`~/.config/herdr`); the script maps
  them into the sandbox and creates their parent directories, which chezmoi
  will not do in an empty destination.
- With no targets the whole tree is applied, which downloads every external
  (all browser extensions included) and renders every template. That includes
  `private_visualcrossing.apikey.tmpl`, which calls `protonPass`: prefer
  explicit targets unless the full tree is the point.
- `--in DIR` reuses an earlier sandbox, keeping its cached externals.
- The sandbox root is the last line of stdout; the exact flags for follow-up
  commands are printed to stderr.

## Inspect

Every follow-up chezmoi command needs the same five flags the script printed
(`--source`, `--destination`, `--persistent-state`, `--cache`,
`--exclude=scripts`), e.g. `chezmoi managed`, `chezmoi diff`,
`chezmoi verify`. Compare a rendered file with the live one using plain
`diff "$sandbox/home/.config/foo" ~/.config/foo`.

## Limits

- `.chezmoiscripts/` never run in the sandbox: some write outside
  `$CHEZMOI_DEST_DIR` (e.g. `run_onchange_wezterm-terminfo` prefers
  `$TERMINFO`/`$XDG_DATA_HOME`). Test a script by reading it, or by running it
  by hand with those variables pointed into the sandbox.
- Remove the sandbox when done: `rm -rf "$sandbox"`.
- Applying to the real home is the user's call; suggest the command, do not run
  it.
