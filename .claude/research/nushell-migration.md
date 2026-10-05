---
ctime: 2026-09-29
mtime: 2026-10-05
spdx: GPL-3.0-only
title: Zsh to Nushell migration research
description: >-
  Assessment of moving from zsh to Nushell, written against this repository's
  zsh configuration.
tags:
  - research
  - nushell
  - zsh
  - shell
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/.claude/research/nushell-migration.md
   -
   -->

# Zsh to Nushell migration research

Research date: 2026-09-14. Nushell version referenced throughout: 0.115.1 (2026-08-23). This is
an assessment, not a decision. It is written against this repository's actual zsh configuration,
not a generic shell comparison.

## 1. Executive summary

**Recommendation: run Nushell as an interactive side shell now, keep zsh as the daily driver and
as the shell chezmoi and Termux point at, and revisit a full switch in six to twelve months.**

Two facts drive this more than anything else:

1. **`nvm` has no real Nushell equivalent.** `nvm.sh` is a POSIX shell script that Nushell cannot
   source at all (confirmed below), and this repository's `util/nvm.rc.zsh` depends on sourcing
   it. The practical fix used by other migrators is to replace `nvm` with `fnm`, which is a tool
   swap, not a port.
2. **This repository's `wrap/*` functions are not simple aliases.** Files like `wrap/nvim` (auto
   `chezmoi add`/`re-add` on edit, `sudoedit` for root-owned files) and `wrap/chezmoi` (a small
   subcommand dispatcher) are nontrivial zsh programs built on zsh-specific parameter expansion
   (`${(D)...}`, `${(%):-%N}`, `$+commands[...]`) and associative arrays. None of this transfers
   by renaming a file; each one is a from-scratch rewrite in Nu's language.

Nushell's structured-data and type story is real and matches what you're missing in zsh (see
section 2). The cost is concentrated in a specific, identifiable set of files, not spread evenly
across the whole config, so a hybrid approach is both honest about the cost and cheap to start.

## 2. What Nushell genuinely solves better

These are concrete, not aspirational, and map onto the "type awareness, scoping, structured
data" interest you named.

- **Structured data is the pipeline's native currency.** `open file.toml`, `open file.json`,
  `open file.yaml`, and `open file.db`/`open file.sqlite` all return typed Nu values (tables,
  records) you can filter, sort, and reshape with `where`, `select`, `get`, `update`, instead of
  piping text through `jq`/`yq`/`grep`/`awk`. For a chezmoi-managed dotfiles repo full of TOML
  (`.chezmoiexternals/*.toml`, `home/.chezmoi.toml.tmpl`) and JSONC (`.repo-metadata.jsonc`,
  `.meteor.json`), this is a direct match: `open .meteor.json | get scopes | where name == zsh`
  works today with no parsing code.
- **SQLite is a first-class format, not a library you shell out to.** Nushell "speaks JSON, YAML,
  SQLite, Excel, and more out of the box." `open some.db` returns queryable tables directly, and
  `query db` runs raw SQL against local or in-memory SQLite and hands back Nu tables. There is
  also a `stor` command family (`stor open`, `stor create`, `stor insert`) for an in-memory or
  file-backed SQLite store you can build ad hoc data structures against from the prompt, e.g.
  turning a `pkglist` scrape into a queryable table instead of piping through `less -R` as the
  current `func/pkglist` does. `stor`/`query db` do have rough edges: JSONB columns inside SQLite
  round-trip as strings and need a manual `from json`, and `get` on a `stor open` handle has an
  open compatibility bug, so treat this as "usable now, still hardening" rather than finished.
- **`def` signatures are genuinely type-checked**, and as of 0.114.0 runtime type annotations are
  enforced by default (`enforce-runtime-annotations` became opt-out), catching type mismatches
  Zsh functions like `adb-wifi` (which silently treats `$1`/`$2`/`$3` as untyped strings with a
  `:=` default) would only fail on at the point of use.
- **Scoping is lexical and block-based by default** (`let`, `def`, `$env` inside a block do not
  leak outward), which is the opposite of zsh's ambient dynamic scoping that the `func/*` files
  here work around by hand: `__bg_jobs_summary` uses `emulate -L zsh` plus a hand-built
  "already enabled" guard variable (`__enabled_${safevarname}`) precisely because zsh functions
  do not give you a clean local/reload story for free. Nu's `overlay use` / `overlay hide` gives
  you a genuine push/pop environment scope (this is exactly the mechanism Python's `venv`
  `activate.nu` scripts use), which is closer to what "intuitive scoping" usually means in
  practice than anything zsh offers natively.

## 3. What would be lost or need rework

Mapped against the actual files in `home/dot_config/zsh/`, not a generic ecosystem-maturity
claim.

### No clean Nu equivalent, real rework required

| File | Why it does not port cleanly |
|---|---|
| `util/nvm.rc.zsh` | Sources `nvm.sh`, a POSIX-only bash script. Nushell cannot source POSIX shell scripts at all (see section 4's evidence); this is not a syntax gap, it is a hard boundary. Migrators who moved to Nu report switching to `fnm` (which has a purpose-built `nu_scripts` module using Nu's `env_change.PWD` hook to auto-switch versions per directory) instead of porting `nvm` itself. This is a tool substitution, and you would inherit its behavior differences from `nvm` (e.g. how `.nvmrc` resolution and default-version aliasing work). |
| `wrap/nvim` | ~40 lines of real logic: detects new vs. existing files, calls `sudoedit` when the target is owned by uid 0, checks `chezmoi managed`/`chezmoi source-path` and calls `chezmoi add --prompt` or `chezmoi re-add` accordingly. Every piece (`$(zstat +uid ...)`, `chezmoi re-add "$target" &!` as a detached background job) needs a Nu-native rewrite: Nu has no direct zsh `&!` (disown-and-background) equivalent and file stat comes from `stat` output parsing or an external call. |
| `wrap/chezmoi` | A hand-rolled subcommand dispatcher (`dispatch`, `alias_main`, `help_main`) that reformats `chezmoi help` output and injects a custom `alias` subcommand. Nu supports subcommands via `def "chezmoi alias" [...]` naturally, which is arguably a nicer fit, but the whole file is a rewrite, not a port. |
| `wrap/rm`, `wrap/sv` | Small, but depend on zsh's `$+commands[x]` and `$+aliases[x]` fast existence checks and zsh alias introspection. Nu has `(which x | is-not-empty)` and no alias table in the same sense (Nu aliases are simpler substitutions); trivial to rewrite but not copy-paste. |
| `func/__bg_jobs_summary` | Deeply zsh-specific: reads `$jobstates`/`$jobtexts`/`$jobdirs` associative arrays, registers itself via `add-zsh-hook precmd`, and mutates `$PS1` by string-splicing a placeholder into it. Nu's prompt is a closure (`$env.PROMPT_COMMAND`), and Nu's job control/table introspection for background jobs is not a drop-in match for zsh's `jobstates`. This is a full redesign, not a translation. |
| `func/nameddirs` | Reads zsh's built-in `$nameddirs` associative array (populated by zsh's named-directory feature, `hash -d`). Nushell has no equivalent named-directory mechanism; you would need to build your own table (e.g. backed by an env record or a `stor` table) and a matching `cd` convenience, which is more of a feature reimplementation than a port. |
| `func/pkglist` | Termux-only (`$TERMUX_VERSION` gate), uses zsh's `zmodload zsh/parameter`, `local +h functions` (unset the `h` "hide" flag on the functions array to define a private local function), and `dpkg-query`/`apt-cache` piped through a hand-rolled word-wrapper. The Debian tooling calls are portable to Nu as external commands; the zsh-internal plumbing (`zmodload`, `+h functions`) is not. |
| `spec/zsh-vi-mode.rc.zsh` | Configures the `zsh-vi-mode` plugin (cursor styles, clipboard integration via `wl-copy`/`wl-paste`, `ZVM_OPEN_CMD`/`ZVM_OPEN_URL_CMD`). See section on vi-mode below: there is no drop-in Nu equivalent of this plugin's feature set. |
| `spec/zsh-autocomplete.rc.zsh` | Currently disabled (`PLUGIN_DISABLE=1`) in this config, so nothing to port, but noted for completeness since it's a zsh-plugin-manager-specific file with no Nu analogue. |

### Ports cleanly or needs only light rework

- **`util/zoxide.rc.zsh`**: zoxide has native, documented Nushell support (`zoxide init nushell`),
  requiring Nu 0.89+ (long since satisfied by 0.115.1). The existing file's caching trick
  (regenerate `zoxide init zsh` output only when stale) is a reasonable pattern to replicate in Nu
  using `$nu.env-path`/`$nu.config-path`. One real behavior change: zoxide's `--cmd cd` (replacing
  `cd` outright) does not work in Nushell the way it does in zsh; Nu's zoxide integration instead
  defines separate `z`/`zi` commands rather than overriding `cd`.
- **`util/fzf.rc.zsh`**: this is the one clear regression with no full fix available yet. fzf has
  **no official native Nushell shell integration** as of this research (open feature request), so
  the CTRL-R/CTRL-T/ALT-C keybindings and `**`-trigger completion this file wires up have no
  first-party Nu equivalent. The community workaround is Carapace's completion bridging plus
  hand-wired `fzf` calls in custom keybindings, which is materially less integrated than the
  current setup.
- **`util/chezmoi.rc.zsh`**: the `cz`/`cze`/`cza`/etc. aliases port directly (Nu `alias` syntax is
  simpler than zsh's). The completion-cache-regeneration block needs `chezmoi completion nushell`
  to exist; if it does not, you fall back to Carapace bridging for chezmoi specifically.
- **`func/journal`, `func/clipdump`, `func/mkcd`, `func/mkdirt`, `func/adb-wifi`,
  `func/unicode-search-fonts`, `func/read-pipe`, `func/zedd`, `func/ansifilter`,
  `func/openrouter`, `func/gc`, `func/gcp`, `func/ansi16`**: these are mostly straight-line
  argument handling, string building, and external command invocation (`adb`, `wl-paste`, `date`,
  `git`). They port with moderate, mechanical effort: `${1:-default}` becomes a typed `def`
  parameter with a default value, `$?`-based error paths become Nu's `try`/`error make`. None of
  these depend on zsh-only mechanisms the way the files in the first table do.
- **`root/etc/zshenv`**: mostly XDG variable exports (`XDG_DATA_HOME`, etc.), which is a direct,
  low-effort translation to Nu's `env.nu` regardless of what happens with `root/` (recall: nothing
  currently applies `root/` as a chezmoi source, per the main `CLAUDE.md`, so this file is inert
  reference material for now, not something an interactive shell reads).
- **`wrap/claude`**: mostly `local -x VAR="value"` environment exports plus a `project_dir()`
  helper that parses `git remote get-url origin` into an owner/repo slug via zsh string-slicing
  (`${(s:/:)git_repo_url}`). The exports translate directly to `$env.VAR = "value"`; the slug
  parser is easier in Nu (`split row "/" | last 2 | str join "/"`-shaped) than in zsh, so this file
  is actually a case where Nu is a net simplification.

### Config architecture itself

The whole `zsh_dirs`-driven, ordered-directory-of-`*.rc.zsh`-files loading scheme in `dot_zshrc`
(`env/` then a hand-ordered subset of `rc/` then the rest of `rc/` then `util/`) is a zsh-specific
solution to a problem Nu solves natively with modules: `use`/`export use` of `.nu` module files,
with `config.nu` and `env.nu` as fixed entry points. Porting this is a redesign of the loading
mechanism itself, not a mechanical translation. It is also the easiest piece to redesign well,
since Nu's module system is more structured than "source every file in a directory."

## 4. The Termux/Android constraint

This is directly relevant and was checked, not assumed:

- **Termux packages Nushell officially.** `pkg install nushell` is available; Termux's own build
  script compiles it with `--features plugin,trash-support,sqlite,network,native-tls`, so the
  `sqlite`/`stor`/`query db` features discussed above are present in the Termux build.
- **Building from source in Termux is broken**, independent of the packaged build: `cargo install
  nu` fails on Android because the `arboard` clipboard crate has no Android platform backend
  (`could not find 'Clipboard' in 'platform'`). This does not block you since the packaged route
  works, but it means you cannot easily build a custom/patched Nu with extra cargo features on
  Termux; you are limited to whatever feature set the Termux package maintainers ship.
- **The shell-selection mechanism in this repo is a hard file, not a preference.**
  `home/dot_config/termux/symlink_shell` is a chezmoi `symlink_*` file whose target is
  `/data/data/com.termux/files/usr/bin/zsh`, literally. Termux's own `login` shell resolution
  reads this file directly. Switching Termux's shell means changing this symlink target (and
  confirming a `nu` binary path is stable enough to hardlink against across Termux upgrades),
  which is a small, mechanical change, not a blocker, but it is a change to a currently-working,
  recently-touched file (the `sv` wrapper fix in this same directory tree landed within the last
  day per `git log`), so treat the Termux side as "do this last, after the desktop side is
  validated."
- **The Termux-specific `func`/`wrap` files most likely to need attention on this host are
  `func/pkglist`, `func/adb-wifi`, and `wrap/sv`**, all already flagged above as requiring
  meaningful rework rather than a straight port.

Net: Nushell is not a fringe or unsupported option on Termux. It is officially packaged, and the
one real gap (no custom cargo builds) is unlikely to matter for interactive daily use.

## 5. A realistic migration path, if you proceed

1. **Prototype without touching the login shell.** Install Nu (`pkg install nushell` on Termux,
   your Linux distro's package or a static release binary elsewhere) and run it as a subshell from
   inside zsh (`nu`) for a few days of real work, particularly TOML/JSON/SQLite tasks against this
   repo's own files (`.meteor.json`, `.repo-metadata.jsonc`, `.chezmoiexternals/*.toml`) since
   that is exactly the workload motivating this. Do not change `chezmoi`'s `sourceDir`, the
   `dot_zshrc` loader, or the Termux `symlink_shell` target yet.
2. **Port the cleanly-portable `func/*` files first** (the second table in section 3): they are
   low-risk, and get you fluent in Nu's `def`/error-handling idioms before tackling the harder
   files.
3. **Replace `nvm` with `fnm` early and separately from the shell migration itself.** This
   decouples "can I manage Node versions in Nu" from "should I migrate my shell," since `fnm`'s
   `nu_scripts` module works today regardless of what your login shell is, and you will want to
   validate it independent of everything else breaking at once.
4. **Wire up `zoxide init nushell`** (native support, low risk) before touching `fzf`, since
   `zoxide`'s own `zi` interactive mode depends on `fzf` being callable, and you'll want to know
   whether your `fzf` workaround (Carapace bridging, or hand-written keybindings) is solid first.
5. **Tackle `fzf` integration explicitly as a known regression**, not an afterthought: decide up
   front whether you accept losing native CTRL-R/CTRL-T/ALT-C until fzf ships first-party Nu
   support, or invest in a Carapace-bridged or hand-rolled replacement.
6. **Port `wrap/nvim` and `wrap/chezmoi` last**, since they are the most logic-heavy and the most
   load-bearing for your actual chezmoi workflow (auto-add/re-add on edit). Test them hard before
   relying on them; a bug here risks silently failing to track an edited dotfile.
7. **Leave `chezmoi`'s `run_*` scripts and every `executable_*` script alone.** These are
   standalone, shebang'd scripts (`home/.chezmoiscripts/run_wezterm-terminfo` is
   `#!/usr/bin/env bash`) invoked as subprocesses by chezmoi, not sourced into an interactive
   shell. Changing your login/interactive shell does not affect them at all; confirmed by both
   reading these scripts' shebangs directly and by the general Nu behavior that running (as
   opposed to sourcing) a foreign script works fine since it is just an external process. No work
   needed here regardless of migration progress elsewhere.
8. **Only retarget `home/dot_config/termux/symlink_shell` (and any equivalent desktop login-shell
   setting) once steps 2 to 6 are stable**, and keep zsh installed and reachable (e.g. as `zsh` on
   PATH, or a keybinding/alias to drop into it) indefinitely for anything that still needs POSIX
   compatibility: piped installer one-liners, tutorials, and LLM-generated shell snippets, which
   overwhelmingly assume bash/zsh syntax.

## 6. Open risks and unknowns

- **fzf's Nushell integration timeline is unknown.** It is an open, unassigned feature request;
  there is no committed roadmap. This is the single largest unresolved dependency for matching
  current interactive functionality.
- **`stor`/`query db`'s rough edges** (JSONB round-tripping as strings, `get` failing on `stor
  open` handles) mean the SQLite story, while real, is not yet as polished as the marketing
  framing ("speaks SQLite... out of the box") suggests. Re-check these specific issues before
  building anything load-bearing on `stor`.
- **LLM and tutorial support for Nu syntax is materially weaker than for bash/zsh**, per the
  Ryan X. Charles writeup below, who reverted to zsh specifically over this friction. Since you
  (and presumably Claude Code sessions working in this repo) will often be pasting or generating
  shell snippets, this is a recurring tax, not a one-time cost, until Nu adoption grows.
  the same class of gap likely affects auto-completions and quick troubleshooting.
- **Whether `chezmoi completion nushell` exists** was not directly confirmed; if it does not,
  `util/chezmoi.rc.zsh`'s completion story falls back to Carapace bridging, which is real but
  imperfect (the Nushell cookbook itself notes Carapace's own completions for `nu` are sometimes
  wrong).
- **Breaking-change cadence**: 0.114.0's runtime-type-annotation change needed a same-cycle patch
  release (0.114.1) to fix fallout, and 0.112.0 was skipped entirely due to a crates.io release
  issue. Nu is still moving fast enough that pinning a version and reading changelogs before each
  upgrade is a real, recurring maintenance task, unlike zsh's much slower change rate.
- **No `add-zsh-hook`-equivalent survey was done for every Nu hook type** (`env_change`,
  `display_output`, etc.) against every remaining `rc/*.rc.zsh` file (only `util/` and `func/`/
  `wrap/` were read in depth for this report); a full port would need the same close reading
  applied to `rc/prompt.rc.zsh`, `rc/completion.rc.zsh`, `rc/history.rc.zsh`, and the others
  before committing to a timeline.

## 7. Sources

- [Nu Blog](https://www.nushell.sh/blog/) and [Releases · nushell/nushell](https://github.com/nushell/nushell/releases): version history, 0.115.1 patch notes, 0.114.0 runtime-annotation change.
- [termux-packages/packages/nushell/build.sh](https://github.com/termux/termux-packages/blob/master/packages/nushell/build.sh): Termux's official Nushell build/feature flags.
- [In Termux, cargo install nu --features=dataframe fails · Issue #12379](https://github.com/nushell/nushell/issues/12379): Android `arboard`/clipboard build failure when building from source.
- [query db | Nushell](https://www.nushell.sh/commands/docs/query_db.html) and [Support SQLite JSONB type with stor and query db · Issue #16216](https://github.com/nushell/nushell/issues/16216): `stor`/`query db` capability and known gaps.
- [`stor open | get $XY` gives error · Issue #14735](https://github.com/nushell/nushell/issues/14735): `stor`/`get` compatibility bug.
- [zoxide.org: zoxide init for Bash, Zsh, Fish, PowerShell and Nushell](https://zoxide.org/blog/zoxide-init-guide/) and [Nushell Integration | DeepWiki](https://deepwiki.com/ajeetdsouza/zoxide/5.5-nushell-integration): native zoxide/Nu support, `--cmd cd` limitation.
- [[Feature Request] nushell integration · fzf Issue #4122](https://github.com/junegunn/fzf/issues/4122): fzf's lack of first-party Nushell integration.
- [External Completers | Nushell](https://www.nushell.sh/cookbook/external_completers.html): Carapace bridging, per-tool completer exceptions.
- [Multiple completers · Discussion #15927](https://github.com/nushell/nushell/discussions/15927): Nu completion gaps versus zsh compsys.
- [Vi mode seems incomplete · Issue #5226](https://github.com/nushell/nushell/issues/5226) and [Reedline README](https://github.com/nushell/reedline/blob/main/README.md): Reedline vi-mode maturity versus zsh-vi-mode.
- [Plugins | Nushell](https://www.nushell.sh/book/plugins.html): nu-plugin protocol version coupling.
- [nushell-plugins complete-version-update-guide.md](https://repo.jesusperez.pro/jesus/nushell-plugins/src/commit/d9ef2f0d5b418f0ed6cb879e9d5f2f539b15019e/guides/complete-version-update-guide.md): real-world plugin-update maintenance burden across a version bump.
- [GitHub - Cerber-Ursi/nushell-nvm](https://github.com/Cerber-Ursi/nushell-nvm) and [Additional Environment Tools | nu_scripts DeepWiki](https://deepwiki.com/nushell/nu_scripts/4.3-additional-environment-tools): `nvm` incompatibility and `fnm` as the practical Nu-native replacement.
- [Why I Switched Back to Zsh from Nushell - Ryan X. Charles](https://ryanxcharles.com/blog/2025-05-26-nushell-to-zsh/): direct account of reverting, citing tutorial/LLM support gaps.
- [Nushell first impressions - Gabe Venberg](https://gabevenberg.com/posts/nushell/): hybrid daily-driver-plus-zsh-fallback account.
- [I migrated to Nushell for all of my Terminal scripts - XDA](https://www.xda-developers.com/migrated-nushell-terminal-scripts/): positive migration account, also notes `nvm`-to-Volta swap.
- [Foreign Shell Scripts | Nushell](https://www.nushell.sh/cookbook/foreign_shell_scripts.html) and [Source bash script · Issue #5505](https://github.com/nushell/nushell/issues/5505): confirms Nu cannot source POSIX shell scripts, can run them as opaque subprocesses only.
- [Overlays and structured env vars · Issue #15920](https://github.com/nushell/nushell/issues/15920) and [Module Scenarios | Nushell](https://www.nushell.sh/cookbook/modules.html): `overlay use`/`export-env` scoping mechanics, Python venv pattern as the model for scoped environments.

<!-- vim:set expandtab shiftwidth=2 filetype=markdown: -->
