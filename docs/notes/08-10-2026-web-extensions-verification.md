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
| Stale lock: this host, dead pid | `[NOTICE] Ignoring stale lock ...`, moved |
| Live lock: this host, live pid | skipped, nothing moved |
| Lock from another host | skipped, nothing moved |
| Wrapper, old profile only | `Profile not migrated yet, ...`, `--user-data-dir` is the old path |
| Wrapper, both profiles | new path, no warning |
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

## Revisions: MV2 directory, themes, refresh period

Checks for the [spec's Revisions](../specs/08-10-2026-web-extensions-design.md#revisions).

### Template and wrapper

| Check | Observed |
| --- | --- |
| Real data renders `extensions/mv3/<name>` entries | 17, none left at the flat `extensions/<name>` |
| Real data renders `extensions/mv2/<name>` entries | `twp-translate-web-pages`, `ublock-origin` |
| Synthetic `chromiumMv2` with a `.crx` asset | `format = "zip"` and the `crx-unpack` filter |
| Synthetic `chromiumMv2` with a `.zip` asset | GitHub URL, no filter |
| Wrapper with `mv3/{a,b}`, `mv2/{b,c}` | `--load-extension=.../mv3/a,.../mv2/b,.../mv2/c` |
| Same with `CHROMIUM_MV2=0` | `--load-extension=.../mv3/a,.../mv3/b` |

### `crx-unpack` and MS-DOS zip entries

The first temp apply with uBlock Origin's GitHub CRX failed:
`lstat .../mv2/ublock-origin/_locales/ar: permission denied`. Its entries
have `create_system = 0` (MS-DOS), and zip readers, Go's included, only take
the Unix mode from `external_attr` when `create_system` is 3, so directories
came out without the execute bit. Before the fix all 781 converted entries
were non-Unix; after setting `create_system = 3`, none were, and the
crx-unpack checks above still passed.

### Chromium runs the MV2 builds

Temp apply of `.local/share/chromium` and the wrapper, then headless
`chromium` through the wrapper:

| Check | Observed |
| --- | --- |
| `manifest_version` and derived ID | TWP: 2, `bolggfoncklhniejomgplkjcllmnonbh`. uBlock Origin: 2, `fkgkibajhfbepljeaefdnfnegdcjomkh` |
| Extensions registered (`location` 8) | 18 (17 mv3, minus uBlock Origin Lite, plus 2 mv2) |
| Running targets | 18 unique; Claude has both a service worker and a page |
| TWP and uBlock Origin | `background_page` running for each |
| uBlock Origin Lite `ddkjiahejlhfcafbddmgiahcphecmpfh` | not loaded, overridden by the MV2 build |

### Themes

The data keeps `theme-cyberpunk-lo-fi` and `theme-cyberpunk-pixels-animated`;
the Firefox externals template now renders 34 entries (was 38), and
`chezmoi managed --include externals` lists 53 extension targets (34
Firefox, 17 mv3, 2 mv2).

### Shared refresh period

| Check | Observed |
| --- | --- |
| `refreshPeriod = "168h"` left under `home/` | none |
| Every templated external that sets `refreshPeriod` | renders `"24h"` |
| Plain `.toml` externals setting `refreshPeriod` | none (`zsh-config`, `nvim-config` became `.tmpl`) |
| `chezmoi execute-template --init < home/.chezmoi.toml.tmpl`, `[gitHub]` | `refreshPeriod = "24h"` |
| `.chezmoidata` visible to the config template | no (`map has no entry for key`); `include ... \| fromToml` works |

### `~/.config/mozilla-firefox` removal

A temp destination holding `.config/mozilla-firefox/chewyfox/extensions.json`
(a copy of the live stale file) and an otherwise empty tree: one
`chezmoi apply` of that target, without `--force` and with no TTY, left
nothing under `.config`. The stale file and its directories go with the
`.chezmoiremove` entry, without a prompt.

## Not verified here

- The real `chezmoi apply`, left to the user with both browsers closed.
- Proton Pass sign-in through its `externally_connectable` flow in a real
  session; only its ID was checked.

<!-- vim:set expandtab shiftwidth=2 filetype=markdown: -->
