---
ctime: 2026-11-03
mtime: 2026-11-03
spdx: GPL-3.0-only
title: Home Directory Structure Specification
description: >-
  Purpose-specific home directory organisation, XDG placement rules, and the
  local convention for containing inseparable application data.
tags:
  - dotfiles
  - filesystem
  - xdg
  - specification
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/docs/spec/2026-11-03_home-directory-structure-design.md
   -
   -->

# Home Directory Structure Specification

Status: accepted organisational direction, recorded on 2026-11-03. Application
migrations remain unimplemented by this documentation change.

The home directory should distinguish personal material from application files,
and application files should be segregated by purpose wherever the application
permits. Applications requiring an inseparable directory are contained beneath
`~/.local/var/<app>`.

This is a personal specification maintained in the dotfiles repository. It
adopts XDG conventions and adds an explicitly local exception. It does not claim
that `~/.local/var` is an XDG or filesystem-hierarchy standard.

Related documents:

- [Research and rationale][research].
- [Implementation and verification plan][plan].

## Intent and scope

The desired arrangement provides predictable locations for configuration,
reconstructible caches, retained state, installed resources, and personal files.
It supports selective backup and inspection without treating a monolithic
application directory as configuration merely because it was relocated beneath
`~/.config`.

The specification concerns the normal user's home directory. `~` denotes that
user's actual home, including on Android/Termux; it does not imply a fixed
`/home/chewygumxx` prefix. System directories and project-local files such as a
repository's `.codex/` are outside this placement policy.

This document records the selected organisation. The linked plan proposes how to
implement it incrementally; it does not authorise blanket removal of existing
directories or assume that every application can be migrated.

## Top-level directory structure

| Directory  | Purpose                                                    |
| ---------- | ---------------------------------------------------------- |
| `.local/`  | Application resources, executables, state, and mixed data. |
| `.cache/`  | Default location for reconstructible application caches.   |
| `.config/` | Default location for application configuration.            |
| `.ssh/`    | SSH configuration and identity material.                   |
| `arc/`     | Archive and backup.                                        |
| `dev/`     | Development.                                               |
| `doc/`     | Personal notes and documents.                              |
| `net/`     | Network-related material, including downloads.             |
| `ref/`     | Reference assets with an intentionally stable structure.   |
| `scr/`     | Scratch material.                                          |
| `sec/`     | Secret and private material.                               |

These are organisational roles, not instructions to relocate every existing
file. Additional top-level application directories should be treated as
compatibility exceptions and documented when retained.

Directory permissions are determined by their contents and required access. The
illustrative permission column in the original consultation is not a requirement
to apply one mode throughout the tree. In particular, private material should
not inherit permissive modes merely for visual consistency.

## Purpose-specific application locations

Use an application's supported paths to preserve the following classification.
Honour non-empty, absolute XDG overrides; the defaults below describe the
preferred layout when no override is supplied.

| Variable or location | Default                             |
| -------------------- | ----------------------------------- |
| `XDG_CONFIG_HOME`    | `~/.config`                         |
| `XDG_CACHE_HOME`     | `~/.cache`                          |
| `XDG_DATA_HOME`      | `~/.local/share`                    |
| `XDG_STATE_HOME`     | `~/.local/state`                    |
| `XDG_RUNTIME_DIR`    | Supplied by the session environment |
| User executables     | `~/.local/bin`                      |

Configuration belongs in the configuration root, reconstructible data in cache,
durable data and resources in the data root, and retained operational state such
as logs and history in the state root. Executables intended for `PATH` belong in
the user executable directory.

The XDG categories and defaults are defined in the [XDG Base Directory
Specification][xdg]. Runtime storage has session-lifetime and access
requirements; it must not be replaced with persistent storage under
`.local/var`.

Classify files by their meaning and recovery requirements, not their extension.
A database may contain durable user information, configuration, or a disposable
index. A JSON file may contain authentication material or session state. Opacity
does not make data a cache, and placement in `.local/state` does not by itself
make it safe to discard.

If an application mixes several categories inside one database, directory
relocation cannot separate its records. Record that limitation rather than
claiming complete segregation.

## Mixed application data

The selected local convention is:

```text
~/.local/var/<app>/
```

`var` borrows the Unix term for variable data. The full path is a personal
extension, and there is no implied `XDG_VAR_HOME` variable. Configuration
included in a mixed tree remains an acknowledged exception to purpose-specific
placement.

An application belongs here when it offers only one storage root, or when its
internal structure cannot reliably be separated. This location must not become
the default for applications that already support suitable XDG paths.

Use a stable application identifier, normally the established lowercase command
or package name. Where independently selected accounts or profiles need separate
roots, prefer `<app>/<profile>/` when the application permits that layout.
Profile names and final paths are application-level decisions to be recorded
during migration.

For example, a possible resulting layout is:

```text
~/.config/example/settings.toml
~/.cache/example/
~/.local/share/example/
~/.local/state/example/
~/.local/var/mixed-example/
```

These paths illustrate the classification; they do not require an application to
create every directory.

## Compatibility policy

Prefer supported per-purpose settings, followed by a supported relocation of the
mixed application root. Separate subdirectories using filesystem links only
after verifying that application writes and updates preserve the arrangement.

A symlink or ordinary bind mount at `~/.app` still occupies an entry in the home
directory. It may be a useful compatibility measure, but does not satisfy the
desired absence of that top-level entry.

An alternate-home launcher or private mount namespace is an optional
application-specific fallback. Neither is adopted as a universal execution
environment. Agents launch other tools, so their filesystem view must also
accommodate those tools' configuration, credentials, and workspaces.

Do not change the account's home directory globally to implement this
convention. Any execution wrapper requires a separate application-level design
and verification.

## Repository and data ownership

The repository tracks this specification, research, migration decisions, and the
declarative configuration needed to reproduce them. Runtime databases,
credentials, conversation transcripts, downloaded caches, and other
application-owned files do not become dotfiles merely because they live beneath
`.local/var`.

Within this repository, `home/` is the active chezmoi source root. Future
managed files targeting `.local/var` therefore use the appropriate source
attributes beneath `home/dot_local/var/`. An application directory should not be
added recursively to chezmoi without reviewing its contents and ownership.

The location of a mixed tree is not a backup policy. Until its contents have
been classified, preserve it as potentially containing irreplaceable data and
credentials. Document exclusions individually rather than purging the whole tree
as though it were a cache.

## Changes and exceptions

Each implemented migration should record its old and new paths, supported
controls, remaining exceptions, backup treatment, verification, and rollback
procedure. Record source links and the application version used to verify
behaviour.

Update this specification when the organisational policy changes. Keep
version-sensitive application findings in the research or implementation record
so they do not silently become permanent requirements.

[research]: ../notes/2026-11-03_home-directory-research.md
[plan]: ../plans/2026-11-03-home-directory-structure.md
[xdg]: https://specifications.freedesktop.org/basedir/latest/

<!-- vim:set expandtab shiftwidth=2 filetype=markdown: -->
