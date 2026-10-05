---
ctime: 2026-09-09
mtime: 2026-10-05
spdx: GPL-3.0-only
title: Reference Directory
description: >-
  What ~/ref holds: standardised assets referenced from configuration, and where
  each is referenced from.
tags:
  - ref
  - dotfiles
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/home/ref/ref_dir.md
   -
   -->

# Reference Directory

This directory is employed as a means of standardised asset storage for
idiomatic reference within configuration and personal organisation. It is a
subdirectory of the home directory (`~`), and its scope does not impede on
the purviews of other subdirectories.

## Subdirectories

### image/

#### Referenced From

- `~/.config/hypr/chewy.lua`
  - `grim` screenshot destination directory: `top/screenshot/`
- `~/.config/hyprpaper.conf`
  - Wallpaper: `top/wallpaper/current-eDP-1`

### font/

#### Referenced From

- `~/.local/share/fonts`
  - As a symlink destination
- `~/.config/wezterm/wezterm.lua`
  - For it's shorter list of font assets than the system font directory

<!-- vim:set expandtab shiftwidth=2 filetype=markdown: -->
