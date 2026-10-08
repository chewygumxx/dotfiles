---
ctime: 2026-10-08
mtime: 2026-10-08
spdx: GPL-3.0-only
title: Web Extensions
description: >-
  How chezmoi installs and updates Firefox add-ons and ungoogled-chromium
  extensions from one data list, and how to use it.
tags:
  - firefox
  - chromium
  - chezmoi
  - web-extensions
  - web-browser
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/docs/web-extensions.md
   -
   -->

# Web Extensions

One list in `home/.chezmoidata/web-extensions.toml` declares every browser
extension. `chezmoi apply` downloads each one, places it where the browser
picks it up, and refreshes it daily. All browser data lives under
`~/.local/share`, one tree per vendor.

Background: [design spec](specs/08-10-2026-web-extensions-design.md),
[implementation plan](plans/08-10-2026-web-extensions.md),
[verification report](notes/08-10-2026-web-extensions-verification.md),
[conversation notes](notes/08-10-2026-claude-conversation-web-extensions.md).

## Overview

```text
home/.chezmoidata/web-extensions.toml          one [[webExtensions]] per extension
  |
  +-> home/dot_local/share/private_mozilla/private_firefox/chewyfox/
  |     .chezmoiexternals/web-extensions.toml.tmpl
  |       type "file", AMO latest signed XPI
  |       -> ~/.local/share/mozilla/firefox/chewyfox/extensions/<id>.xpi
  |
  +-> home/dot_local/share/chromium/.chezmoiexternals/web-extensions.toml.tmpl
        type "archive", exact
          Web Store CRX | python3 -I crx-unpack   (key injected)
          GitHub release .crx | crx-unpack        (key injected)
          GitHub release zip                      (as is)
        chromium    -> ~/.local/share/chromium/extensions/mv3/<name>/
        chromiumMv2 -> ~/.local/share/chromium/extensions/mv2/<name>/

~/.local/bin/chromium (wrapper)
  exec chromium --user-data-dir=~/.local/share/chromium/chewy-ungoogled
                --load-extension=<one dir per name with a manifest.json,
                                  mv2 over mv3 unless CHROMIUM_MV2=0>
```

Resulting layout:

```text
~/.config/mozilla -> ../.local/share/mozilla      (Firefox XDG lookup)
~/.local/share/
  mozilla/firefox/
    profiles.ini, installs.ini                     (tracked)
    chewyfox/
      user.js, chrome/                             (tracked)
      extensions/<add-on-id>.xpi                   (externals)
  chromium/
    chewy-ungoogled/                               (profile, unmanaged)
    extensions/mv3/<name>/                         (externals, Manifest V3)
    extensions/mv2/<name>/                         (externals, Manifest V2)
```

Three extension directories, one per kind of build: Firefox's profile
`extensions/`, and Chromium's `mv3/` and `mv2/`. MV2 builds live apart so
they can be switched off in one place the day ungoogled-chromium stops
running them.

## Data file reference

```toml
[webBrowsers.chromium]
version = "153"  # Major version the Web Store serves builds for

[[webExtensions]]
name     = "proton-pass"
firefox  = "78272b6fa58f4a1abaac99321d503a20@proton.me"
chromium = "ghmbeldphafepmbegfdlkpapadhbakde"

[[webExtensions]]
name     = "imagus-reborn"
firefox  = "{7653b5cb-d76d-442f-a98f-f3c83a118cf4}"
chromium = { repo = "hababr/Imagus-Reborn", asset = "ImagusReborn_Chrome_*.zip" }

[[webExtensions]]
name        = "ublock-origin"
firefox     = "uBlock0@raymondhill.net"
chromium    = "ddkjiahejlhfcafbddmgiahcphecmpfh"  # uBlock Origin Lite
chromiumMv2 = { repo = "gorhill/uBlock", asset = "uBlock0_*.chromium.crx" }
```

| Key | Required | Meaning |
| --- | --- | --- |
| `name` | yes | Stable identifier. Also the Chromium extension directory name. |
| `firefox` | no | AMO add-on ID. Omit for Chromium-only extensions. |
| `chromium` | no | Manifest V3 build: a Chrome Web Store ID (string), or a table naming a GitHub release asset. Goes to `extensions/mv3/<name>`. |
| `chromiumMv2` | no | Manifest V2 build, same two forms. Goes to `extensions/mv2/<name>`. |

Omit both Chromium keys for Firefox-only add-ons, and `firefox` for
Chromium-only extensions.

The table form takes `repo` (`owner/name`), `asset` (a glob matched against
the latest release's asset names) and an optional `stripComponents` for zips
that wrap everything in one top-level directory. An asset ending in `.crx`
goes through `crx-unpack` like a Web Store CRX, so it keeps its signing
key's ID; a zip is used as is.

ungoogled-chromium 153 still runs Manifest V2, but upstream Chromium has
removed it. Give an extension `chromiumMv2` only for something MV3 can't do
(full uBlock Origin) or that has no MV3 build (TWP). When an entry has both,
the wrapper loads the MV2 build; once MV2 stops working, launch with
`CHROMIUM_MV2=0` (also `false`, `no` or `off`; set it in
`ungoogled-chromium.service` to make it stick) and every extension falls back
to its MV3 build. Then delete the `chromiumMv2` keys: `extensions/`, `mv2/`
and `mv3/` are exact, so the next `chezmoi apply` prunes the retired MV2
builds instead of leaving them to shadow MV3 again.

`webBrowsers.chromium.version` is sent to the Web Store as `prodversion`.
Bump it when ungoogled-chromium moves to a new major version, or the store
may stop serving builds that need newer APIs.

## Adding and removing an extension

**Firefox ID.** Install the add-on once by hand, then read its ID from
`about:support` (Add-ons section). Without installing it, the AMO API gives
the same value as `guid`:

```zsh
curl -s https://addons.mozilla.org/api/v5/addons/addon/<slug>/ | jq -r .guid
```

`<slug>` is the last part of the add-on's AMO URL.

**Chromium ID.** The 32 letters `a` to `p` at the end of the Chrome Web Store
URL, `chromewebstore.google.com/detail/<slug>/<id>`.

**Add.** Insert a `[[webExtensions]]` table, keeping the list sorted by
`name`, then:

```zsh
chezmoi diff        # shows the new target
chezmoi apply
```

Firefox enables the new add-on the next time it starts. Chromium loads it
the next time it is launched through the wrapper.

**Remove.** Delete the table (or just its `chromium` or `chromiumMv2` key).
On Chromium that is all: the extension directories are exact, so the next
`chezmoi apply` prunes the build and the wrapper stops loading it. On
Firefox, chezmoi stops managing the XPI but does not delete it, so also
uninstall the add-on from `about:addons` (Firefox deletes the XPI).

## Updating

Every external in the repo that refreshes reads its `refreshPeriod` from
`home/.chezmoidata/externals.toml` (`refreshPeriod = "24h"`), so a normal
`chezmoi apply` downloads a new copy at most once a day. The chezmoi config's
`gitHub.refreshPeriod` includes the same file, so GitHub "latest release"
lookups expire together with the downloads. After changing the value, run
`chezmoi init` once to regenerate the config. To update now:

```zsh
chezmoi apply --refresh-externals
```

Firefox replaces an add-on whose XPI changed on its next start. Chromium
reloads unpacked extensions on its next launch.

## Firefox details

Release builds of Firefox only sideload new add-ons from the **profile
scope**, `<profile>/extensions/<id>.xpi`. The user scope
(`~/.mozilla/extensions/...`) is ignored unless Firefox was built with
`MOZ_ALLOW_ADDON_SIDELOAD`, and no pref changes that.

`user.js` sets two prefs for this:

- `extensions.autoDisableScopes = 14` enables add-ons found in the profile
  scope. With the default (`15`) they install disabled and wait for a prompt.
- `extensions.update.autoUpdateDefault = false` makes chezmoi the only thing
  that updates add-ons. Otherwise Firefox rewrites the XPIs itself, `chezmoi
  diff` shows drift, and `chezmoi apply` can put an older cached copy back.
  The trade-off: this applies to every add-on, including ones not in the
  list. Firefox still checks for updates and lists them in `about:addons`,
  where they can be applied by hand.

Firefox tracks enabled or disabled state by add-on ID in the profile's
`extensions.json`, not in the XPI. An add-on you disable in `about:addons`
stays disabled when chezmoi replaces its file. The same goes for the
selected theme: both listed themes (Cyberpunk Lo-Fi and Cyberpunk Pixels,
Animated) are installed, and whichever one you picked stays active.

The two dictionaries are listed too. The `en-GB` language pack is not,
because AMO's "latest" build targets the next Firefox version; install the
`firefox-i18n-en-gb` package instead.

## Chromium details

**CRX conversion.** A Web Store CRX is a zip behind a signed header.
`crx-unpack` (`home/dot_local/bin/executable_crx-unpack`, Python standard
library only) reads it on stdin and writes a plain zip on stdout:

1. It finds the publisher key in the header. That is the key whose SHA-256
   prefix matches the header's `crx_id`.
2. It writes that key into `manifest.json` as base64 `key`.
3. It sets every entry to mode `0644` (directories `0755`) and marks it as
   made on Unix (`create_system = 3`). CRX entries can carry modes that make
   a directory unreadable, and zip readers ignore Unix modes on entries
   marked as MS-DOS, which is how uBlock Origin's CRX is built.
4. It drops `_metadata/`, the store's integrity data, which unpacked loads
   do not use.

Step 2 matters because an unpacked extension's ID is
`sha256(manifest key)`, or `sha256(directory path)` when there is no key.
With the key, every extension keeps its Web Store ID, so storage, settings
and flows that target the store ID (Proton Pass sign-in, for example) keep
working.

The externals template runs `crx-unpack` from the source directory through
`python3 -I`, so it works on the very first apply, before `~/.local/bin`
exists. It is also installed as `~/.local/bin/crx-unpack` for manual use:

```zsh
crx-unpack < extension.crx > extension.zip
```

GitHub zips have no key, so Imagus Reborn gets a path-derived ID. That ID
is stable as long as `~/.local/share/chromium/extensions/mv3/imagus-reborn`
does not move. GitHub `.crx` assets keep their publisher's ID: the MV2
uBlock Origin is `fkgkibajhfbepljeaefdnfnegdcjomkh` (gorhill's own signing
key, not the delisted Web Store ID), so its settings do not carry over from
uBlock Origin Lite.

**`exact`.** Each extension directory is `exact = true`, so files left over
from an older version are deleted on update.

**Wrapper.** `~/.local/bin/chromium` shadows the real binary. It finds the
next `chromium` on `PATH` whose resolved path is not the wrapper itself, so a
symlinked or trailing-slash spelling of `~/.local/bin` cannot make it exec
itself. `PATH` is left unchanged for the browser. It passes the ungoogled
flags, `--user-data-dir`, and one `--load-extension` with one directory per
extension name: the `mv2/` build when there is a usable one and
`CHROMIUM_MV2` is not `0`, `false`, `no` or `off`, otherwise the `mv3/`
build. A directory without a `manifest.json` is
skipped with a warning on stderr, and the browser still launches.
`ungoogled-chromium.service` starts the wrapper.

## First apply on this machine

1. Close Firefox and Chromium.
2. Regenerate the chezmoi config (it now reads `gitHub.refreshPeriod` from
   `externals.toml`), review, then apply:

   ```zsh
   chezmoi init
   chezmoi diff --exclude externals
   chezmoi apply
   ```

   The first apply downloads 53 extensions. The Firefox profile's
   `chrome`, `user.js`, `profiles.ini` and `installs.ini` stop being
   symlinks, and `~/.config/mozilla-firefox` is removed as a whole, stale
   `extensions.json` and emptied directories included, without a prompt.
   Their content is unchanged apart from the two new prefs.
3. `run_before_migrate-chromium-profile` moves
   `~/.local/share/chewy-ungoogled` to
   `~/.local/share/chromium/chewy-ungoogled`. If Chromium is still running,
   or both paths exist, it prints a warning, moves nothing, and lets the
   apply continue. It runs before every apply, so the move happens on the
   next run once the reason is gone. A stale `SingletonLock` left by a crash
   (this host, dead pid) does not block it.

   Until the move happens, the wrapper keeps launching the old profile and
   warns `Profile not migrated yet`, so Chromium never starts on an empty
   profile at the new path.
4. `~/.config/chromium` is left alone. It was created by a launch that
   bypassed the wrapper; delete it if nothing there is wanted.
5. `sudo pacman -S firefox-i18n-en-gb` for the British English language
   pack.

## Troubleshooting

**`crx-unpack: input is not a CRX (...)`.** The Web Store returned something
else, usually because the extension was delisted, is MV2-only, or needs a
newer `prodversion`. The apply aborts before writing anything. Check the
store page, then bump `webBrowsers.chromium.version` or remove the entry.
chezmoi caches the download before the filter runs, so a bad response keeps
failing every apply until the `refreshPeriod` runs out. After fixing the
cause, or when the failure was transient, rerun with
`chezmoi apply --refresh-externals`.

**GitHub API rate limit.** `gitHubLatestReleaseAssetURL` calls the GitHub
API when its cached answer is older than `gitHub.refreshPeriod` (24h).
Unauthenticated calls are limited to 60 an hour; export `GITHUB_TOKEN` (for
example `GITHUB_TOKEN=$(gh auth token) chezmoi apply`) to raise it.

**`web-extensions: <name>: no <repo> release asset matches <asset>`.** The
repo's latest release no longer ships an asset matching `asset`.
`gitHubLatestReleaseAssetURL` returns nothing in that case, and the Chromium
externals template stops with this message, so every `chezmoi apply` and
`chezmoi diff` aborts, not just Chromium. TWP is the likely case: its Chromium MV2 CRX is already named
`..._deprecated`. Fix the glob, or delete that `chromium` or `chromiumMv2`
key.

**`chromium: Skipping extension without manifest.json: ...`.** The zip wraps
its files in a top-level directory. Add `stripComponents = 1` to that
entry's `chromium` or `chromiumMv2` table. A broken `mv2/` build is skipped
and the `mv3/` build of the same name, if any, is loaded instead.

**`about:addons` lists updates.** Expected with `autoUpdateDefault = false`.
Run `chezmoi apply --refresh-externals`. Updating by hand is possible but
fights chezmoi: until the next refresh, `chezmoi apply` reports the XPI as
changed since it last wrote it, and overwriting (or `--force`) puts the
older cached copy back.

**`chezmoi: could not open a new TTY`.** `progress = true` in the chezmoi
config draws download progress on `/dev/tty`. Run from a terminal, or pass
`--no-tty`.

## Future: system policies

Once `root/` becomes a live source root, Firefox can move to
`/etc/firefox/policies/policies.json` with `ExtensionSettings`
(`installation_mode`, `install_url` per add-on ID). That brings native AMO
updates without the `autoUpdateDefault` trade-off, and `force_installed` can
lock add-ons. The same data file can render it, since policies are keyed by
the same IDs. Chromium's equivalent (`ExtensionInstallForcelist`) needs a
self-hosted update manifest on ungoogled builds, so unpacked extensions stay
the better fit there.

<!-- vim:set expandtab shiftwidth=2 filetype=markdown: -->
