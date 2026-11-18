---
name: managing-dotfiles-with-chezmoi
description: >-
  Use when adding, changing, templating, applying or debugging dotfiles
  managed by chezmoi: its source directory and attribute-named files
  (dot_, private_, run_onchange_, .tmpl), .chezmoiignore, externals,
  scripts, secrets and encryption, the chezmoi config file, or setting
  up a machine from a dotfiles repo with chezmoi init.
license: GPL-3.0-only
---

<!--
   -
   - ~chewygumxx/agentic-library.git
   - ::: :/skills/managing-dotfiles-with-chezmoi/SKILL.md
   -
   -->

# Managing dotfiles with chezmoi

chezmoi keeps the desired state of a home directory in a source
directory, a git repo, and writes real files, not symlinks, into the
home directory on `chezmoi apply`. Here is how to change that state
safely, from an agent with no terminal, and check it before it lands.
Written against chezmoi 2.74; `chezmoi --version` tells you what you
are driving.

## The model

- **Source directory**, `~/.local/share/chezmoi` (`chezmoi source-path`):
  one regular file or directory per managed entry, with metadata in its
  name. Shared by every machine through git.
- **Config file**, `~/.config/chezmoi/chezmoi.toml` (or `.yaml`, `.json`,
  `.jsonc`, never two): this machine's own settings and `data`. Not in
  the repo; generated from `.chezmoi.toml.tmpl` in it, if present.
- **Target state**: what each file should be here, computed from source,
  config and templates. **Destination**: the home directory as it is.
- **Persistent state**, `~/.config/chezmoi/chezmoistate.boltdb`: what
  chezmoi last wrote and which scripts have run. A file changed since
  chezmoi last wrote it is a conflict on the next apply.

Edit the source, never the target: `apply` overwrites the target. To
keep a change made in the home directory, copy it back with `add` or
`re-add`.

## Working without a terminal

Agents run chezmoi without a TTY. A command that wants to ask fails
with `could not open a new TTY` and exit 1, having done nothing, so
reach for the non-interactive form from the start:

| Instead of                      | Do                                                                   |
| ------------------------------- | -------------------------------------------------------------------- |
| `chezmoi edit FILE`             | Edit the file at `chezmoi source-path FILE` directly                 |
| `chezmoi cd`                    | Work in `$(chezmoi source-path)`; `chezmoi git -- ARGS` for git      |
| `chezmoi merge FILE`            | Read `chezmoi diff FILE`, then edit the source or `add` the target   |
| `apply` over a conflict         | Resolve it as below; never `--force` before reading the diff         |
| `init` with `prompt*` templates | Pass every answer: `--promptString 'Prompt=value'`, `--promptBool …` |
| `forget`, `destroy`, `purge`    | Confirm with the user, then pass `--force`                           |
| `add` over a template           | Edit the `.tmpl` source instead; `add --force` drops the template    |

- Flags for `chezmoi git` go after `--`: `chezmoi git -- log --oneline`.
- `--no-pager` keeps `diff` out of a pager if a pseudo-terminal is
  attached; piped output is never paged.
- `--promptDefaults` answers only the prompts that have a default.
  `--no-tty` reads answers from stdin, one per line, in prompt order.
- Exit codes: `verify` is 0 only if nothing would change.
  `apply --error-on-conflict` exits 1 **without a message**; check
  `chezmoi status` for `MM` to find the conflict.

## The loop

1. **Look**: `chezmoi status` (what apply would do), `chezmoi managed`,
   `chezmoi source-path ~/.zshrc` (which source file is it).
2. **Change the source**: add a file, edit one, rename to change an
   attribute (`chezmoi chattr +template,+private ~/.netrc`).
3. **Check**: `chezmoi diff` for the whole effect, `chezmoi cat ~/.zshrc`
   for one target's computed contents, `chezmoi apply -n -v` for every
   action, scripts included, without running any. These print decrypted
   files and fetched secrets: add `--exclude=encrypted`, and see
   [secrets](./references/secrets.md) before showing their output.
4. **Apply** what you checked, naming it: `chezmoi apply ~/.zshrc`.
   A bare `chezmoi apply` also runs every due script.
5. **Commit** in the source repo: `chezmoi git -- add -A`, then
   `chezmoi git -- commit -m "…"`. Push only when the user asks.

The user's home directory is not a scratch area. Show the diff and get
assent before an `apply` that changes or removes something you did not
just write, and before anything that runs scripts.

### Resolving a conflict

`status` shows `MM`: the target was edited by hand and the source has
changed too. Read `chezmoi diff FILE`, which shows the edit apply would
undo, then either keep the local edit (`chezmoi re-add FILE`, or by
hand into a template's source) or discard it (`chezmoi apply --force
FILE`, after the user agrees).

## Naming source files

A source name is the target name with attribute prefixes and suffixes,
which must come in a fixed order: `private_dot_ssh/`,
`executable_dot_local/bin/…`, `encrypted_private_dot_netrc.age`,
`run_onchange_before_install.sh.tmpl`. An attribute out of order is not
an error: it becomes part of the target's name, so `dot_private_x`
writes `~/.private_x`. Let `chezmoi add` name files when you can, and
check a hand-made name with `chezmoi target-path SOURCE`.

Names starting with `.` are ignored in the source, except chezmoi's own
`.chezmoi*`. A `README.md` or `install.sh` at the source root is applied
into `~` unless listed in `.chezmoiignore`.

Attributes, target types, the special files and their order:
[source state](./references/source-state.md).

## Choosing the mechanism

| Need                                      | Use                                                              |
| ----------------------------------------- | ---------------------------------------------------------------- |
| A value that differs per machine          | Template, `.tmpl`, on `.chezmoi.os`, `.chezmoi.hostname`, `data` |
| A whole file on some machines only        | Template on `.chezmoiignore` (patterns are target paths)         |
| Some keys of a file a program also writes | `modify_` with `chezmoi:modify-template`, `setValueAtPath`       |
| Write once, then leave to the user        | `create_`                                                        |
| A program rewrites its config             | `modify_`, or `symlink_` back into the source dir                |
| A secret                                  | Password-manager template function, or `encrypted_`              |
| Someone else's files, a plugin, a binary  | `.chezmoiexternal.toml`                                          |
| Install packages, run a command           | `run_onchange_` script, keyed on what it installs                |
| A directory exactly as declared           | `exact_`, which deletes anything unmanaged in it                 |

Each in depth:

- [Templates](./references/templates.md): data and its precedence,
  variables, syntax and whitespace, shared templates, directives,
  functions, and the config file template that `init` runs.
- [Scripts and hooks](./references/scripts-and-hooks.md): `run_`
  scripts, `modify_` files, interpreters, environment, hooks, state.
- [Externals](./references/externals.md): archives, files, git repos
  and submodules from elsewhere.
- [Secrets and encryption](./references/secrets.md): password managers,
  age and gpg, and keeping secrets out of the repo.
- [Configuration and flags](./references/configuration.md): the config
  file's variables, global and common flags, entry types, new machines,
  several sources.
- [Troubleshooting](./references/troubleshooting.md): error messages,
  their causes and fixes.

## Checking

- `chezmoi status`: first column is the target's change since chezmoi
  last wrote it, second what apply will do: `A` add, `D` delete, `M`
  modify, `R` run a script.
- `chezmoi execute-template '{{ .chezmoi.hostname }}'`, or a whole file
  on stdin, renders a template; `chezmoi data` prints all template data.
- `chezmoi ignored`, `chezmoi unmanaged ~/.config`, and
  `chezmoi managed -i templates` list what is in and out.
- `chezmoi doctor` checks the install, its tools and the config.
- `--debug` traces a command step by step; `-v` prints each change.

## Pitfalls

- A file whose source or template renders **empty is deleted** from the
  target, and a template that renders empty on this machine is how a
  file is kept off it. Use `empty_` for a file that should be empty.
- A template indexing a missing key fails: `map has no entry for key`.
  Guard optional data with `hasKey`, `dig` or `default`, rather than
  loosening `template.options` for every file.
- `re-add` skips templates and exits 0, changing nothing. Copy the edit
  into the `.tmpl` by hand.
- `add` warns about a secret in a file and adds it anyway. Use
  `--secrets=error`, read the warning, and never push such a file.
- `git.autoPush` pushes whatever is added, secrets included.
- Hooks run even under `--dry-run`; scripts do not.
- `chezmoi add --exact --recursive ~/.config/nvim` with nothing else of
  `~/.config` managed makes `~/.config` exact too, and the next apply
  deletes the rest of it. Add a file of the parent first.
- `destroy` deletes the source and the target. To stop managing a file
  and keep it, use `forget`.
