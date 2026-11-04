---
name: web-browsers
description: >-
  Map of how this repo installs and configures Firefox and ungoogled-chromium:
  every browser source file, the target it produces and why it exists, the
  extension pipeline, per-host gating and the traps. Use before touching
  anything under home/dot_local/share/private_mozilla or
  home/dot_local/share/chromium, the web-extensions data file, the chromium
  wrapper, crx-unpack, the browser systemd units, or when asked how a browser
  setting, add-on or extension gets onto the machine.
ctime: 2026-11-04
mtime: 2026-11-04
spdx: GPL-3.0-only
tags:
  - claude
  - skill
  - chezmoi
  - firefox
  - chromium
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/.agents/skills/web-browsers/SKILL.md
   -
   -->

# Web browsers

This repo installs no browser binaries; they come from system packages
(`firefox` and `firefox-i18n-en-gb` from pacman, `ungoogled-chromium-bin`
from the AUR on this host). What it manages is
each browser's profile settings, extensions, launcher and desktop
integration. The authoritative user guide for the extension pipeline is
`docs/note/2026-10-08_web-extensions.md` (design, plan and verification
reports are linked from it). Read it before changing extension behaviour.
This skill is the file map around it.

## Architecture

```text
home/.chezmoidata/web-extensions.toml    one [[webExtensions]] per extension
home/.chezmoidata/externals.toml         shared refreshPeriod (24h)
  |
  +-> Firefox externals template  -> ~/.local/share/mozilla/firefox/chewyfox/extensions/<id>.xpi
  |                                   (AMO latest signed XPI, type "file")
  |
  +-> Chromium externals template -> ~/.local/share/chromium/extensions/{mv3,mv2}/<name>/
                                      (type "archive", exact; CRX piped through crx-unpack)

Firefox:  /usr/bin/firefox finds ~/.config/mozilla -> ~/.local/share/mozilla,
          profiles.ini/installs.ini pin profile "chewyfox",
          user.js + chrome/*.css configure it, extensions/ sideloads the XPIs.

Chromium: ~/.local/bin/chromium (wrapper) shadows the real binary and execs it with
          the ungoogled flags, --user-data-dir=~/.local/share/chromium/chewy-ungoogled
          and --load-extension=<one dir per name, mv2 over mv3 unless CHROMIUM_MV2=0>.
```

The two browsers are configured in opposite ways. Firefox is configured
through files in its profile. Chromium's profile is left entirely unmanaged,
and all of its configuration is command-line flags in the wrapper.

## Firefox files

Source root: `home/dot_local/share/private_mozilla/private_firefox/`, which
becomes `~/.local/share/mozilla/firefox/` (mode 0700 through `private_`).

| Source (relative to that root) | Purpose |
| --- | --- |
| `profiles.ini` | Firefox's profile registry: one profile, `chewyfox`, relative path, default, selector hidden. |
| `installs.ini` | Binds the install hash `4F96D1932A9F858E` (`/usr/lib/firefox`) to `chewyfox` with `Locked=1`, so Firefox never creates a fresh default profile. |
| `.gitattributes` | `-sync-header-metadata` on both `.ini` files: Firefox rewrites them, so they must stay headerless. Never add a header to them. |
| `.chezmoiignore` | Ignores Firefox-written state under the root (`Crash Reports/`, `Pending Pings/`, `Profile Groups/`, `firefox-mpris/`). |
| `chewyfox/.chezmoiignore` | Allowlist: `*` ignored except `chrome/`, `extensions/` and `user.js`. Everything else in the profile is Firefox's own state. |
| `chewyfox/user.js` | Prefs applied on every start. Load-bearing ones: `toolkit.legacyUserProfileCustomizations.stylesheets` (enables `chrome/`), `extensions.autoDisableScopes = 14` (enables sideloaded XPIs), `extensions.update.autoUpdateDefault = false` (chezmoi owns updates), `browser.download.dir = ~/net/firefox`. The "Miscellaneous" block is mostly onboarding and telemetry counters captured from `prefs.js`. |
| `chewyfox/chrome/userChrome.css` | Browser UI: accent colour, hides the native tab bar (tabs live in Sidebery), sidebar header, radii, context menu pruning, URL bar and toolbar. A new stylesheet split out of it needs an `@import` at the top of this file. |
| `chewyfox/chrome/userContent.css` | Dark palette for `about:*` pages through `@-moz-document`. |
| `chewyfox/.chezmoiexternals/web-extensions.toml.tmpl` | One `type = "file"` external per entry with a `firefox` key, downloading `addons.mozilla.org/firefox/downloads/latest/<id>/latest.xpi` to `extensions/<id>.xpi`. Skipped on Termux. |

Elsewhere:

| Source | Purpose |
| --- | --- |
| `home/dot_config/symlink_mozilla` | `~/.config/mozilla -> ../.local/share/mozilla`, the XDG path Firefox looks up, so the data tree is the only real copy. |
| `home/.chezmoiremove` | Removes the retired `~/.config/mozilla-firefox` tree and the deployed `chrome/context_menu.css` (its rules were inlined in `userChrome.css`). |
| `home/dot_cache/.chezmoiignore` | Keeps `~/.cache/mozilla` unmanaged. |
| `home/dot_config/systemd/user/firefox.service` | `ExecStart=/usr/bin/firefox`; Hyprland autostart runs `systemctl --user start firefox` (`home/dot_config/hypr/chewy.lua`). |
| `home/net/firefox/` | The download directory. Contents ignored; on `chewytop` only, `ext-sidebery/` and `ext-imagus-mod/` are created as empty dirs. |

## Chromium files

| Source | Purpose |
| --- | --- |
| `home/dot_local/share/chromium/.chezmoiexternals/web-extensions.toml.tmpl` | For `chromium` (to `mv3/`) and `chromiumMv2` (to `mv2/`): a Web Store ID becomes a `clients2.google.com` CRX download with `prodversion` from `webBrowsers.chromium.version`; a `{ repo, asset }` table becomes `gitHubLatestReleaseAssetURL` (fails the whole render if no asset matches). `.crx` sources go through `python3 -I <source>/dot_local/bin/executable_crx-unpack`, so it works before `~/.local/bin` exists. Every target is `exact`. Skipped on Termux. |
| `home/dot_local/share/chromium/exact_extensions/exact_mv{2,3}/.keep` | Make `extensions/`, `mv2/` and `mv3/` exact directories, so removed or retired builds are pruned on apply. `.keep` is not deployed. |
| `home/dot_local/bin/executable_chromium` | Zsh wrapper, `~/.local/bin/chromium`. Resolves the next `chromium` on `PATH` that is not itself, sets the ungoogled flags (dark mode, blank NTP, no tab close buttons, keep history, etc.) and `--user-data-dir`, falls back to the legacy profile path until migrated, and builds `--load-extension` (skips dirs without `manifest.json`). Browser behaviour changes go in its `flags` array. |
| `home/dot_local/bin/executable_crx-unpack` | Python (stdlib only) CRX3-to-zip filter: injects the publisher key into `manifest.json` as `key` so the unpacked extension keeps its store ID, normalises entry modes, drops `_metadata/`. |
| `home/.chezmoiscripts/run_before_migrate-chromium-profile` | Moves `~/.local/share/chewy-ungoogled` to `~/.local/share/chromium/chewy-ungoogled`; no-op once done, defers while Chromium holds a live `SingletonLock`. |
| `home/dot_config/systemd/user/ungoogled-chromium.service` | `ExecStart=%h/.local/bin/chromium`. Put `Environment=CHROMIUM_MV2=0` here to retire MV2 builds. |
| `home/dot_config/chromium/.chezmoiignore` | `**`: `~/.config/chromium` is the default profile path, created only by launches that bypass the wrapper; never managed. |

## Shared and integration files

| Source | Purpose |
| --- | --- |
| `home/.chezmoidata/web-extensions.toml` | The one extension list (`name`, `firefox`, `chromium`, `chromiumMv2`), sorted by `name`, plus `webBrowsers.chromium.version`. Key reference is in the user guide. |
| `home/.chezmoidata/externals.toml` | `externals.refreshPeriod`, also read by `gitHub.refreshPeriod` in `home/.chezmoi.toml.tmpl`. Never hardcode a period. |
| `home/dot_config/environment.d/base.conf` | `BROWSER=firefox`. |
| `home/dot_config/mimeapps.list` | Firefox is the default for web and PDF types; Chromium is registered as an alternative. |
| `home/dot_config/hypr/window_workspace_rules.lua` | Rules for the Firefox main window, Library and extension popups. |
| `home/dot_config/gh/config.yml`, `waybar/config.jsonc`, `yazi/keymap.toml` (`gd` to `~/net/firefox`), `fd/ignore` (profile storage) | Minor Firefox references. |

## Host gating

- **Termux**: both externals templates render nothing; `home/.chezmoiignore`
  ignores the migration script, the Chromium unit, both `~/.local/bin`
  scripts, `.local/share/chromium/` and `.local/share/mozilla/`
  (`systemd/` is ignored there wholesale by `home/dot_config/.chezmoiignore`).
- **No browser installed**: `home/dot_config/.chezmoiignore` drops
  `~/.config/mozilla` without `firefox` on `PATH`, and `~/.config/chromium`
  without `chromium`. The data trees are not gated this way.
- **chewytop**: only `home/net/firefox/ext-*` differ.

## Traps

- Never `chezmoi apply` browser targets against the real home to test. Use
  the `chezmoi-sandbox` skill; a full render downloads every extension, so
  scope it to a target where possible.
- Firefox only sideloads from the profile scope, and does not delete an XPI
  that chezmoi stops managing: removing an add-on also needs an uninstall in
  `about:addons`. Chromium removals are pruned by the exact dirs.
- Add-on enabled state and the selected theme live in Firefox's
  `extensions.json`, not the XPI, and stay unmanaged.
- Don't track more of the Firefox profile: the allowlist in
  `chewyfox/.chezmoiignore` would hide it anyway. Add a `!path` line there
  together with the file.
- `user.js` wins over `about:config` on every restart; a pref changed in the
  UI reverts unless it is also changed here.
- An external download failing aborts the whole `chezmoi apply`/`diff`, not
  just the browser. Troubleshooting is in the user guide.
- `webBrowsers.chromium.version` must track the installed major version
  (`pacman -Q ungoogled-chromium-bin`), or the Web Store may stop serving
  builds that need newer APIs.
- Deleting a tracked profile file leaves the deployed copy behind; add its
  target path to `home/.chezmoiremove` in the same commit.
- Commit scopes are `firefox` and `chromium` (`firefox/chromium` for both).
