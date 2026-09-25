---
__cgxx: |
  # vim:set expandtab shiftwidth=2 filetype=markdown:
  # SPDX-License-Identifier: GPL-3.0-only

  #
  #
  # ~chewygumxx/dotfiles.git
  # ::: :/home/dot_config/claude/CLAUDE.md
  #
  #

ctime: 2026-09-21
title: CLAUDE.md
---

# CLAUDE.md

## Markdown

- A hook reflows `.md` files to 80 columns after every Write or Edit. In
  those files, write each paragraph as one long line. Never count columns,
  wrap by hand, or run a formatter or width check yourself.
- Create and edit `.md` files with the Write and Edit tools, never through
  Bash (heredocs, `>`, `tee`, `sed -i`); the hook only fires on those tools.
- The hook rewrites the file after each write, so the on-disk text is
  wrapped and can make the next Edit fail as modified since read. Make all
  changes to a `.md` file in one call where practical, and Read it again
  before editing it a second time.
- Do not draft prose in scratch files (for example `/tmp/*.txt`) to wrap or
  measure it. Nothing reflows those files, and the round trip costs tokens.
- Chat replies are not covered by the hook. Wrap them at roughly 80 columns
  as you write. Approximate is fine; do not measure or redraft.
- Fenced code, tables, and unbreakable URLs may exceed 80 columns.
