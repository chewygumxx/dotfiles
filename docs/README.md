---
ctime: 2026-11-05
mtime: 2026-11-05
spdx: GPL-3.0-only
title: ":/docs/README.md"
description:
tags:
  - docs
  - readme
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/docs/README.md
   -
   -->

# :/docs/README.md

Documentation pertaining to the development of this repository.

## Navigation

- [Documentation Home](./README.md) - You found it ^-^.
- [Decision Rationale](./wiki/decisions.md) - Decisions made, changed, and their rationale.
- [Record Index](./wiki/records.md) - Exhaustive record index.
- [Agentic Instructions](./AGENTS.md) - Additional context beyond this file.

## File/Directory Tree

| File/Dir     | Content                                                        | Additional Notes                                                                                                                                                      |
| ------------ | -------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `spec/`      | Proposed specification of potential development                | Typically composed following research                                                                                                                                 |
| `plan/`      | Proposed implementation strategy of specification              |                                                                                                                                                                       |
| `report/`    | Rationale, rulings, verification, testing                      | Major pull requests often include a respective report                                                                                                                 |
| `deferred/`  | Unresolved matters designated for later settlement             | Typically minor matters that are expected to be addressed later anyway                                                                                                |
| `note/`      | Miscellaneous notation retained for reference                  | Research, conjecture, approaches, justification, etc.                                                                                                                 |
| `wiki/`      | Wikipedia-like pages per relevant subject                      | Dual purpose as a brief conceptual overview and maintened reference. topics, profiles, decisions, questions, problems and priorities, linking the records as evidence |
| `roadmap.md` | Projected implementation phase order, abstract and prequisites |                                                                                                                                                                       |
| `README.md`  | Documentation overview, progressive disclousure friendly       | If it doesn't detail, it references in the general direction.                                                                                                         |

## Filename Convention

Filename format conforms to `YYYY-MM-DD_<abbreviated-title>.md` where
`YYYY-MM-DD` is the creation time (ctime) of the document. The living
reference, `README.md` and `wiki/`, takes stable descriptive names, with
no date; existing dated paths stay as they are.

## Document Structure

### Frontmatter

Markdown YAML frontmatter (`ctime`, `mtime`, `spdx`, `title`,
`description`, `tags`) and the breadcrumb comment; copy both from a
sibling, and bump `mtime` when you edit. `lint:header` checks the
breadcrumb against the file's path.

### Line Length

Lines are at most 80 characters, inline code included: a long command
goes in a fenced block. Links are Markdown links, never `[[...]]` wiki
links. `lint:md` runs remark and markdownlint, which enforce both.

<!-- vim:set expandtab shiftwidth=2 filetype=markdown foldlevel=3: -->
