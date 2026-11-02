---
ctime: 2026-11-03
mtime: 2026-11-03
spdx: GPL-3.0-only
title: Home Directory Structure Research and Rationale
description: >-
  Research into XDG segregation, mixed application storage, relocation
  mechanisms, and the rationale for the ~/.local/var convention.
tags:
  - dotfiles
  - filesystem
  - xdg
  - research
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/docs/notes/2026-11-03_home-directory-research.md
   -
   -->

# Home Directory Structure Research and Rationale

Research and consultation date: 2026-11-03.

The adopted policy is recorded in the [specification][spec]. The [implementation
plan][plan] describes work that remains to be carried out.

## Problem and requirements

The increasing number of agent clients and related tools has introduced many
application-specific dot-directories directly beneath the user's home. The
desired structure retains a small, purposeful set of top-level directories and
segregates application files according to their role.

Moving a mixed directory to `XDG_CONFIG_HOME` does not meet that objective:
configuration remains intermingled with caches, databases, transcripts, and
other state. There are consequently two distinct requirements:

1. Reduce top-level application-directory proliferation.
2. Preserve meaningful separation within application storage where possible.

A containment directory addresses the first requirement. It only partially
addresses the second, and the documentation must keep that distinction visible.

## Standards and naming decision

The [XDG specification][xdg] defines purpose-specific locations, not a general
destination for a mixed application tree. The selected structure therefore
combines those locations with a local convention for applications that cannot be
split.

The [Linux filesystem hierarchy][hier] uses `/var` for persistent variable data.
Its `/opt` arrangement separates installed vendor software from configuration in
`/etc/opt` and variable data in `/var/opt`. The term `var` is an appropriate
analogy, but neither that hierarchy nor XDG standardises `~/.local/var` for
mixed user data.

| Candidate                | Assessment                                |
| ------------------------ | ----------------------------------------- |
| `~/.local/app/<app>`     | Can suggest an application installation.  |
| `~/.local/opt/<app>`     | Suggests installed software.              |
| `~/.opt/<app>`           | Same issue, plus another home entry.      |
| `~/.local/share/<app>`   | Standard data path, still mixed contents. |
| `~/.local/appdata/<app>` | Descriptive, but not standardised.        |
| `~/.var/app/<app-id>`    | Specific to Flatpak's containment model.  |
| `~/.local/var/<app>`     | Selected local convention.                |

The initial consultation proposed `app`. Further consideration selected `var`,
and the user explicitly accepted `~/.local/var/<app>`. The selection is based on
semantics and the desired layout, not a claim of widespread adoption of that
exact path.

## Relocation mechanisms

- Native per-purpose paths allow direct placement, subject to the controls
  exposed by the application.
- A native mixed-root override can remove the original home entry without
  changing the account's home. Internal categories remain mixed unless
  separately configurable.
- Links inside a relocated root can separate selected contents. Writers and
  updaters may replace or reject those links.
- A symlink or ordinary bind mount at the original path relocates storage but
  retains the top-level entry.
- A process-specific alternate home can redirect applications that respect it.
  Other home-discovery methods may bypass it, and child processes inherit the
  altered environment.
- A private mount namespace can present a replacement home at the original
  absolute path. It requires filesystem mappings and integration testing.

File symlinks are not universally transparent to atomic replacement. Database
sidecars and locking also need consideration; relocating only one file from an
application's database directory is not a generic recipe.

[Bubblewrap][bwrap] constructs a private mount namespace. As an
application-specific design, this can present a replacement home while exposing
selected real working directories. That is a possible mechanism, not a tested
wrapper for this machine. For agents, Git, SSH, language tools, sockets, and
child processes make a minimal filesystem view insufficient.

[Flatpak][flatpak] provides an established containment arrangement beneath
`~/.var/app/<app-id>`. Its `--persist=.foo` option can retain a hard-coded
`~/.foo` inside that host-side tree when broad home access is absent. This
demonstrates a working namespace-based approach; it does not make Flatpak's
directory name a general requirement for non-Flatpak software.

## Application controls identified

These are documentation findings as of the research date. They are not evidence
that relocation has been performed or tested against every installed client,
plugin, or service.

- Claude Code: `CLAUDE_CONFIG_DIR` relocates settings, history, and plugins
  together. The name does not imply configuration-only storage. Credential
  handling needs separate verification for the installation and authentication
  method. See [Claude Code environment variables][claude].
- Codex: `CODEX_HOME` provides overall relocation, while `sqlite_home` and
  `log_dir` offer narrower database and log destinations. This is partial
  separation. Official OpenAI documentation covers [storage][codex] and
  [configuration keys][codex-ref]. Explicitly setting `log_dir` also enables the
  optional plaintext TUI log according to the current reference; migration
  should account for this behavioural effect.
- OpenClaw: `OPENCLAW_CONFIG_PATH` and `OPENCLAW_STATE_DIR` separate the active
  configuration-file path from the mutable root. Remaining contents still
  require classification. See [path controls][openclaw] and
  [configuration][oc-config]. Writes require a regular configuration file; use
  its explicit path control to place that file outside the state root.

Launch environment matters. A terminal, editor integration, desktop launcher,
and service may not receive the same variables. A successful interactive launch
alone cannot establish that an old directory will stop being recreated.

## Observations from the current machine

Read-only inspection found 41 top-level dot-directories whose only child was
`skills/`, with every entry in those skill directories a symlink resolving
beneath `~/.agents/skills`. Examples included `.adal`, `.aider-desk`, and
`.augment`. The count excludes the canonical `.agents` directory itself.

This pattern is consistent with installing skills for all supported agent
targets. The [skills CLI reference][skills] documents that `--all` selects all
skills and agents, while `--agent` selects particular targets. The exact
historical command was not verified; directory names alone do not establish
which applications are installed or used.

Before migrating those entries, identify the intended agent targets and the
installer that maintains the links. Removing unused registrations may resolve
much of the clutter, but deleting the shared source would affect other agents.
No such deletion was performed during this work.

The `codex` command also resolved through
`~/.cache/.bun/install/global/node_modules/@openai/codex/bin/codex.js`.
Installed tools should be reviewed separately from disposable download caches.
This observation is a migration candidate, not a completed audit of the Bun
installation.

## Repository findings and remaining work

- The active chezmoi source root is `home/`; `docs/` is documentation only.
- `home/dot_config/environment.d/91-xdg.conf` declares the preferred
  configuration, cache, data, and state locations. It also hard-codes
  `/run/user/1000`; runtime-directory portability requires separate review.
- `home/.chezmoi.toml.tmpl` falls back to `.local/cache` when the cache variable
  is absent. Existing `home/dot_local/cache/` entries also need classification
  before adopting `.cache` consistently.
- Claude configuration currently has source directories beneath
  `home/dot_config/claude/` and `home/dot_config/claude-2/`. The second
  account's settings source links to the first. A migration must preserve that
  relationship and the hooks that use `CLAUDE_CONFIG_DIR`.
- Zsh configuration is fetched from the separate `zsh-config` repository.
  Changes to shell-owned environment definitions belong there rather than being
  made only in deployed files.

These findings establish work to investigate, not blanket instructions to move
existing files. Application versions, launch routes, retention needs, and
compatibility exceptions remain to be recorded during implementation.

[spec]: ../specs/2026-11-03-home-directory-structure-design.md
[plan]: ../plans/2026-11-03-home-directory-structure.md
[xdg]: https://specifications.freedesktop.org/basedir/latest/
[hier]: https://uapi-group.org/specifications/specs/linux_file_system_hierarchy/
[bwrap]: https://github.com/containers/bubblewrap#usage
[flatpak]: https://docs.flatpak.org/en/latest/sandbox-permissions.html
[claude]: https://code.claude.com/docs/en/env-vars
[codex]: https://learn.chatgpt.com/docs/config-file/config-advanced
[codex-ref]: https://learn.chatgpt.com/docs/config-file/config-reference
[openclaw]: https://docs.openclaw.ai/help/environment
[oc-config]: https://docs.openclaw.ai/gateway/configuration
[skills]: https://github.com/vercel-labs/skills/blob/main/docs/commands.md

<!-- vim:set expandtab shiftwidth=2 filetype=markdown: -->
