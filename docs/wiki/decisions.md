---
ctime: 2026-11-03
mtime: 2026-11-05
spdx: GPL-3.0-only
title: Decisions
description: >-
tags:
  - docs
  - decisions
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/docs/wiki/decisions.md
   -
   -->

# Decisions

[Docs Home](./../README.md)

This document records significant decisions that have shaped the project or
continue to guide its development. Each entry preserves the circumstances,
alternatives, rationale, consequences, and supporting evidence behind a
decision, together with its current standing.

The purpose of this document is to preserve **why decisions were made**, not
to duplicate descriptions of their implementation. Reference documentation
describes the project's current state; this document traces the decisions
behind it and links to relevant documentation where appropriate.

Decisions are organised by subject, following the project's documentation
structure where one exists. Entries are derived from supporting records,
including specifications, design documents, implementation reports, roadmap
revisions, and explicitly documented directives.

Only decisions with meaningful architectural, operational, or strategic
implications belong here. Minor implementation decisions remain in their
respective records.

## Entry Structure

Each decision is documented under a descriptive heading, followed by a list
of consistently ordered fields:

- **Context**: The circumstances, requirements, or constraints that
  prompted the decision.
- **Weight**: The documented or reasonably established trade-offs, risks,
  limitations, or consequences of the decision, including the potential
  cost of an incorrect choice. Distinguish recorded costs from
  independently identified risks.
- **Choice**: The decision made, including its date and decision-maker
  where documented. Neither authorship nor approval may be inferred solely
  from the existence of a specification or implementation.
- **Reason**: The documented rationale for the decision. Use
  `not recorded` when no rationale is available.
- **Status**: Present state of decision implementation.
- **Confidence**: Validity sentiment relative to implementation status and
  current information.
- **History**: Log of any subsequent revision, replacement, or reconsideration.
  Include relevant dates and reference subsequent decisions. Distinguish a
  decision's standing from its implementation status.
- **Alternatives**: Other approaches considered or rejected, including their
  documented trade-offs. State when no alternatives were recorded.
- **Sources**: Additional material relevant to decision and its interpretation,
  including links to current documentation where useful.

## Documentation Principles

Entries must remain faithful to their supporting records. Missing
information must be identified rather than inferred, reconstructed, or
presented as established fact.

Distinguish proposals from adopted decisions, recorded rationale from
subsequent interpretation, and documented authority from assumed approval.

When a decision changes, preserve its original context and identify the
subsequent decision responsible for the change. Do not silently rewrite
historical reasoning to reflect present circumstances.

Keep entries concise and focused on decision-making. Refer readers to
supporting records for implementation details, extended analysis, and
verification results.

<!-- vim:set expandtab shiftwidth=2 filetype=markdown foldlevel=3: -->
