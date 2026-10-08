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
4. ungoogled-chromium launches through a shadow wrapper in `~/.local/bin`,
   including from its systemd user unit. Firefox needs no flags, so it has
   no wrapper and its unit runs `/usr/bin/firefox`.

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
- **Manifest V2 has no future on Chromium.** `uBlock0_*.chromium.zip` and
  `darkreader-chrome.zip` are MV2, as is TWP's only Chromium build.
  Upstream Chromium has removed MV2. ungoogled-chromium 153 still runs it
  (corrected during implementation, see the verification report), but the
  design sticks to MV3 builds so nothing breaks when that ends.
- **Web Store CRXs can be fetched without a browser** from
  `https://clients2.google.com/service/update2/crx?response=redirect&prodversion=<major>&acceptformat=crx3&x=id%3D<id>%26uc`.
  ungoogled-chromium substitutes Google domains at runtime, but chezmoi
  fetches the file itself, so that substitution never applies.
- **An unpacked extension keeps its Web Store ID only if `manifest.json` has
  `key`.** Without it the ID is a hash of the directory path. Claude and
  Proton VPN ship `key`, but Proton Pass (whose `externally_connectable`
  sign-in flow targets its store ID), SingleFile, HeadingsMap and Auto Tab
  Discard do not.
- **The CRX3 header carries the publisher key.** It is the
  `sha256_with_rsa` or `sha256_with_ecdsa` proof whose SHA-256 prefix equals
  `signed_header_data.crx_id`. Writing it into `manifest.json` as base64
  `key` gives every unpacked extension its store ID, which was confirmed
  for Claude, Proton Pass and SingleFile in ungoogled-chromium 153.
- **CRX zip entries carry unusable permission bits** (one directory came out
  unreadable). The conversion must normalise modes and drop `_metadata/`
  (store integrity data that unpacked loads do not use).

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
[webBrowsers.chromium]
version = "153"

[[webExtensions]]
name     = "ublock-origin"
firefox  = "uBlock0@raymondhill.net"
chromium = "ddkjiahejlhfcafbddmgiahcphecmpfh"

[[webExtensions]]
name     = "imagus-reborn"
firefox  = "{7653b5cb-d76d-442f-a98f-f3c83a118cf4}"
chromium = { repo = "hababr/Imagus-Reborn", asset = "ImagusReborn_Chrome_*.zip" }
```

- `name`: stable identifier, and the Chromium extension directory name.
  For GitHub-sourced extensions without `key`, renaming it changes the
  unpacked extension ID and loses its Chromium settings.
- `firefox`: the AMO add-on ID (shown in `about:support`).
- `chromium` as a string: a Chrome Web Store ID (the last path segment of
  its store URL). This is the default source.
- `chromium` as a table: `repo` and `asset` name a GitHub release asset glob
  for an unpacked MV3 zip, for extensions not on the Web Store. Optional
  `stripComponents` for zips that nest everything in one folder.
- `webBrowsers.chromium.version`: the major version sent as `prodversion`,
  so the Web Store serves builds compatible with the installed browser.

Initial list (2026-10-08):

| Extension | Firefox | Chromium |
| --- | --- | --- |
| Auto Tab Discard | yes | Web Store |
| Claude | none (Chromium only) | Web Store |
| Dark Reader | yes | Web Store |
| DeArrow | yes | Web Store |
| HeadingsMap | yes | Web Store |
| Hide shorts for YouTube | yes | Web Store |
| Imagus Reborn | yes | GitHub |
| Obsidian Web Clipper | yes | Web Store |
| Proton Pass | yes | Web Store |
| Proton VPN | yes | Web Store |
| Return YouTube Dislike | yes | Web Store |
| Sidebery | yes | none (Firefox only) |
| simple-modify-headers | yes | Web Store |
| SingleFile | yes | Web Store |
| SponsorBlock | yes | Web Store |
| Stylus | yes | Web Store |
| TWP - Translate Web Pages | yes | none (MV2 only) |
| uBlock Origin | yes | Web Store (uBlock Origin Lite) |
| Violentmonkey | yes | Web Store |

Firefox-only additions, covering every other installed AMO add-on:

| Add-on | Type |
| --- | --- |
| Australian English Dictionary | dictionary |
| British English Dictionary (Marco Pinto) | dictionary |
| ClearURLs | extension |
| ContextSearch web-ext | extension |
| Cookie-Editor | extension |
| Download All Images | extension |
| Image Search Options | extension |
| Imagus mod | extension |
| Load Reddit Images Directly | extension |
| Open Multiple URLs | extension |
| ScriptCat (脚本猫) | extension |
| Tab Image Saver | extension |
| UltimaDark | extension |
| View Image | extension |
| Blue Cyberpunk, Pixel Cyberpunk, Cyberpunk 2077 3, Cyberpunk Lo-Fi, Cyberpunk Pixels - Animated, ITJ's Cyberpunk Dark Edit | theme |

Deliberately excluded:

- `newtab@mozilla.org`: built into Firefox, not hosted on AMO.
- `langpack-en-GB@firefox.mozilla.org`: language packs must match the
  Firefox version exactly, and AMO's latest already targets the next
  release. Under `autoUpdateDefault = false` a chezmoi-managed langpack
  would break on every Firefox upgrade. Install the Arch package
  `firefox-i18n-en-gb` instead, which pacman upgrades in lockstep with
  `firefox`.

Add-ons installed later through `about:addons` and not added to this list
stay unmanaged, and under `autoUpdateDefault = false` they do not update
automatically either. Add them to the list.

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
`extensions/<name>`, with `refreshPeriod = "168h"` and `exact = true`.
`exact` removes files left over from the previous version when an extension
updates.

- **Web Store ID:** `url` is the CRX endpoint above, `format = "zip"`, and
  `filter.command = "python3"` with `filter.args = ["-I", <crx-unpack>]`.
  The filter reads the CRX on stdin and writes a zip on stdout with `key`
  injected, modes normalised and `_metadata/` dropped.
- **GitHub table:** `url` is `gitHubLatestReleaseAssetURL repo asset`, with
  no filter.

### CRX converter: `home/dot_local/bin/executable_crx-unpack`

A dependency-free Python 3 script, the only non-shell code in this design.
Python's `zipfile` reads the zip past the CRX header, and a 20-line protobuf
walker reads the header. The externals template invokes it by its source
path (`joinPath .chezmoi.sourceDir ...`) through `python3 -I`, so it works
on the very first `chezmoi apply`, before `~/.local/bin` exists, and
regardless of the repo's disabled in-repo executability. It is also
deployed to `~/.local/bin/crx-unpack` for manual use
(`crx-unpack < x.crx > x.zip`). It exits non-zero on a non-CRX3 input or a
missing publisher key, which aborts the apply instead of installing an
extension under the wrong ID.

### Host scoping

Termux runs neither browser, so `home/.chezmoiignore` ignores
`.local/share/chromium/`, `.local/share/mozilla/`, the `chromium`
wrapper, `crx-unpack`, and the browser systemd units under the Termux condition.
That also keeps chezmoi from downloading roughly 40 extensions there.

### Wrapper: `home/dot_local/bin/executable_chromium`

A self-contained zsh shadow wrapper that follows the sibling `wget` and
`xdg-open` wrappers: resolve the real binary from `PATH` while skipping the
wrapper itself, then `exec` it with a flags array.

- Resolution skips any `PATH` candidate whose resolved path is the wrapper,
  so a symlinked or trailing-slash spelling of `~/.local/bin` cannot make it
  exec itself, and the browser inherits the user's unmodified `PATH`. The current draft strips `~/.local/bin` from the
  browser's own environment.
- `chromium` passes `--user-data-dir=$XDG_DATA_HOME/chromium/$PROFILE` and
  `--load-extension=` joined from every `extensions/*/` that contains a
  `manifest.json`. The broken profile-creation block is dropped, since
  Chromium creates the directory itself. While the old profile exists and
  the new one does not, the wrapper uses the old one and warns, so an early
  launch cannot create an empty profile that blocks the migration.

### systemd user units

`ungoogled-chromium.service` launches `%h/.local/bin/chromium`.
`firefox.service` keeps `/usr/bin/firefox`; the draft change pointing it at a
nonexistent `%h/.local/bin/firefox` is reverted. zsh-config (`BROWSER`,
`GH_BROWSER`, `ZVM_OPEN_URL_CMD`) only calls `firefox` by name, so it needs
no change.

### Migration: `run_before_` script

`home/.chezmoiscripts/run_before_migrate-chromium-profile` moves
`~/.local/share/chewy-ungoogled` to `~/.local/share/chromium/chewy-ungoogled`
if the old path exists, the new one does not, and Chromium is not running
(a `SingletonLock` naming a dead pid on this host is stale and ignored).
Otherwise it prints why it skipped and exits 0, so `chezmoi apply` continues.
It is `run_before_`, not `run_once_before_`, so a skipped move is retried on
the next apply; once the old path is gone it does nothing.
The leftover `~/.config/chromium` (from a launch that bypassed the wrapper)
stays untouched and is mentioned in the docs.

## Error handling

- A failed download, GitHub API error, or `crx-unpack` failure makes chezmoi
  abort before writing anything; no partial state. chezmoi caches the raw
  download, so after fixing (or a transient bad response) rerun with
  `--refresh-externals`.
- A Web Store extension that is delisted or goes MV2-only returns a non-CRX
  response, and `crx-unpack` rejects it with a message naming the problem.
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
   the temp tree, registers every listed extension, with Web Store entries
   under their store IDs.
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
