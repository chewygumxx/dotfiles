---
ctime: 2026-10-08
mtime: 2026-10-08
spdx: GPL-3.0-only
title: "Report: Web Extensions Verification"
description: >-
  Evidence for the web extensions design: the constraints tested before
  implementation and the checks run against the finished branch.
tags:
  - firefox
  - chromium
  - chezmoi
  - web-extensions
  - report
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/docs/notes/08-10-2026-web-extensions-verification.md
   -
   -->

# Report: Web Extensions Verification

All checks ran on 2026-10-08 on `chewytop` (Arch Linux): Firefox 157.0.1,
ungoogled-chromium 153.0.8010.52, chezmoi 2.73.0, Python 3.14.7, zsh 5.9.2.
Every `chezmoi apply` used a temp `--destination`, `--cache` and
`--persistent-state`; the real home was only read (`chezmoi diff`).

See [the design spec](../specs/08-10-2026-web-extensions-design.md) and
[the user guide](../web-extensions.md).

## Constraints tested before implementation

These shaped the [design spec](../specs/08-10-2026-web-extensions-design.md)
and were tested with throwaway prototypes. The end-to-end checks below
confirm each one against the committed code.

| Constraint | Method | Observed |
| --- | --- | --- |
| Firefox only sideloads from the profile scope | Read `XPIProvider.sys.mjs` / `AddonSettings.sys.mjs` in the 157 omni.ja | `SCOPES_SIDELOAD = SCOPE_PROFILE` unless `MOZ_ALLOW_ADDON_SIDELOAD`; release builds do not set it |
| Profile sideload needs `autoDisableScopes = 14` | Headless Firefox on a temp profile with one XPI in `extensions/`, pref `15` vs `14` | `15`: installed, disabled. `14`: active, `signedState` 2 |
| AMO serves latest XPI by ID | `curl -sIL` on the latest URL for all 40 installed profile add-ons | 38 resolve to a signed XPI. `newtab@mozilla.org` is built in; the `en-GB` langpack's latest targets Firefox 158 |
| ungoogled-chromium 153 honours `--load-extension` | Headless launch with one unpacked MV3 extension | Registered, service worker running |
| Web Store CRX downloadable without a browser | `curl -L` on the `clients2.google.com` endpoint, `prodversion=153` | CRX3 files (`Cr24`, version 3) |
| Unpacked ID needs `key` | Inspected manifests; loaded with and without `key` | Without `key` the ID is the path hash. Proton Pass, SingleFile, HeadingsMap, Auto Tab Discard ship no `key` |
| CRX header carries the publisher key | Prototype converter injecting the header key | Claude, Proton Pass and SingleFile loaded under their store IDs |
| CRX entry modes are unusable | First chezmoi archive + filter run | `permission denied` on `_metadata/verified_contents.json`; fixed by normalising modes and dropping `_metadata/` |

## Checks against the branch

### `crx-unpack`

```zsh
python3 -I home/dot_local/bin/executable_crx-unpack < pass.crx > pass.zip && echo ok
unzip -p pass.zip manifest.json | jq -r .key | base64 -d | sha256sum | cut -c1-32 | tr 0-9a-f a-p
unzip -l pass.zip | grep -c _metadata
printf '<html>gone</html>' | python3 -I home/dot_local/bin/executable_crx-unpack; echo "exit $?"
```

```text
ok
ghmbeldphafepmbegfdlkpapadhbakde
0
crx-unpack: input is not a CRX (17 bytes, starts b'<html>gone</html')
exit 1
```

The derived ID is Proton Pass's Web Store ID. An HTML error page is
rejected with exit 1, which aborts `chezmoi apply`.

### Templates and managed targets

```zsh
chezmoi execute-template < home/dot_local/share/chromium/.chezmoiexternals/web-extensions.toml.tmpl | grep -c '^\['
chezmoi execute-template < home/dot_local/share/private_mozilla/private_firefox/chewyfox/.chezmoiexternals/web-extensions.toml.tmpl | grep -c '^\['
chezmoi managed --include externals | grep -cE 'chromium/extensions/[^/]+$|chewyfox/extensions/[^/]+\.xpi$'
```

```text
17
38
55
```

Before this branch, every chezmoi command failed on the draft template with
`function "repoSlug" not defined`.

### Firefox layout migration

The current layout was applied from `main` into a temp destination, then the
branch was applied over it.

| Check | Observed |
| --- | --- |
| Symlinks under `.local/share/mozilla` before | 4 (`profiles.ini`, `installs.ini`, `chewyfox/chrome`, `chewyfox/user.js`) |
| Symlinks after | 0 |
| `.config/mozilla-firefox` after | removed (`No such file or directory`) |
| XPIs in `chewyfox/extensions/` | 38 |
| `chrome/userChrome.css` vs `main` | identical apart from the header path |

### Firefox loads every add-on

Headless Firefox on a copy of the applied profile, then `extensions.json`
grouped by type for `location == "app-profile"`:

| Type | Installed | Active | `signedState` 2 |
| --- | --- | --- | --- |
| extension | 30 | 30 | 30 |
| dictionary | 2 | 2 | 0 (not recorded for dictionaries) |
| theme | 6 | 0 | 6 |

All 38 are installed. The themes are inactive because Firefox allows one
active theme and the fresh profile keeps the default; the live profile keeps
its current selection (`{7c9b0deb-...}`, Cyberpunk Lo-Fi).

**Disabled state survives a file replacement.** Sidebery was marked
`userDisabled` in `extensions.json`, its XPI deleted and rewritten with a new
mtime (as chezmoi does), and Firefox restarted:
`userDisabled=true active=false location=app-profile`.

**AMO ID lookup.**
`curl -s https://addons.mozilla.org/api/v5/addons/addon/sidebery/ | jq -r .guid`
printed `{3c078156-979c-498b-8990-85f7987dd929}`, matching the data file.

### Chromium wrapper

A fake `chromium` that prints its arguments, the wrapper copied into
`$t/link`, and `$t/link-alias -> $t/link` placed first on `PATH` with a
trailing slash. `ZDOTDIR` pointed at an empty directory, because the user's
zsh env prepends `~/.local/bin` to `PATH` for every zsh script.

| Case | Draft | Rewrite |
| --- | --- | --- |
| `PATH` alias of the wrapper's own dir | execs itself until `timeout` (124) | skips itself, runs the fake binary |
| `--user-data-dir` | `$t/data/chewy-ungoogled` | `$t/data/chromium/chewy-ungoogled` |
| `--load-extension` | absent | `$t/data/chromium/extensions/good` |
| Extension dir without `manifest.json` | not handled | `chromium: Skipping extension without manifest.json: .../bad`, still launches |
| User arguments | | `--x` passed last |
| No real binary on `PATH` | | `chromium: Shadowed command not found: chromium`, exit 127 |

### Chromium profile migration

| Case | Observed |
| --- | --- |
| Old dir only | `[NOTICE] Moved ...`, exit 0, `Default/Prefs` at the new path |
| Old dir with `SingletonLock` symlink | `[WARN] Chromium is using ...`, exit 0, nothing moved |
| Both dirs present | `[WARN] Both ... exist, leaving both untouched`, exit 0 |
| Neither | silent, exit 0 |
| `CHEZMOI_DEST_DIR` in scripts | a `run_` script in a temp source wrote `dest=<the --destination path>` |

### Chromium loads every extension under the right ID

The branch was applied to a temp destination (17 extension directories, each
with a `manifest.json`), the migration script moved a seeded old profile, and
the applied wrapper launched `chromium --headless=new` with `XDG_DATA_HOME` in
the temp tree and `PATH=/usr/bin:/bin`.

| Check | Observed |
| --- | --- |
| `extensions.settings` entries with `location` 8 (command line) | 17 |
| Extension service workers on the DevTools target list | 17 |
| Web Store IDs from the data file missing from either list | none (16 of 16 present) |
| Extra ID | `ikjiffgnbibipaoalpdjgckfjaojdipm`, Imagus Reborn: `sha256` of its directory path, as expected for a GitHub zip without `key` |

The browser log contained 14 `Failed to create API on Chrome object`
renderer messages and GPU/WebGL fallback messages, which are headless
noise; none named an extension or manifest error.

### Correction: Manifest V2 still runs

The spec originally said Chromium 153 rejects MV2. That was inferred from
upstream's removal and from release asset names, not tested. Testing it:

```zsh
gh release download -R darkreader/darkreader -p darkreader-chrome.zip   # manifest_version 2
chromium --headless=new --user-data-dir=$t/prof --load-extension=$t/dr --remote-debugging-port=9336 about:blank
curl -s localhost:9336/json/list | jq -r '.[] | "\(.type) \(.url)"'
```

```text
background_page chrome-extension://bledjebonkpioiioogiofdholgojjdcd/background/index.html
```

ungoogled-chromium 153 runs the MV2 build. The design keeps MV3 Web Store
builds anyway, since MV2 support can disappear in any later release; the
spec and guide now say so.

### systemd units and Termux

`systemd-analyze --user verify` on `firefox.service` (back to
`/usr/bin/firefox`) and `ungoogled-chromium.service` reported nothing about
either unit. `home/.chezmoiignore` rendered with
`--destination /data/data/com.termux/files/home` contains all six browser
entries.

### `chezmoi diff` against the real home

`chezmoi diff --exclude externals` (read-only) lists:

- New: `.local/bin/crx-unpack`, `.config/systemd/user/ungoogled-chromium.service`,
  `.chezmoiscripts/migrate-chromium-profile`.
- Changed: `.local/bin/chromium` (rewrite).
- Symlink to real file: `.local/share/mozilla/firefox/{profiles.ini,
  installs.ini}`, `chewyfox/user.js`, `chewyfox/chrome/` and its three CSS
  files.
- Deleted: `.config/mozilla-firefox`.
- Unrelated and pre-existing: `.chezmoiscripts/wezterm-terminfo` (a
  `run_onchange_` script) and the two Claude `settings.json` files.

The live files behind the Firefox symlinks match the branch's copies except
for header lines and the two new prefs, and `~/.config/mozilla-firefox` holds
nothing else besides the stale `extensions.json`. The real apply loses no
data.

## Not verified here

- The real `chezmoi apply`, left to the user with both browsers closed.
- Proton Pass sign-in through its `externally_connectable` flow in a real
  session; only its ID was checked.

<!-- vim:set expandtab shiftwidth=2 filetype=markdown: -->
