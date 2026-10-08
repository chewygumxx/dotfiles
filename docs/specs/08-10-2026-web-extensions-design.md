---
ctime: 2026-10-08
mtime: 2026-10-08
spdx: GPL-3.0-only
title: "Design: Chezmoi Managed Web Extensions"
description: >-
  Design specification for declaratively installing and updating Firefox
  and ungoogled-chromium extensions via chezmoi externals, and for
  reorganising browser data under ~/.local/share.
tags:
  - firefox
  - chromium
  - chezmoi
  - dotfiles
  - web-extensions
  - design
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/docs/specs/08-10-2026-web-extensions-design.md
   -
   -->

# Design: Chezmoi Managed Web Extensions

Background discussion: [conversation](../notes/08-10-2026-claude-conversation-web-extensions.md).

## Goals

1. One list of extensions in chezmoi data drives both Firefox and
   ungoogled-chromium.
2. `chezmoi apply --refresh-externals` installs and updates every listed
   extension. No root access is required.
3. All browser data lives under `~/.local/share`, one tree per vendor, with
   no symlink round trips through `~/.config`.
4. Both browsers launch through shadow wrappers in `~/.local/bin`, including
   from their systemd user units.

## Non-goals

- Uninstalling extensions removed from the list. chezmoi stops managing the
  file and it stays on disk. Remove it in the browser.
- Managing extension settings. They live in per-profile storage keyed by
  random UUIDs (Firefox) or path hashes (Chromium).
- System policies (`/etc`). Deferred until root dotfiles management exists;
  see [Future: system policies](#future-system-policies).

## Verified constraints

Each of these was tested on this machine on 2026-10-08. Evidence is in the
[verification report](../notes/08-10-2026-web-extensions-verification.md).

- **Firefox 157 only sideloads new add-ons from the profile scope.**
  `AddonSettings.sys.mjs` hardcodes `SCOPES_SIDELOAD = SCOPE_PROFILE` unless
  the build sets `MOZ_ALLOW_ADDON_SIDELOAD`, which release builds do not.
  The user scope (`~/.mozilla/extensions/{ec8030f7-...}/`) is ignored for new
  add-ons, and no pref changes that.
- **Profile-scope sideloads need `extensions.autoDisableScopes = 14`.** With
  the default of `15`, the add-on installs disabled and waits for a prompt.
  With `14` it is active and signed on first start.
- **AMO serves the latest signed XPI by add-on ID.**
  `https://addons.mozilla.org/firefox/downloads/latest/<url-escaped-id>/latest.xpi`
  resolved for 38 of 40 installed profile add-ons. The exceptions are
  `newtab@mozilla.org` (built in) and the `en-GB` language pack (AMO's
  latest targets the next Firefox version).
- **ungoogled-chromium 153 still honours `--load-extension`** for unpacked
  MV3 extensions.
- **Chromium 153 rejects Manifest V2.** `uBlock0_*.chromium.zip` and
  `darkreader-chrome.zip` are MV2. Use `uBOLite_*.chromium.zip` from
  `uBlockOrigin/uBOL-home` and `darkreader-chrome-mv3.zip` instead.

## Target layout

```text
~/.config/mozilla -> ../.local/share/mozilla      (kept; Firefox XDG lookup)
~/.local/share/
  mozilla/firefox/
    profiles.ini, installs.ini                     (real files, tracked)
    chewyfox/
      user.js, chrome/                             (real files, tracked)
      extensions/<add-on-id>.xpi                   (externals, type "file")
  chromium/
    chewy-ungoogled/                               (--user-data-dir, unmanaged)
    extensions/<name>/                             (externals, type "archive")
```

Removed: the source tree `home/dot_config/mozilla-firefox/` (including the
tracked 549 KB `extensions.json`, which is volatile Firefox state and was not
even the live copy), the four `symlink_*` entries pointing into it, and the
`chromium-extensions/` and `firefox-extensions/` placeholder directories.
`~/.config/mozilla-firefox` is deleted from targets via `.chezmoiremove`.

## Components

### Data: `home/.chezmoidata/web-extensions.toml`

Moved to the source root because it now feeds two vendor directories. Each
entry names one extension and says how each browser gets it. Either browser
key may be omitted.

```toml
[[webExtensions]]
name     = "ublock-origin"
firefox  = "uBlock0@raymondhill.net"
chromium = { repo = "uBlockOrigin/uBOL-home", asset = "uBOLite_*.chromium.zip" }
```

- `name`: stable identifier, and the Chromium extension directory name.
  Renaming it changes the unpacked extension ID and loses its Chromium
  settings.
- `firefox`: the AMO add-on ID (shown in `about:support`).
- `chromium.repo`, `chromium.asset`: GitHub repository and release asset
  glob for an unpacked MV3 zip. Optional `chromium.stripComponents` for zips
  that nest everything in one folder.

### Firefox externals

`home/dot_local/share/private_mozilla/private_firefox/chewyfox/.chezmoiexternals/web-extensions.toml.tmpl`
emits one `type = "file"` entry per extension with a `firefox` key, at
`extensions/<id>.xpi`, from the AMO latest URL, `refreshPeriod = "168h"`.
The profile's `.chezmoiignore` gains `!extensions/` so these targets are not
ignored.

`user.js` gains two prefs:

- `extensions.autoDisableScopes = 14`: enable profile-scope sideloads without
  a prompt.
- `extensions.update.autoUpdateDefault = false`: chezmoi owns updates.
  Without this, Firefox rewrites `<id>.xpi` on its own schedule, `chezmoi
  diff` shows drift, and `chezmoi apply` can write an older cached XPI back.
  This applies to every add-on, including unlisted ones. Firefox still
  checks for updates, so `about:addons` shows them and they can be applied
  by hand.

### Chromium externals

`home/dot_local/share/chromium/.chezmoiexternals/web-extensions.toml.tmpl`
emits one `type = "archive"` entry per extension with a `chromium` key, at
`extensions/<name>`, using `gitHubLatestReleaseAssetURL`,
`refreshPeriod = "168h"` and `exact = true`. `exact` removes files left over
from the previous version when an extension updates.

### Wrappers: `home/dot_local/bin/executable_{chromium,firefox}`

Self-contained zsh shadow wrappers that follow the sibling `wget` and
`xdg-open` wrappers: resolve the real binary from `PATH` while skipping the
wrapper's own directory, then `exec` it with a flags array.

- Resolution uses a private copy of `path`, so the browser inherits the
  user's unmodified `PATH`. The current draft strips `~/.local/bin` from the
  browser's own environment.
- `chromium` passes `--user-data-dir=$XDG_DATA_HOME/chromium/$PROFILE` and
  `--load-extension=` joined from every `extensions/*/` that contains a
  `manifest.json`. The broken profile-creation block is dropped, since
  Chromium creates the directory itself.
- `firefox` passes `-P "$PROFILE"` so the profile is chosen explicitly
  rather than depending on `installs.ini` hash matching.

### systemd user units

`firefox.service` and `ungoogled-chromium.service` launch
`%h/.local/bin/{firefox,chromium}`.

### Migration: `run_once_before_` script

`home/.chezmoiscripts/run_once_before_migrate-chromium-profile` moves
`~/.local/share/chewy-ungoogled` to `~/.local/share/chromium/chewy-ungoogled`
if the old path exists, the new one does not, and Chromium is not running.
Otherwise it prints why it skipped and exits 0, so `chezmoi apply` continues.
The leftover `~/.config/chromium` (from a launch that bypassed the wrapper)
stays untouched and is mentioned in the docs.

## Error handling

- A failed download or GitHub API error makes chezmoi abort before writing
  anything. Rerun after fixing; no partial state.
- `gitHubLatestReleaseAssetURL` calls the GitHub API at template time.
  Unauthenticated limits are 60 requests per hour, and setting
  `GITHUB_TOKEN` raises that.
- A Chromium extension directory without `manifest.json` (for example, a
  nested zip needing `stripComponents`) is skipped by the wrapper with a
  warning instead of breaking the launch.

## Testing

No test suite exists, so verification is behavioural and recorded in the
verification report:

1. `chezmoi execute-template` and `chezmoi managed` succeed, which shows the
   templates parse.
2. `chezmoi apply --destination <tmp>` produces the target layout.
3. Headless Firefox on the applied temp profile reports every listed add-on
   as `app-profile`, active and signed.
4. Headless Chromium through the wrapper, with `XDG_DATA_HOME` pointed at
   the temp tree, starts one service worker per listed extension.
5. `chezmoi diff` against the real home shows only the intended changes.
   The real `chezmoi apply` is left to the user, run with both browsers
   closed.

## Future: system policies

Once root dotfiles management exists (`root/` becomes a live source root),
Firefox can switch to `/etc/firefox/policies/policies.json` with
`ExtensionSettings` (`installation_mode`, `install_url` per add-on ID). That
gives native AMO updates without the `autoUpdateDefault` trade-off, and
`force_installed` can lock add-ons. The same data file can render it, since
the policy is keyed by the same add-on IDs. Chromium's equivalent
(`/etc/chromium/policies/managed/*.json`, `ExtensionInstallForcelist`) needs
a self-hosted update manifest on ungoogled builds, so unpacked extensions
stay the better fit there.

<!-- vim:set expandtab shiftwidth=2 filetype=markdown: -->
