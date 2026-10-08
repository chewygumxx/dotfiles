---
ctime: 2026-10-08
mtime: 2026-10-08
spdx: GPL-3.0-only
title: "Conversation with Claude: Chezmoi Managed Web Extensions"
description: >-
  Conversation with Claude regarding the declarative installation of
  extensions for firefox and chromium based web browsers via chezmoi.
tags:
  - firefox
  - chromium
  - chezmoi
  - dotfiles
  - config
  - web-extensions
  - web-browser
  - claude
  - llm
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/docs/notes/08-10-2026-claude-conversation-web-extensions.md
   -
   -->

# Conversation with Claude: Chezmoi Managed Web Extensions

## chewygumxx Prompt 1

I've installed `ungoogled-chromium` as contingency for websites not functioning
properly on firefox. Is it possible for extensions and other settings to be
managed be chezmoi? Could I simply update extensions by keeping a
`.chezmiexternals` subdirectory within the source path of the
`--user-data-dir=$dir` extensions subdirectory?

---

## Claude Response 1

### Short answer

Partly. chezmoi can manage Chromium settings and a reproducible set of
extensions, but not by pointing `.chezmoiexternal` at the profile's
`Extensions` directory. A small variation of your idea does work.

### Why the profile `Extensions` directory is the wrong target

- **Registration:** Chromium only loads an extension that is registered in the
  profile's `Preferences` and `Secure Preferences`. Dropping files into
  `<user-data-dir>/Default/Extensions/<id>/<version>_0/` does nothing by itself.
- **Integrity:** `Secure Preferences` is HMAC protected, so hand-editing it to
  register an extension gets reverted or flagged.
- **Volatile state:** Chromium rewrites that directory and those files at
  runtime, so chezmoi would show permanent drift.
- **Format:** A `.crx` is a zip with a header prepended, so chezmoi's `archive`
  type is not a clean fit.

Two spelling notes: the file is `.chezmoiexternal.$FORMAT` (or a
`.chezmoiexternals/` directory of such files), and the chezmoi docs say entry
paths are relative to the target directory of the source directory that
contains the file. So your instinct about placing it inside the matching source
subdirectory is correct.

### A workable variant: unpacked extensions with `--load-extension`

Keep extensions in a directory outside the profile's `Default/` folder, fetch
them with chezmoi externals, and tell Chromium to load them at launch.

#### External definition

Source path `dot_local/share/chromium-extensions/.chezmoiexternal.toml`, which
targets `~/.local/share/chromium-extensions/`:

```toml
[ublock-origin-lite]
    type = "archive"
    url = {{ gitHubLatestReleaseAssetURL "uBlockOrigin/uBOL-home" "uBOLite_*.chromium.zip" | quote }}
    refreshPeriod = "168h"
    # stripComponents = 1  # uncomment if the zip nests everything in one folder
```

Check the real asset name and archive layout before relying on this, since I am
pattern-matching from memory. For extensions that ship a buildable git tree
rather than a zip, `type = "git-repo"` also works.

Update with:

```sh
chezmoi apply --refresh-externals
```

Do not mark the directory `exact`. Unmanaged files inside it are then left alone.

#### Launch wrapper

Source path `dot_local/bin/executable_chromium-ug`:

```bash
#!/usr/bin/env bash
data="${XDG_DATA_HOME:-$HOME/.local/share}"
exts="$(printf '%s,' "$data/chromium-extensions"/*/)"

exec ungoogled-chromium \
    --user-data-dir="$data/chromium-profile" \
    --load-extension="${exts%,}" \
    "$@"
```

The binary name varies by package (`chromium`, `ungoogled-chromium`, or a
Flatpak wrapper). Point your `.desktop` entry at this script so every launch
path gets the same flags.

#### Caveats

- Unpacked extensions get no automatic updates. `--refresh-externals` is your
  update mechanism.
- Upstream Chromium has removed Manifest V2 support, so MV2-only extensions may
  not load. Verify against your installed version.
- `--load-extension` was removed from branded Chrome builds, but Chromium
  builds have kept it. Confirm it still works on your build.

### Managing settings

#### Policies (the right layer for most settings)

The widely accepted convention is the **Chromium/Chrome Enterprise policy**
mechanism: JSON files in a managed policy directory, documented in the Chrome
Enterprise policy list. On Linux Chromium builds that is
`/etc/chromium/policies/managed/*.json`. Policies apply regardless of
`--user-data-dir`, and you can verify them at `chrome://policy`.

Because that path is outside `$HOME`, store the JSON in the source tree, ignore
it for normal deployment, and install it with a script.

`etc/chromium-policy.json` in the source root (add `etc/` to `.chezmoiignore`):

```json
{
  "HomepageLocation": "about:blank",
  "PasswordManagerEnabled": false,
  "DnsOverHttpsMode": "automatic"
}
```

`run_onchange_after_chromium-policy.sh.tmpl`:

```bash
#!/usr/bin/env bash
# policy hash: {{ include "etc/chromium-policy.json" | sha256sum }}
set -euo pipefail
sudo install -Dm644 {{ joinPath .chezmoi.sourceDir "etc/chromium-policy.json" | quote }} \
    /etc/chromium/policies/managed/10-personal.json
```

The hash comment makes chezmoi rerun the script only when the policy changes.

#### Flags

Anything that is not a policy goes in the wrapper script above. Some distro
packages also read `~/.config/chromium-flags.conf`, but that varies by package,
so the wrapper is more portable.

#### Profile `Preferences`

I would not track `Default/Preferences` or `Secure Preferences` as files. If
you need a specific key that has no policy, a `modify_` script using `jq`
against the closed browser's `Preferences` is possible, but Chromium may
overwrite it later.

### Alternatives if the above feels like too much machinery

1. **Policy force-install:** Use `ExtensionInstallForcelist` in the managed
   policy file. This gives Chromium-native installs and updates, but it needs a
   reachable update URL, and ungoogled-chromium's removal of Web Store access
   makes this unreliable unless you self-host an update manifest.
2. **Manual installs plus `chromium-web-store`:** Install extensions through
   the UI, treat the profile as unmanaged state, and let chezmoi manage only
   the wrapper script and policy file. This is the least fragile option.
3. **Pinned lockfile:** Keep a small TOML or JSON list of extension names and
   versions in chezmoi, and use a `run_onchange_` script to fetch and unpack
   them. This is the same outcome as externals with more control, but more code
   to maintain.

For a contingency browser, I would start with option 2 plus the policy file,
and only add the externals approach if you want fully reproducible extensions.

---

## chewygumxx Prompt 2

Can the same be done for firefox extensions?

---

## Claude Prompt 2

### Short answer

Yes, and it is simpler than Chromium. Firefox has a first-class policy
mechanism that installs extensions natively and keeps them updated, so you do
not need chezmoi externals for the extensions themselves. chezmoi's job becomes
shipping the policy file, a `user.js`, and any `userChrome.css`.

### Why the profile extensions directory is still the wrong target

- **Registration:** Firefox tracks installed add-ons in profile state files
  (`extensions.json`, `addonStartup.json.lz4`). Dropping an XPI into
  `<profile>/extensions/` is not a reliable install path, and Firefox has
  narrowed sideloading over the years.
- **Signing:** Release and ESR Firefox reject unsigned extensions. Developer
  Edition and Nightly can relax this with `xpinstall.signatures.required`, but
  that is not what you are running.
- **Volatility:** Those state files are rewritten constantly, so chezmoi would
  show permanent drift.
- **No `--load-extension` equivalent:** Firefox's closest feature is a
  temporary add-on (`about:debugging` or `web-ext run`), which does not persist
  across restarts. The wrapper-script trick from the Chromium answer has no
  Firefox counterpart.

### Policy-based installs (the right layer)

The convention here is Mozilla's enterprise policy engine, documented in the
`mozilla/policy-templates` repository. The relevant policy is
`ExtensionSettings`, keyed by extension ID.

`etc/firefox-policies.json` in your source root (add `etc/` to
`.chezmoiignore`):

```json
{
  "policies": {
    "ExtensionSettings": {
      "uBlock0@raymondhill.net": {
        "installation_mode": "normal_installed",
        "install_url": "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
      },
      "{446900e4-71c2-419f-a6a7-df9c091e268b}": {
        "installation_mode": "normal_installed",
        "install_url": "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi"
      }
    }
  }
}
```

Find IDs in `about:support` under Extensions. The slug in the URL is the AMO
page slug.

#### Installation modes

- **`normal_installed`:** installs the extension, and the user can still
  disable it.
- **`force_installed`:** installs it and locks it against disabling or removal.
- **`allowed` and `blocked`:** gate what users may install. A `"*"` entry with
  `blocked` gives you an allowlist.

Because the install URL points at AMO, Firefox's normal add-on update mechanism
handles updates. That makes this strictly better than the Chromium situation,
where force-install from the Web Store is awkward on ungoogled builds.

#### Deploying the file

The policy location is outside `$HOME`, so use a script as before. Mozilla
builds on Linux read `/etc/firefox/policies/policies.json`, while some distro
packages use `/usr/lib/firefox/distribution/` instead, and Flatpak and Snap
differ again.

`run_onchange_after_firefox-policy.sh.tmpl`:

```bash
#!/usr/bin/env bash
# policy hash: {{ include "etc/firefox-policies.json" | sha256sum }}
set -euo pipefail
sudo install -Dm644 {{ joinPath .chezmoi.sourceDir "etc/firefox-policies.json" | quote }} \
    /etc/firefox/policies/policies.json
```

Verify at `about:policies`, which has Active and Errors tabs.

### Where chezmoi externals still fit

Only for a pinned or offline copy. Fetch a signed XPI with an external of `type
= "file"`, then point `install_url` at a `file:///home/<user>/...` path
(templated with `{{ .chezmoi.homeDir }}` if you render the policy file). You
lose the AMO `latest` convenience and take on manual refreshes with `chezmoi
apply --refresh-externals`, so I would only do this if you want exact version
pinning.

### Settings

#### `user.js` in a pinned profile

Firefox applies `user.js` over `prefs.js` on every startup, which makes it the
safe thing to track. Never track `prefs.js` itself.

The profile directory has a random-prefix name by default, which is awkward for
chezmoi. Create one at a fixed path:

```sh
firefox -CreateProfile "main $HOME/.local/share/firefox/main"
```

Then manage `user.js` and `chrome/userChrome.css` inside it, without `exact` on
the directory. Recent Firefox releases also gained XDG Base Directory support
on Linux (I believe 147 onward, so verify on your version), which may let you
use `~/.config/mozilla/firefox/` natively.

#### Extension settings

Extension options live in per-profile storage under a random UUID, so they are
not worth tracking as files. Extensions that implement `storage.managed` can
instead be configured through the policy file's `3rdparty` section. uBlock
Origin is one such extension, and its deployment docs list the accepted keys.

### Alternatives if this feels like too much

1. **Policy file plus `user.js` only:** the setup above without any externals.
   This is what I would pick.
2. **Firefox Sync:** it handles the installed extension list across machines
   with no chezmoi involvement, though it does not sync most extension
   settings.
3. **Manual installs:** treat extensions as unmanaged profile state and let
   chezmoi manage only `user.js` and `userChrome.css`. This is the least
   fragile option.

<!-- vim:set expandtab shiftwidth=2 filetype=markdown foldlevel=3: -->
