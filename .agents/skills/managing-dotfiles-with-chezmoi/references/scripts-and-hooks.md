<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/.agents/skills/managing-dotfiles-with-chezmoi/references/scripts-and-hooks.md
   -
   -->

# Scripts and hooks

Scripts break chezmoi's declarative model, so keep them few and
idempotent, `once_` and `onchange_` ones too: state can be reset, and
a failed run is retried.

## `run_` scripts

| Name                      | Runs                                                                  |
| ------------------------- | --------------------------------------------------------------------- |
| `run_x.sh`                | On every `apply`                                                      |
| `run_onchange_x.sh`       | When its contents, after templating, or its name have changed         |
| `run_once_x.sh`           | Once per distinct contents, even renamed, until it succeeds           |
| `…_before_…`, `…_after_…` | Before or after every file is updated; otherwise in target-name order |

- A script needs a `#!` line, or to be a binary; chezmoi sets the
  executable bit itself. On Windows, and for hooks, the extension picks
  an interpreter: `.ps1` `pwsh`, `.py` `python3`, `.pl` `perl`, `.rb`
  `ruby`, `.nu` `nu`; add others under `[interpreters.EXT]` with
  `command` and `args`.
- A `.tmpl` script that renders to nothing but whitespace does not run:
  wrap a whole script in `{{ if eq .chezmoi.os "linux" -}} … {{ end -}}`
  to run it on some machines only. Trim the newline before `#!` with
  `-}}`, or the kernel reports `exec format error`.
- Put scripts in `.chezmoiscripts/`, at the source root, so they make
  no directory in the target. Elsewhere, a script runs in its matching
  target directory, or the nearest one that exists.
- Name them to order them: `run_onchange_before_10-packages.sh.tmpl`.
- `-n` never runs a script. `-v` prints each script before running it.
  `diff` prints each due script, and `status` marks it `R`; set
  `diff.exclude`, `status.exclude` to `["scripts"]` to hide them.
- `--exclude=scripts` applies files only; `--include=scripts` runs only
  scripts.
- A script runs as the user. One that needs root calls `sudo` itself,
  and must wait for anything it elevates before it exits.
- A script that `apply` runs cannot call chezmoi back: `apply` holds the
  state lock, and `status`, `diff`, even `source-path` fail with
  `timeout obtaining persistent state lock`. Read the environment below
  instead.

### Environment

Scripts, hooks and `chezmoi cd` see `CHEZMOI=1` and `.chezmoi`'s data
in upper snake case: `CHEZMOI_OS`, `CHEZMOI_ARCH`, `CHEZMOI_HOSTNAME`,
`CHEZMOI_SOURCE_DIR`, `CHEZMOI_DEST_DIR`, `CHEZMOI_HOME_DIR`,
`CHEZMOI_CONFIG_FILE`, `CHEZMOI_OS_RELEASE_ID`, with `CHEZMOI_COMMAND`
(as `apply`) and `CHEZMOI_ARGS`. Add more under `[scriptEnv]` in the
config. A script is not a template unless `.tmpl`, so read these rather
than template data when it can stay plain.

### Patterns

Run when another file changes, by hashing it into a comment:

```sh
#!/bin/sh
# dconf.ini hash: {{ include "dconf.ini" | sha256sum }}
dconf load / < {{ joinPath .chezmoi.sourceDir "dconf.ini" | quote }}
```

Name it `run_onchange_after_dconf-load.sh.tmpl` and list `dconf.ini` in
`.chezmoiignore`. The same trick re-runs a script when a `git-repo`
external moves (`output "git" "-C" PATH "rev-parse" "HEAD"`), each day
(`now | date "2006-01-02"`), or after an OS update (`output "sw_vers"
"--buildVersion"`).

Install packages declaratively from data in
`.chezmoidata/packages.yaml`, so adding one re-runs the script:

```text
{{ if eq .chezmoi.os "darwin" -}}
#!/bin/bash
brew bundle --file=/dev/stdin <<EOF
{{ range .packages.darwin.brews -}}
brew {{ . | quote }}
{{ end -}}
EOF
{{ end -}}
```

A tool a template needs, as `output "jq" …` does, must be installed by a
`run_before_` script that is **not** a template: templates are rendered
before any script runs. A password manager that templates need goes in
a `read-source-state.pre` hook instead, below.

Leave out of scripts what chezmoi already does: file contents (a file),
a file's mode (`create_` with `private_`), a downloaded file (an
external).

### Script state

`once_` and `onchange_` record what ran in the persistent state. To run
them all again:

```sh
chezmoi state delete-bucket --bucket=scriptState  # run_once_
chezmoi state delete-bucket --bucket=entryState   # run_onchange_
```

`chezmoi state dump` shows everything recorded.

## `modify_` files

A `modify_` file computes a target from its current contents, for files
that both you and a program write. Two forms:

- **A template**, if it contains `chezmoi:modify-template` anywhere
  (lines holding it are removed). The current contents are
  `.chezmoi.stdin`; the output is the new file. Never name it `.tmpl`.

  ```text
  {{- /* chezmoi:modify-template */ -}}
  {{ .chezmoi.stdin | default "{}" | fromJson
     | setValueAtPath "editor.fontSize" 14
     | toPrettyJson -}}
  ```

  `default "{}"` covers a missing target, whose stdin is empty and would
  fail `fromJson`. The closing `-}}` drops the newline after the
  action, as `toPrettyJson`, `toToml` and `toYaml` end with their own.
  Parse with `fromToml`, `fromYaml`, `fromIni` and `fromJsonc`
  likewise; serialising does not keep comments or key order.
  `replaceAllRegex "old" "new"` edits text in place.

- **A script**, otherwise: it reads the current contents on stdin and
  writes the whole new file to stdout, so it must reproduce what it does
  not change, and the whole file when stdin is empty.

Check one with `chezmoi cat FILE` and `chezmoi diff FILE`.

## Hooks

Hooks are commands in the config file, run before and after an event,
**even under `--dry-run`**. Keep them fast and idempotent.

```toml
[hooks.read-source-state.pre]
    command = ".local/share/chezmoi/.install-password-manager.sh"
[hooks.apply.post]
    command = "notify-send"
    args = ["dotfiles applied"]
```

- Events: any command's name (`apply`, `add`, `update`, …),
  `read-source-state`, `git-auto-commit`, `git-auto-push`; each with
  `.pre` and `.post`.
- `command` runs directly; `script` runs by the interpreter for its
  extension.
- `CHEZMOI_COMMAND`, `CHEZMOI_COMMAND_DIR` and `CHEZMOI_ARGS` say what
  triggered it.
- `read-source-state.pre` runs after `init` clones the repo and before
  any template renders: the place to install a password manager. The
  hook is not a template, so it detects the system with `uname`, exits
  at once when there is nothing to do, and starts with `.` so chezmoi
  does not apply it.
