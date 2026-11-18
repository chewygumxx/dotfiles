<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/.agents/skills/managing-dotfiles-with-chezmoi/references/source-state.md
   -
   -->

# Source state

Each entry in the source directory maps one to one onto a target:
directories to directories, and every other target type to a regular
file. Its name carries its type and attributes, so changing an attribute
is a rename, which `chezmoi chattr` does for you.

## Attributes

| Prefix        | Effect                                                                |
| ------------- | --------------------------------------------------------------------- |
| `after_`      | Run the script after updating the destination                         |
| `before_`     | Run the script before updating the destination                        |
| `create_`     | Create the file with these contents if absent; never change it after  |
| `dot_`        | A leading dot: `dot_zshrc` is `.zshrc`                                |
| `empty_`      | Keep the file even when empty; otherwise empty means absent           |
| `encrypted_`  | The source is encrypted                                               |
| `exact_`      | Remove anything in the directory that chezmoi does not manage         |
| `executable_` | Set the executable bits                                               |
| `external_`   | Ignore attributes in the directory's children, as for a git submodule |
| `literal_`    | Stop parsing prefixes                                                 |
| `modify_`     | The contents are a script or template that rewrites the existing file |
| `once_`       | Run the script once per distinct contents                             |
| `onchange_`   | Run the script when its contents or name change                       |
| `private_`    | Remove group and world permissions                                    |
| `readonly_`   | Remove write permissions                                              |
| `remove_`     | Remove the target, or the directory if empty                          |
| `run_`        | The contents are a script to run                                      |
| `symlink_`    | A symlink, its target the contents, one trailing newline stripped     |

| Suffix     | Effect                                                   |
| ---------- | -------------------------------------------------------- |
| `.tmpl`    | Execute the contents as a template                       |
| `.literal` | Stop parsing suffixes                                    |
| `.age`     | Stripped from an encrypted file under age (`age.suffix`) |
| `.asc`     | Stripped from an encrypted file under gpg (`gpg.suffix`) |

Prefixes must come in this order for each type. An attribute out of
order is read as part of the name.

| Target type  | Prefixes, in order                                                                | Suffix  |
| ------------ | --------------------------------------------------------------------------------- | ------- |
| Directory    | `remove_`, `external_`, `exact_`, `private_`, `readonly_`, `dot_`                 | none    |
| Regular file | `encrypted_`, `private_`, `readonly_`, `empty_`, `executable_`, `dot_`            | `.tmpl` |
| Create file  | `create_`, `encrypted_`, `private_`, `readonly_`, `empty_`, `executable_`, `dot_` | `.tmpl` |
| Modify file  | `modify_`, `encrypted_`, `private_`, `readonly_`, `executable_`, `dot_`           | none    |
| Remove       | `remove_`, `dot_`                                                                 | none    |
| Script       | `run_`, then `once_` or `onchange_`, then `before_` or `after_`                   | `.tmpl` |
| Symlink      | `symlink_`, `dot_`                                                                | `.tmpl` |

A `modify_` file takes no `.tmpl`: it becomes a template by containing
`chezmoi:modify-template` instead, and with `.tmpl` its template loses
`.chezmoi.stdin`. See [scripts and hooks](./scripts-and-hooks.md).

`literal_` and `.literal` serve a target whose own name begins with an
attribute: `literal_run_tests.sh` is `run_tests.sh`, a file, not a
script.

Permissions are only what the attributes express: files `0644`, `0755`,
`0600`, `0700`, `0444`, `0555`, `0400`, `0500`; directories `0755`,
`0700`, `0500`. Group write comes from the umask; set `umask = 0o022`
in the config to stop it. `chezmoi add` records a directory's `private_`
from its mode, as `private_dot_config` for a `0700` `~/.config`.

`chattr` takes attribute names or abbreviations, with `+`, `-` or `no`,
comma-separated: `chezmoi chattr +private,+template ~/.netrc`,
`chezmoi chattr -- -x ~/.zshrc` (a `-` form needs `--`). Abbreviations:
`a` after, `b` before, `e` empty, `x` executable, `o` once, `p` private,
`r` readonly, `t` template. Type modifiers `create`, `modify`, `script`,
`symlink`, and their `no` forms, change the type.

## Target types

- **File**: the contents, or the template's output. Empty output
  removes the target unless `empty_`.
- **Create file**: written only if absent. Its permissions are still
  enforced, so an empty `private_config` under `create_` keeps an
  existing file's mode `0600` without touching its contents.
- **Modify file**: rewrites the current contents; see
  [scripts and hooks](./scripts-and-hooks.md).
- **Remove**: `remove_dot_old` removes `~/.old` if it exists.
- **Directory**: created; `exact_` also deletes what it does not
  declare. Git drops empty directories, so give an empty source
  directory a `.keep` file, which `chezmoi add` does for you.
- **Symlink**: the target of the link is the contents, whitespace
  stripped; a `.tmpl` lets it differ per machine, for example
  `{{ .chezmoi.sourceDir }}/settings.json` for a file an application
  rewrites, kept in the source and listed in `.chezmoiignore`.
- **Script**: see [scripts and hooks](./scripts-and-hooks.md).

`mode = "symlink"` in the config makes plain files symlinks into the
source directory, like GNU Stow. Encrypted, executable, private and
template files stay regular files, and `add` makes no symlink until the
next `apply`.

## Special files and directories

Read in this order, each optional:

1. `.chezmoiroot`, at the repo root: a relative path, read first, that
   becomes the root of the source state. Every other special file
   moves under it, `.chezmoi.toml.tmpl` included; only
   `.chezmoiversion` may stay anywhere. Use it to keep a README,
   install script and CI files out of the source state.
2. `.chezmoi.$FORMAT.tmpl`, at the root: run by `init`, or by any
   command given `--init`, to write the config file. See
   [templates](./templates.md).
3. `.chezmoidata.$FORMAT` files and `.chezmoidata/` directories, in
   any directory: static data merged into the template data in lexical
   order, dictionaries deep-merged and lists replaced. They cannot be
   templates.
4. `.chezmoitemplates/`: shared templates for `template` and
   `includeTemplate`.
5. `.chezmoiignore`: patterns of targets to leave alone.
6. `.chezmoiremove`: patterns of targets to delete on apply. A template.
   Excluded (`!`) and ignored targets are never removed. Run
   `chezmoi apply -n -v` first.
7. `.chezmoiexternal.$FORMAT` and `.chezmoiexternals/`: see
   [externals](./externals.md).
8. `.chezmoiversion`: the oldest chezmoi that may read this source,
   as `2.50.0`. Older ones refuse.

`.chezmoiscripts/`, at the root, holds scripts that run without making
a matching directory in the target. They still need `run_`.

`$FORMAT` is `json`, `jsonc`, `toml` or `yaml`.

### `.chezmoiignore`

- One pattern per line, matched by doublestar against the **target**
  path, relative to the destination: `.config/app/conf`, never
  `dot_config/app/conf`.
- `*` stops at `/`: `*.txt` is top-level only, `*/*.txt` one level
  down. `**` crosses directories: `backups/` ignores the directory,
  `backups/**` only its contents.
- `!pattern` excludes from ignoring, and every exclude beats every
  include.
- `#` starts a comment at the line's start, or after whitespace.
- Always a template, `.tmpl` or not. Its logic runs inverted: list a
  file to keep it **off** a machine.

  ```text
  README.md
  {{- if ne .chezmoi.os "darwin" }}
  Library/
  {{- end }}
  {{- if not .work }}
  .config/work-vpn/
  {{- end }}
  ```

- A `.chezmoiignore` in a subdirectory of the source applies within it.
- `chezmoi ignored` lists what the patterns caught on this machine.

## Application order

1. Read the source state, then the destination, and compute the target
   state. A source change made while chezmoi runs, as by a `before_`
   script, is undefined behaviour.
2. Run `run_before_` scripts, in name order.
3. Update every entry, externals and plain `run_` scripts included, in
   ASCII order of the target name once attributes are stripped. A
   directory comes before what it contains.
4. Run `run_after_` scripts, in name order.

Order scripts with a number: `run_onchange_before_10-packages.sh`.
