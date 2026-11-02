---
ctime: 2026-11-03
mtime: 2026-11-03
spdx: GPL-3.0-only
title: Home Directory Structure Implementation Plan
description: >-
  Incremental implementation, verification, and rollback guidance for the home
  directory specification and mixed application data convention.
tags:
  - dotfiles
  - filesystem
  - xdg
  - implementation
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/docs/plans/2026-11-03-home-directory-structure.md
   -
   -->

# Home Directory Structure Implementation Plan

Status: proposed rollout guidance. No application migration is implemented by
the documentation commit that introduces this plan.

The [specification][spec] records the accepted organisation. The
[research][research] records the supporting sources, alternatives, and initial
machine observations.

## Delivery boundaries

Implement the specification one application at a time. Record policy and
declarative changes in this repository, while keeping live application data
outside Git. Changes to the separately maintained Zsh configuration must be
committed in its own repository and referenced here when relevant.

The first delivery consists of the specification, research, and this plan.
Subsequent deliveries should include application-specific evidence and rollback
instructions. Directory creation alone does not demonstrate that an application
follows the new layout.

## 1. Inventory ownership and launch routes

For each candidate, identify the owner of the existing directory and the
contents that must survive relocation. Record the installed application version
and verify supported path controls against that version.

Capture the following information without copying secrets or conversation
contents into the documentation:

| Field          | Required information                                 |
| -------------- | ---------------------------------------------------- |
| Existing paths | Roots, secondary accounts, and profiles.             |
| Contents       | Categories, credentials, and installed software.     |
| Target paths   | XDG destinations and mixed-data exceptions.          |
| Controls       | Supported variables, flags, or configuration keys.   |
| Launch routes  | Shell, desktop, editor, jobs, services, updaters.    |
| Dependencies   | Hooks, plugins, links, subprocesses, absolute paths. |
| Retention      | Backup scope, disposable contents, restore needs.    |
| Validation     | Checks establishing successful relocation.           |
| Rollback       | Original settings and recovery procedure.            |

Prioritise the skill-only directories separately from actual application
storage. Confirm which agent targets are used and how their registrations are
maintained before proposing removal. Preserve shared skill sources and any links
still required by active clients.

## 2. Select placement per application

Prefer native controls that separate individual data categories. Where only an
overall root is configurable, select `.local/var/<app>` and document the mixture
that remains.

Examples to investigate, not declarations of completed configuration:

- Claude Code: relocate each required account root and preserve shared settings
  and hook behaviour.
- Codex: assess its overall root and narrower database/log destinations,
  including the effects on plugins, authentication, and existing sessions.
- OpenClaw: assess a separate configuration-file path and mutable root,
  including the service environment and workspace paths.

Use an interior symlink only after checking the relevant writer and updater.
Keep database sidecars with their database. Where configuration and other
information share a database, retain the indivisible store and record the
exception.

If native controls cannot remove a top-level entry, decide explicitly between
retaining that entry and designing an application-specific filesystem wrapper.
Do not introduce a global alternate home or a generic wrapper for every agent.

## 3. Update the authoritative configuration

Locate the source of each launch environment before editing it. Ensure shell
commands, services, editor integrations, and desktop launchers use the same
intended storage paths. Avoid maintaining independent defaults that silently
recreate the old directory.

Within chezmoi, target paths beneath `.local/var` correspond to source paths
beneath `home/dot_local/var/`, with source attributes added as appropriate.
Manage only reviewed configuration or launch integration; do not recursively add
runtime application trees.

Review existing fallback paths and cache placement as a separate change. In
particular, account for the `.local/cache` fallback and existing source entries
rather than assuming that setting `XDG_CACHE_HOME` migrates them. Preserve
session-provided runtime-directory semantics instead of relying on a fixed
numeric UID across hosts.

Commit each coherent declarative change with a single-purpose commit. Keep
unrelated staged or working-tree changes out of those commits.

## 4. Rehearse and migrate

Rehearse the destination layout using the repository's chezmoi sandbox workflow.
Destination, cache, and persistent state must be isolated, and scripts must be
excluded or individually verified not to touch the real home. Inspect the
rendered configuration and diff before deployment.

For an application migration:

1. Stop every process and service that may write the affected data.
2. Make an appropriate backup or consistent snapshot, preserving modes and
   links. Do not copy an actively written database as though an ordinary file
   copy guaranteed consistency.
3. Check destination ownership, available space, and existing contents. If both
   old and new roots contain data, reconcile them explicitly; do not merge or
   overwrite automatically.
4. Place the reviewed data at its destination, preserving a recovery copy
   outside the application's normal discovery paths.
5. Activate the authoritative path controls and restart through the intended
   launch routes.
6. Perform the checks below before retiring the old active directory.

Live application changes are a separate implementation step. The documentation
commit neither runs chezmoi against the real home nor installs wrappers, moves
data, or removes skill registrations.

## 5. Verify behaviour

Verification should establish that the application uses the intended files, not
merely that it starts successfully.

- Existing settings, accounts, history, and required plugins remain available
  according to the migration's retention requirements.
- Creating and updating representative data writes to the expected location,
  including after restarting the application.
- Each supported launch route uses the same intended roots.
- The old top-level directory is not recreated, or its continued presence is
  recorded as an explicit exception.
- Hooks and child tools still find their configuration and resources.
- Authentication continues to work without placing credentials in Git.
- Backup and restore cover durable data; cache deletion is tested only for
  contents confirmed to be reconstructible.
- Updaters preserve the arrangement. Where a future update cannot yet be
  exercised, record that limitation and check it at the next update.
- The chezmoi diff is limited to intended targets and introduces no unreviewed
  removals or credential changes.

Keep a dated report under `docs/reports/` for each completed migration. Include
versions, commands or procedures used, results, remaining exceptions, and links
to the relevant implementation commits.

## 6. Roll back without losing new data

Stop all writers before rollback. Preserve data created after migration; an old
backup is not automatically the correct current state.

Restore the former launch configuration and reconcile the application's current
data with its previous location using an application-appropriate procedure.
Restart and repeat the essential functionality checks. Keep the migration backup
until both application behaviour and recovery have been verified.

Do not run old and new instances against competing copies of the same profile
during recovery. Record the failure and resulting placement as a compatibility
exception rather than leaving the repository and live environment with
contradictory path definitions.

## Completion criteria

An individual application migration is complete when its intended launch routes
consistently use the documented layout, required data is retained, rollback is
understood, and all remaining exceptions are recorded.

The broader specification is implemented incrementally. A small number of
justified compatibility entries does not make unverified bulk moves preferable;
each exception remains visible and reviewable in the record.

[spec]: ../specs/2026-11-03-home-directory-structure-design.md
[research]: ../notes/2026-11-03_home-directory-research.md

<!-- vim:set expandtab shiftwidth=2 filetype=markdown: -->
