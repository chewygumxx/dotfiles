---
ctime: 2026-10-08
mtime: 2026-10-08
spdx: GPL-3.0-only
title: "Plan: Chezmoi Managed Web Extensions"
description: >-
  Task-by-task implementation plan for the chezmoi managed web extensions
  design.
tags:
  - firefox
  - chromium
  - chezmoi
  - web-extensions
  - plan
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/docs/plans/08-10-2026-web-extensions.md
   -
   -->

# Chezmoi Managed Web Extensions Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** One chezmoi data list installs and updates Firefox and
ungoogled-chromium extensions, with all browser data under `~/.local/share`.

**Architecture:** `home/.chezmoidata/web-extensions.toml` feeds two
`.chezmoiexternals` templates, one inside the Firefox profile source dir
(signed XPIs from AMO, `type = "file"`) and one inside `chromium/` (Web Store
CRXs converted by `crx-unpack` through a chezmoi `filter`, or GitHub zips,
`type = "archive"`). A zsh wrapper loads the unpacked Chromium extensions with
`--load-extension`.

**Tech Stack:** chezmoi 2.73 templates and externals, zsh, bash, Python 3
standard library, Firefox 157, ungoogled-chromium 153.

**Spec:** [`docs/specs/08-10-2026-web-extensions-design.md`](../specs/08-10-2026-web-extensions-design.md)

## Global Constraints

- No em dashes anywhere (code, comments, commits, docs).
- No AI co-author trailers on commits or the PR.
- Commits: Conventional Commits, header at most 50 chars, body wrapped at 72,
  scopes from `.commitlintrc.mts` (`chromium` is added in Task 0; combine
  with `/`, for example `feat(chromium/firefox): ...`).
- Every new file starts with the editor modeline, `SPDX-License-Identifier:
  GPL-3.0-only`, and the boxed `~chewygumxx/dotfiles.git` /
  `::: :/<repo-relative path>` header in that file's comment syntax.
- 4-space indentation, 2 spaces for Markdown, LF, final newline.
- Never run `chezmoi apply` against the real `$HOME`. All apply tests use
  `--destination`, `--cache` and `--persistent-state` under a temp dir. The
  real apply is left to the user with both browsers closed.
- `crx-unpack` uses only the Python standard library and is invoked as
  `python3 -I <source path>`.
- Chromium Web Store `prodversion` comes from `webBrowsers.chromium.version`
  (`"153"`).

## Review Focus

1. **Non-CRX response from the Web Store** (delisted extension, HTML error
   page): `crx-unpack` must exit non-zero with a message naming the input,
   so `chezmoi apply` aborts instead of installing garbage. Pinned in Task 1.
2. **`~/.local/bin` reachable through a differently spelled `PATH` entry**
   (symlinked dir, trailing slash): the wrapper must not exec itself. Pinned
   in Task 4.
3. **Extension directory without `manifest.json`** (zip that needed
   `stripComponents`): the wrapper must warn and still launch. Pinned in
   Task 4.
4. **Migration while Chromium is running, or with both old and new profile
   dirs present**: no move, no data loss, apply continues. Pinned in Task 5.
5. **Applying over the current symlinked Firefox layout**: symlinks
   `chrome` and `user.js` must become real files without touching the
   symlink targets' contents first. Pinned in Task 3.

---

### Task 0: `chromium` commit scope

**Files:**
- Modify: `.commitlintrc.mts` (scope list, alphabetical, before `claude`)

- [ ] **Step 1: Write the failing test**

```zsh
echo "feat(chromium): Test" | bunx commitlint --config .commitlintrc.mts
```

- [ ] **Step 2: Run it to verify it fails**

Expected: `scope must be one of [btop, claude, ...]`.

- [ ] **Step 3: Implement**

```ts
        {
            name: "chromium",
            fullName: "Ungoogled Chromium",
            description: "Web Browser",
        },
```

- [ ] **Step 4: Run tests to verify they pass**

Rerun Step 1 (no output, exit 0) and `bun run typecheck` (exit 0).

- [ ] **Step 5: Commit**

```bash
git add .commitlintrc.mts
git commit -m "build: Add chromium commit scope"
```

---

### Task 1: `crx-unpack` converter

**Files:**
- Create: `home/dot_local/bin/executable_crx-unpack`

**Interfaces:**
- Produces: `python3 -I home/dot_local/bin/executable_crx-unpack < in.crx >
  out.zip`. Exit 0 with a zip whose `manifest.json` has `key`; exit 1 with a
  `crx-unpack: ...` message on stderr otherwise.

- [ ] **Step 1: Write the failing test**

```zsh
t=$(mktemp -d)
curl -sLo $t/pass.crx "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=153&acceptformat=crx3&x=id%3Dghmbeldphafepmbegfdlkpapadhbakde%26uc"
python3 -I home/dot_local/bin/executable_crx-unpack < $t/pass.crx > $t/pass.zip
```

- [ ] **Step 2: Run it to verify it fails**

Expected: `can't open file ... executable_crx-unpack`.

- [ ] **Step 3: Implement**

```python
#!/usr/bin/env python3
# vim:set expandtab shiftwidth=4 filetype=python:
# SPDX-License-Identifier: GPL-3.0-only

#
#
# ~chewygumxx/dotfiles.git
# ::: :/home/dot_local/bin/executable_crx-unpack
#
#

#
# Convert a CRX3 (stdin) to a zip (stdout) that Chromium loads unpacked
# under its Chrome Web Store ID: the publisher key from the CRX header is
# written into manifest.json as "key", entry modes are normalised, and the
# store-only _metadata/ directory is dropped.
#
# Used as a chezmoi externals filter, see docs/web-extensions.md.
#

import base64
import hashlib
import io
import json
import struct
import sys
import zipfile

# CrxFileHeader field numbers, components/crx_file/crx3.proto
SHA256_WITH_RSA = 2
SHA256_WITH_ECDSA = 3
SIGNED_HEADER_DATA = 10000
# AsymmetricKeyProof.public_key and SignedData.crx_id
PUBLIC_KEY = 1
CRX_ID = 1


def die(message):
    print(f"crx-unpack: {message}", file=sys.stderr)
    sys.exit(1)


def varint(buf, i):
    value = shift = 0
    while True:
        if i >= len(buf):
            raise ValueError("truncated varint")
        byte = buf[i]
        i += 1
        value |= (byte & 0x7F) << shift
        shift += 7
        if not byte & 0x80:
            return value, i


def fields(buf):
    """Yield (field number, bytes) for each length-delimited field."""
    i = 0
    while i < len(buf):
        tag, i = varint(buf, i)
        number, wire = tag >> 3, tag & 7
        if wire == 0:
            _, i = varint(buf, i)
        elif wire == 2:
            length, i = varint(buf, i)
            if i + length > len(buf):
                raise ValueError("truncated field")
            yield number, buf[i : i + length]
            i += length
        else:
            raise ValueError(f"unsupported wire type {wire}")


def publisher_key(header):
    crx_id, keys = None, []
    for number, value in fields(header):
        if number in (SHA256_WITH_RSA, SHA256_WITH_ECDSA):
            keys += [v for n, v in fields(value) if n == PUBLIC_KEY]
        elif number == SIGNED_HEADER_DATA:
            crx_id = next((v for n, v in fields(value) if n == CRX_ID), None)
    if crx_id is None:
        die("CRX header has no crx_id")
    for key in keys:
        if hashlib.sha256(key).digest()[:16] == crx_id:
            return key
    die("no public key in the CRX header matches its crx_id")


def main():
    data = sys.stdin.buffer.read()
    if data[:4] != b"Cr24":
        die(f"input is not a CRX ({len(data)} bytes, starts {data[:16]!r})")
    version, header_size = struct.unpack("<II", data[4:12])
    if version != 3:
        die(f"unsupported CRX version {version}")
    try:
        key = publisher_key(data[12 : 12 + header_size])
        src = zipfile.ZipFile(io.BytesIO(data[12 + header_size :]))
    except (ValueError, zipfile.BadZipFile) as error:
        die(f"malformed CRX: {error}")
    if "manifest.json" not in src.namelist():
        die("CRX has no top-level manifest.json")

    out = io.BytesIO()
    with src, zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as dst:
        for info in src.infolist():
            if info.filename.startswith("_metadata/"):
                continue
            blob = src.read(info)
            if info.filename == "manifest.json":
                manifest = json.loads(blob.decode("utf-8-sig"))
                manifest["key"] = base64.b64encode(key).decode("ascii")
                blob = json.dumps(manifest, ensure_ascii=False, indent=2).encode()
            info.external_attr = (0o40755 if info.is_dir() else 0o100644) << 16
            dst.writestr(info, blob)
    sys.stdout.buffer.write(out.getvalue())


if __name__ == "__main__":
    main()
```

- [ ] **Step 4: Run tests to verify they pass**

```zsh
python3 -I home/dot_local/bin/executable_crx-unpack < $t/pass.crx > $t/pass.zip && echo ok
unzip -p $t/pass.zip manifest.json | jq -r .key | base64 -d | sha256sum | cut -c1-32 | tr 0-9a-f a-p
unzip -l $t/pass.zip | grep -c _metadata
printf '<html>gone</html>' | python3 -I home/dot_local/bin/executable_crx-unpack; echo "exit $?"
```

Expected: `ok`; `ghmbeldphafepmbegfdlkpapadhbakde`; `0`;
`crx-unpack: input is not a CRX (17 bytes, ...)` then `exit 1`.

- [ ] **Step 5: Commit**

```bash
git add home/dot_local/bin/executable_crx-unpack
git commit -m "feat(chromium): Add crx-unpack CRX converter"
```

---

### Task 2: Extension data and externals

**Files:**
- Create: `home/.chezmoidata/web-extensions.toml`
- Create: `home/dot_local/share/chromium/.chezmoiexternals/web-extensions.toml.tmpl`
- Create: `home/dot_local/share/private_mozilla/private_firefox/chewyfox/.chezmoiexternals/web-extensions.toml.tmpl`
- Delete (untracked drafts): `home/dot_local/share/.chezmoidata/`,
  `home/dot_local/share/.chezmoiexternals/`,
  `home/dot_local/share/chromium-extensions/`,
  `home/dot_local/share/firefox-extensions/`

**Interfaces:**
- Consumes: `crx-unpack` from Task 1 at
  `{{ .chezmoi.sourceDir }}/dot_local/bin/executable_crx-unpack`.
- Produces: data keys `webBrowsers.chromium.version` and `webExtensions[]`
  with `name`, optional `firefox` (string), optional `chromium` (string or
  table `repo`, `asset`, optional `stripComponents`). Targets
  `.local/share/chromium/extensions/<name>/` and
  `.local/share/mozilla/firefox/chewyfox/extensions/<firefox>.xpi`.

- [ ] **Step 1: Write the failing test**

```zsh
chezmoi managed --include externals 2>&1 | tail -1
```

- [ ] **Step 2: Run it to verify it fails**

Expected: `function "repoSlug" not defined` (the current draft breaks every
chezmoi command).

- [ ] **Step 3: Implement**

Delete the four draft paths, then create the data file with the header
(TOML `#` comments, path `:/home/.chezmoidata/web-extensions.toml`), this
preamble, and one `[[webExtensions]]` table per row of the spec's lists,
sorted by `name`:

```toml
#
# Browser extensions installed and updated by chezmoi externals.
# See docs/web-extensions.md.
#
#   name      Stable identifier, also the Chromium extension directory
#   firefox   AMO add-on ID (about:support, Add-ons section)
#   chromium  Chrome Web Store ID, or { repo, asset[, stripComponents] }
#             naming a GitHub release asset that is an unpacked MV3 zip
#

[webBrowsers.chromium]
version = "153"    # Major version the Web Store serves builds for

[[webExtensions]]
name     = "auto-tab-discard"
firefox  = "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}"
chromium = "jhnleheckmknfcgijgkadoemagpecfol"
```

Full list (name, firefox, chromium):

```text
auto-tab-discard                 {c2c003ee-bd69-42a2-b0e9-6f34222cb046}       jhnleheckmknfcgijgkadoemagpecfol
australian-english-dictionary    AussieDic@dictionaries.addons.mozilla.org    -
british-english-dictionary       marcoagpinto@mail.telepac.pt                 -
claude                           -                                            fcoeoabgfenejglbffodgkkbkcdhcgfn
clearurls                        {74145f27-f039-47ce-a470-a662b129930a}       -
contextsearch-web-ext            {5dd73bb9-e728-4d1e-990b-c77d8e03670f}       -
cookie-editor                    {c3c10168-4186-445c-9c5b-63f12b8e2c87}       -
dark-reader                      addon@darkreader.org                         eimadpbcbfnmbkopoojfekhnkhdbieeh
dearrow                          deArrow@ajay.app                             enamippconapkdmgfgjchkhakpfinmaj
download-all-images              {32af1358-428a-446d-873e-5f8eb5f2a72e}       -
headingsmap                      headings@niquelheadings.net                  flbjommegcjonpdmenkdiocclhjacmbi
hide-youtube-shorts              {88ebde3a-4581-4c6b-8019-2a05a9e3e938}       ankepacjgoajhjpenegknbefpmfffdic
image-search-options             {4a313247-8330-4a81-948e-b79936516f78}       -
imagus-mod                       {6833a9cb-d329-4d96-a062-76b1b663cd2c}       -
imagus-reborn                    {7653b5cb-d76d-442f-a98f-f3c83a118cf4}       { repo = "hababr/Imagus-Reborn", asset = "ImagusReborn_Chrome_*.zip" }
load-reddit-images-directly      {4c421bb7-c1de-4dc6-80c7-ce8625e34d24}       -
obsidian-web-clipper             clipper@obsidian.md                          cnjifjpddelmedmihgijeibhnjfabmlf
open-multiple-urls               openmultipleurls@ustat.de                    -
proton-pass                      78272b6fa58f4a1abaac99321d503a20@proton.me   ghmbeldphafepmbegfdlkpapadhbakde
proton-vpn                       vpn@proton.ch                                jplgfhpmjnbigmhklmmbgecoobifkmpa
return-youtube-dislike           {762f9885-5a13-4abd-9c77-433dcd38b8fd}       gebbhagfogifgggkldgodflihgfeippi
scriptcat                        {8e515334-52b5-4cc5-b4e8-675d50af677d}       -
sidebery                         {3c078156-979c-498b-8990-85f7987dd929}       -
simple-modify-headers            {f6ca2dfb-43a6-4334-9fad-8d5a71a1fe67}       gjgiipmpldkpbdfjkgofildhapegmmic
singlefile                       {531906d3-e22f-4a6c-a102-8057b88a1a63}       mpiodijhokgodhhofbcjdecpffjipkle
sponsorblock                     sponsorBlocker@ajay.app                      mnjggcdmjocbbbhaepdhchncahnbgone
stylus                           {7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}       clngdbkpkpeebahjckkjfobafhncgmne
tab-image-saver                  tab-image-saver@mcdamo.addons.mozilla.org    -
theme-blue-cyberpunk             {7a92e0d1-2ea7-4124-87e5-016277703208}       -
theme-cyberpunk-2077-3           {d8c44ec8-e3c4-4329-a060-7c958ba9c3c0}       -
theme-cyberpunk-lo-fi            {7c9b0deb-b62d-44df-b970-cd11deb60741}       -
theme-cyberpunk-pixels-animated  {0d3d9708-a9af-4a3a-bba4-d05df61379b6}       -
theme-itj-cyberpunk-dark-edit    {ec987ed3-b360-420b-93ee-dadf30f59601}       -
theme-pixel-cyberpunk            {b0c031ea-1653-4749-b7c1-bd5c4c58c07d}       -
twp-translate-web-pages          {036a55b4-5e72-4d05-a06c-cba2dfcc134a}       -
ublock-origin                    uBlock0@raymondhill.net                      ddkjiahejlhfcafbddmgiahcphecmpfh
ultimadark                       {7c7f6dea-3957-4bb9-9eec-2ef2b9e5bcec}       -
view-image                       {287dcf75-bec6-4eec-b4f6-71948a2eea29}       -
violentmonkey                    {aecec67f-0d10-4fa7-b7c7-609a2db280cf}       jinjaccalgkegednnccohejagnlnfdag
```

Chromium externals template (header uses `filetype=gotmpl`):

```gotmpl
{{- /* Termux runs neither browser; skip all network work there */ -}}
{{- if ne .chezmoi.destDir "/data/data/com.termux/files/home" }}
{{-   $crxUnpack := joinPath .chezmoi.sourceDir "dot_local/bin/executable_crx-unpack" }}
{{-   $prodversion := .webBrowsers.chromium.version }}
{{-   range .webExtensions }}
{{-     $source := get . "chromium" }}
{{-     if $source }}

[{{ joinPath "extensions" .name | quote }}]
    type           = "archive"
    exact          = true
    refreshPeriod  = "168h"
{{-       if kindIs "string" $source }}
    format         = "zip"
    url            = {{ printf "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=%s&acceptformat=crx3&x=id%%3D%s%%26uc" $prodversion $source | quote }}
    filter.command = "python3"
    filter.args    = ["-I", {{ $crxUnpack | quote }}]
{{-       else }}
    url            = {{ gitHubLatestReleaseAssetURL $source.repo $source.asset | quote }}
{{-         with get $source "stripComponents" }}
    stripComponents = {{ . }}
{{-         end }}
{{-       end }}
{{-     end }}
{{-   end }}
{{- end }}
```

Firefox externals template:

```gotmpl
{{- /* Termux runs neither browser; skip all network work there */ -}}
{{- if ne .chezmoi.destDir "/data/data/com.termux/files/home" }}
{{-   range .webExtensions }}
{{-     with get . "firefox" }}

[{{ printf "extensions/%s.xpi" . | quote }}]
    type          = "file"
    url           = {{ printf "https://addons.mozilla.org/firefox/downloads/latest/%s/latest.xpi" (urlquery .) | quote }}
    refreshPeriod = "168h"
{{-     end }}
{{-   end }}
{{- end }}
```

- [ ] **Step 4: Run tests to verify they pass**

```zsh
chezmoi execute-template < home/dot_local/share/chromium/.chezmoiexternals/web-extensions.toml.tmpl | grep -c '^\['
chezmoi execute-template < home/dot_local/share/private_mozilla/private_firefox/chewyfox/.chezmoiexternals/web-extensions.toml.tmpl | grep -c '^\['
chezmoi managed --include externals | grep -cE 'chromium/extensions/[^/]+$|chewyfox/extensions/[^/]+\.xpi$'
```

Expected: `17`, `38`, `55`. If the last count is lower, the profile's
`.chezmoiignore` is hiding `extensions/`; Task 3 fixes that and reruns this.

- [ ] **Step 5: Commit**

```bash
git add home/.chezmoidata home/dot_local/share/chromium home/dot_local/share/private_mozilla/private_firefox/chewyfox/.chezmoiexternals
git commit -m "feat(chromium/firefox): Add extension externals"
```

---

### Task 3: Firefox data tree reorganisation

**Files:**
- Move: `home/dot_config/mozilla-firefox/{installs.ini,profiles.ini,.gitattributes}`
  to `home/dot_local/share/private_mozilla/private_firefox/`
- Move: `home/dot_config/mozilla-firefox/chewyfox/{user.js,chrome/}` to
  `home/dot_local/share/private_mozilla/private_firefox/chewyfox/`
- Delete: `home/dot_config/mozilla-firefox/chewyfox/extensions.json`, the
  four `symlink_*` files under `private_firefox/`
- Modify: `private_firefox/chewyfox/.chezmoiignore` (allow `extensions/`),
  `private_firefox/.chezmoiignore` (typo `Prolfile Groups/`),
  `chewyfox/user.js` (two prefs), `home/.chezmoiremove`
  (`.config/mozilla-firefox`)

**Interfaces:**
- Consumes: Firefox externals from Task 2.
- Produces: real files at `.local/share/mozilla/firefox/{profiles.ini,
  installs.ini}` and `.local/share/mozilla/firefox/chewyfox/{user.js,
  chrome/*, extensions/*.xpi}`.

- [ ] **Step 1: Write the failing test** (Review Focus 5)

Build the current layout in a temp destination from `main`, then apply the
branch over it:

```zsh
t=$(mktemp -d); mkdir $t/main $t/dst
git archive main home | tar -x -C $t/main
c=(--destination $t/dst --cache $t/cache --persistent-state $t/state.boltdb --no-tty --force)
chezmoi --source $t/main/home $c apply $t/dst/.config/mozilla-firefox $t/dst/.local/share/mozilla
find $t/dst/.local/share/mozilla -maxdepth 3 -type l
```

- [ ] **Step 2: Run it to verify the starting state**

Expected: four symlinks (`profiles.ini`, `installs.ini`, `chewyfox/chrome`,
`chewyfox/user.js`).

- [ ] **Step 3: Implement**

`git mv` the files listed above, `git rm` `extensions.json` and the four
symlinks, then fix each moved file's header path with `sed`
(`:/home/dot_config/mozilla-firefox/` to
`:/home/dot_local/share/private_mozilla/private_firefox/`). In
`chewyfox/.chezmoiignore` add `!extensions/` after `!chrome/`. In
`private_firefox/.chezmoiignore` change `Prolfile Groups/` to
`Profile Groups/`. In `.chezmoiremove` under "Removed Everywhere" add:

```gitignore
.config/mozilla-firefox   # Firefox files now live in .local/share/mozilla/firefox
```

In `user.js`, in the `// Extensions` block, add:

```js
user_pref("extensions.autoDisableScopes", 14);           // Enable add-ons chezmoi places in the profile
user_pref("extensions.update.autoUpdateDefault", false); // chezmoi owns add-on updates
```

- [ ] **Step 4: Run tests to verify they pass**

```zsh
chezmoi --source home $c apply $t/dst/.config $t/dst/.local/share/mozilla
find $t/dst/.local/share/mozilla -maxdepth 3 -type l | wc -l
ls $t/dst/.config/mozilla-firefox 2>&1
ls $t/dst/.local/share/mozilla/firefox/chewyfox/extensions | wc -l
diff <(git show main:home/dot_config/mozilla-firefox/chewyfox/chrome/userChrome.css) $t/dst/.local/share/mozilla/firefox/chewyfox/chrome/userChrome.css && echo same
cp -r $t/dst/.local/share/mozilla/firefox/chewyfox $t/ff
HOME=$t/home XDG_CONFIG_HOME=$t/home/.config timeout 30 firefox --headless --no-remote --profile $t/ff about:blank >/dev/null 2>&1
jq '[.addons[] | select(.location=="app-profile" and .active and .signedState==2)] | length' $t/ff/extensions.json
```

Expected: `0`; `No such file or directory`; `38`; `same`; `38`. Then
rerun the Task 2 Step 4 count and expect `55`.

- [ ] **Step 5: Commit** (two commits)

```bash
git add -A home/dot_config/mozilla-firefox home/dot_local/share/private_mozilla home/.chezmoiremove
git commit -m "refactor(firefox): Move profile files into data dir" -m "Drops the symlink round trip through ~/.config/mozilla-firefox and the
tracked extensions.json, which was volatile state and not the live copy."
git add home/dot_local/share/private_mozilla/private_firefox/chewyfox/user.js
git commit -m "feat(firefox): Let chezmoi own add-on installs"
```

(Stage `user.js` prefs separately with `git add -p` before the first commit
so the move commit is a pure move plus header fixes.)

---

### Task 4: Chromium wrapper

**Files:**
- Create: `home/dot_local/bin/executable_chromium` (rewrite of the draft)

**Interfaces:**
- Consumes: `.local/share/chromium/extensions/<name>/manifest.json` from
  Task 2.
- Produces: `chromium [args]` execs the real binary with
  `--user-data-dir=$XDG_DATA_HOME/chromium/chewy-ungoogled` and
  `--load-extension=<comma-joined dirs>`.

- [ ] **Step 1: Write the failing tests** (Review Focus 2 and 3)

```zsh
t=$(mktemp -d); mkdir -p $t/bin $t/link $t/data/chromium/extensions/{good,bad}
echo '{}' > $t/data/chromium/extensions/good/manifest.json
printf '#!/bin/sh\nprintf "%%s\\n" "$@"\n' > $t/bin/chromium; chmod +x $t/bin/chromium
cp home/dot_local/bin/executable_chromium $t/link/chromium; chmod +x $t/link/chromium
ln -s $t/link $t/link-alias
PATH="$t/link-alias/:$t/bin:/usr/bin" XDG_DATA_HOME=$t/data $t/link/chromium --x 2>&1
```

- [ ] **Step 2: Run them to verify they fail**

Expected with the draft: `--user-data-dir` points at
`$t/data/chewy-ungoogled` and there is no `--load-extension`.

- [ ] **Step 3: Implement**

```zsh
#!/usr/bin/env zsh
# vim:set expandtab shiftwidth=4 filetype=zsh:
# SPDX-License-Identifier: GPL-3.0-only

#
#
# ~chewygumxx/dotfiles.git
# ::: :/home/dot_local/bin/executable_chromium
#
#

#
# Shadow wrapper as configuration
#
# Loads every unpacked extension chezmoi places in
# $XDG_DATA_HOME/chromium/extensions/, see docs/web-extensions.md.
#

local self="${${(%):-%N}:A}"
local data="${XDG_DATA_HOME:-$HOME/.local/share}/chromium"

# --------------
# Configuration
# --------------

# Profile directory under $data, passed as --user-data-dir
local PROFILE="chewy-ungoogled"

# https://github.com/ungoogled-software/ungoogled-chromium/blob/master/docs/flags.md
local -a flags=(
    # (draft flags kept verbatim, from --enable-features=DisableQRGenerator
    #  through --extension-mime-request-handling=download-as-regular-file)

    # Application data directory
    # - Default: ~/.config/chromium
    --user-data-dir="$data/$PROFILE"
)

# --------
# Helpers
# --------

log() {
    print -u2 -r -- "${self:t}: $*"
}

fatal() {
    local code=1
    if [[ "$1" == -<-> ]]; then
        code="${1#-}"
        shift
    fi
    log "$@"
    exit "$code"
}

# -----------
# Resolution
# -----------

# First `chromium` in PATH that is not this file, compared by resolved
# path so a differently spelled PATH entry for this directory is skipped
# too. PATH itself is left untouched for the browser.
local candidate real
for candidate in ${(f)"$(whence -ap -- "${self:t}")"}; do
    [[ "${candidate:A}" == "$self" ]] && continue
    real="$candidate"
    break
done
[[ -n "$real" ]] || fatal -127 "Shadowed command not found: ${self:t}"

# -----------
# Extensions
# -----------

local -a extensions
local dir
for dir in "$data"/extensions/*(N/); do
    if [[ -f "$dir/manifest.json" ]]; then
        extensions+=("$dir")
    else
        log "Skipping extension without manifest.json: ${(D)dir}"
    fi
done
(( $#extensions )) && flags+=(--load-extension="${(j:,:)extensions}")

# ----------
# Execution
# ----------

exec "$real" "${flags[@]}" "$@"
```

- [ ] **Step 4: Run tests to verify they pass**

Rerun Step 1 with the new file copied in. Expected: no recursion; the
flags printed include `--user-data-dir=$t/data/chromium/chewy-ungoogled`
and `--load-extension=$t/data/chromium/extensions/good`, followed by `--x`;
stderr has `Skipping extension without manifest.json: .../bad`. Also:

```zsh
PATH="$t/link:/nonexistent" $t/link/chromium; echo "exit $?"
```

Expected: `chromium: Shadowed command not found: chromium`, `exit 127`.

- [ ] **Step 5: Commit**

```bash
git add home/dot_local/bin/executable_chromium
git commit -m "feat(chromium): Rewrite shadow wrapper"
```

---

### Task 5: Chromium profile migration

**Files:**
- Create: `home/.chezmoiscripts/run_before_migrate-chromium-profile`

`run_before_`, not `run_once_before_`: a skipped run (Chromium open) must be
retried on the next apply, and the script is a no-op once the old directory
is gone.

**Interfaces:**
- Produces: `${CHEZMOI_DEST_DIR:-$HOME}/.local/share/chewy-ungoogled` moved
  to `.../chromium/chewy-ungoogled`. Uses the destination dir, not
  `XDG_DATA_HOME`, because that is where chezmoi places
  `.local/share/chromium/`, and it keeps `--destination` tests away from the
  real home.

- [ ] **Step 1: Write the failing tests** (Review Focus 4)

```zsh
s=home/.chezmoiscripts/run_before_migrate-chromium-profile
t=$(mktemp -d); mkdir -p $t/.local/share/chewy-ungoogled/Default; touch $t/.local/share/chewy-ungoogled/Default/Prefs
CHEZMOI_DEST_DIR=$t bash $s; echo "exit $?"; ls $t/.local/share/chromium/chewy-ungoogled/Default
```

- [ ] **Step 2: Run them to verify they fail**

Expected: `No such file or directory` for the script.

- [ ] **Step 3: Implement**

```bash
#!/usr/bin/env bash
# vim:set expandtab shiftwidth=4 filetype=bash:
# SPDX-License-Identifier: GPL-3.0-only

#
#
# ~chewygumxx/dotfiles.git
# ::: :/home/.chezmoiscripts/run_before_migrate-chromium-profile
#
#

#
# Moves the ungoogled-chromium profile into the per-vendor data tree,
# see docs/web-extensions.md. Runs before every apply and does nothing once
# the old directory is gone, so a skipped run is retried next time.
#

script_name="migrate-chromium-profile"
data="${CHEZMOI_DEST_DIR:-$HOME}/.local/share"
old="$data/chewy-ungoogled"
new="$data/chromium/chewy-ungoogled"

__log() {
    printf '%s: [%s] %s\n' "$script_name" "$1" "${*:2}" >&2
}

[[ -d "$old" ]] || exit 0

if [[ -e "$new" ]]; then
    __log WARN "Both $old and $new exist, leaving both untouched"
    exit 0
fi

# Chromium holds this symlink in its user data dir while running
if [[ -L "$old/SingletonLock" ]]; then
    __log WARN "Chromium is using $old, close it and rerun chezmoi apply"
    exit 0
fi

mkdir -p -- "${new%/*}" && mv -- "$old" "$new" || {
    __log ERROR "Failed to move $old to $new"
    exit 1
}
__log NOTICE "Moved $old to $new"
```

- [ ] **Step 4: Run tests to verify they pass**

Rerun Step 1: `NOTICE Moved ...`, `exit 0`, `Prefs` listed. Then:

```zsh
t=$(mktemp -d); mkdir -p $t/.local/share/chewy-ungoogled; ln -s host-1 $t/.local/share/chewy-ungoogled/SingletonLock
CHEZMOI_DEST_DIR=$t bash $s; echo "exit $?"; ls -d $t/.local/share/chewy-ungoogled
mkdir -p $t/.local/share/chromium/chewy-ungoogled; rm $t/.local/share/chewy-ungoogled/SingletonLock
CHEZMOI_DEST_DIR=$t bash $s; echo "exit $?"
t=$(mktemp -d); CHEZMOI_DEST_DIR=$t bash $s; echo "exit $?"
```

Expected: running WARN, `exit 0`, old dir still present; both-exist WARN,
`exit 0`; silent `exit 0`.

- [ ] **Step 5: Commit**

```bash
git add home/.chezmoiscripts/run_before_migrate-chromium-profile
git commit -m "feat(chromium): Migrate profile into data tree"
```

---

### Task 6: systemd units and host scoping

**Files:**
- Revert: `home/dot_config/systemd/user/firefox.service` (back to
  `ExecStart=/usr/bin/firefox`)
- Create: `home/dot_config/systemd/user/ungoogled-chromium.service` (draft
  kept as is)
- Modify: `home/.chezmoiignore` (Termux section)

- [ ] **Step 1: Write the failing test**

```zsh
systemd-analyze --user verify home/dot_config/systemd/user/firefox.service 2>&1 | grep -c '.local/bin/firefox'
```

- [ ] **Step 2: Run it to verify it fails**

Expected: `1` (the draft points at a nonexistent wrapper).

- [ ] **Step 3: Implement**

`git checkout -- home/dot_config/systemd/user/firefox.service`. In
`home/.chezmoiignore`, inside the Termux block, add:

```gitignore
.local/bin/chromium            # Neither browser runs on Termux
.local/bin/crx-unpack
.local/share/chromium/
.local/share/mozilla/
.config/systemd/user/ungoogled-chromium.service
```

- [ ] **Step 4: Run tests to verify they pass**

```zsh
systemd-analyze --user verify home/dot_config/systemd/user/{firefox,ungoogled-chromium}.service 2>&1 | grep -E 'firefox|chromium'
chezmoi execute-template < home/.chezmoiignore >/dev/null && echo parses
```

Expected: no output naming a missing executable; `parses`.

- [ ] **Step 5: Commit**

```bash
git add home/dot_config/systemd/user/ungoogled-chromium.service
git commit -m "feat(systemd): Add ungoogled-chromium unit"
git add home/.chezmoiignore
git commit -m "chore(termux): Ignore browser files"
```

---

### Task 7: End-to-end verification and documentation

**Files:**
- Create: `docs/web-extensions.md` (how the system works and how to use it)
- Create: `docs/notes/08-10-2026-web-extensions-verification.md` (report)
- Modify: `.claude/CLAUDE.md` (mention `docs/` and the web extension data)

- [ ] **Step 1: Full temp apply**

```zsh
t=$(mktemp -d); c=(--destination $t/dst --cache $t/cache --persistent-state $t/state.boltdb --no-tty --force)
chezmoi --source home $c apply $t/dst/.local/share/chromium $t/dst/.local/share/mozilla $t/dst/.local/bin/chromium
ls $t/dst/.local/share/chromium/extensions | wc -l
```

Expected: `17`.

- [ ] **Step 2: Chromium registers every extension under the right ID**

```zsh
# PATH excludes ~/.local/bin so the real home's wrapper (and profile) is never reached
PATH=/usr/bin:/bin XDG_DATA_HOME=$t/dst/.local/share zsh $t/dst/.local/bin/chromium --headless=new --no-first-run --remote-debugging-port=9335 about:blank >$t/log 2>&1 & pid=$!
sleep 15; kill $pid; wait $pid
jq -r '.extensions.settings | to_entries[] | select(.value.location==8) | .key' $t/dst/.local/share/chromium/chewy-ungoogled/Default/{Secure\ ,}Preferences 2>/dev/null | sort -u
```

Expected: 17 IDs, including all 16 Web Store IDs from the data file
(`location` 8 is `COMMAND_LINE`, the `--load-extension` source). If this
build does not persist command-line extensions, fall back to the remote
debugging target list plus `chrome://extensions-internals`, and record which
method was used.

- [ ] **Step 3: `chezmoi diff` against the real home**

```zsh
chezmoi diff --exclude externals | grep -E '^(diff|rename|deleted|new)' | head -40
```

Expected: only paths from Tasks 1 to 6. Record the summary.

- [ ] **Step 4: Write the docs**

`docs/web-extensions.md` sections: Overview (diagram of data, templates,
targets), Data file reference (keys and both `chromium` forms), Adding and
removing an extension (finding AMO and Web Store IDs), Updating
(`chezmoi apply --refresh-externals`, `refreshPeriod`), Firefox details
(profile scope, the two prefs and their trade-off, disabled state survives),
Chromium details (`crx-unpack`, key injection, wrapper, `exact`), First
apply on this machine (close both browsers; migration; leftover
`~/.config/chromium`; `firefox-i18n-en-gb`), Troubleshooting (non-CRX,
GitHub rate limit and `GITHUB_TOKEN`, missing `manifest.json`,
`about:addons` showing updates), Future: system policies.

`docs/notes/08-10-2026-web-extensions-verification.md`: every check from the
spec's "Verified constraints" and this plan's test steps, with the command,
the observed output, and the date.

- [ ] **Step 5: Commit**

```bash
git add docs/web-extensions.md && git commit -m "docs: Document web extension management"
git add docs/notes && git commit -m "docs: Add web extensions verification report"
git add .claude/CLAUDE.md && git commit -m "docs(claude): Note docs dir and extension data"
```

---

### Task 8: Push and pull request

- [ ] **Step 1:** `bun run typecheck` is irrelevant here; instead run
  `git log --format=%s main..` and check every subject against the commit
  rules, and `grep -rnP '\x{2014}' docs home/.chezmoidata home/dot_local/bin/executable_c*`
  for em dashes.
- [ ] **Step 2:** `git push -u origin feat/web-extensions`.
- [ ] **Step 3:** `gh pr create --base main` with a body that links (as
  blob URLs on the branch) the spec, this plan, `docs/web-extensions.md`, the
  verification report and the conversation notes, plus a summary, the
  first-apply checklist, and the known trade-offs. No AI trailer.
- [ ] **Step 4:** Watch CI (`commitlint`, `sync-header-metadata`,
  `lint-config`) and pull any header-sync commit back.

<!-- vim:set expandtab shiftwidth=2 filetype=markdown: -->
