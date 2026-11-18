<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/.agents/skills/managing-dotfiles-with-chezmoi/references/configuration.md
   -
   -->

# Configuration and flags

## The config file

`~/.config/chezmoi/chezmoi.$FORMAT`, following XDG, in TOML, YAML, JSON
or JSONC; two at once is an error. `--config FILE` reads another.
`chezmoi cat-config` prints it, `chezmoi dump-config` prints the
effective settings. It is this machine's alone: if the repo has a
`.chezmoi.$FORMAT.tmpl`, change that and run `chezmoi init`, rather
than editing the generated file, or the next `init` undoes the edit.

In TOML, top-level keys such as `encryption` and `umask` must come
before the first `[section]`, or they land inside it.

| Variable                                                   | Use                                                        |
| ---------------------------------------------------------- | ---------------------------------------------------------- |
| `data`                                                     | Template data for this machine                             |
| `sourceDir`, `destDir`, `workingTree`                      | Where the source, the target and the git repo are          |
| `encryption`, `[age]`, `[gpg]`                             | See [secrets](./secrets.md)                                |
| `[edit] command`, `args`, `apply`, `watch`                 | The editor, and applying on save                           |
| `[diff] command`, `args`, `exclude`, `pager`, `reverse`    | External diff tool, hidden entry types                     |
| `[merge] command`, `args`                                  | Three-way merge tool, `vimdiff` by default                 |
| `[status] exclude`, `[verify] exclude`                     | Entry types to leave out                                   |
| `[git] autoAdd`, `autoCommit`, `autoPush`                  | Commit (and push) the source after every change            |
| `[git] commitMessageTemplate`, `commitMessageTemplateFile` | Auto-commit message, as a template                         |
| `[update] command`, `args`, `apply`, `recurseSubmodules`   | What `update` runs                                         |
| `[add] encrypt`, `secrets`, `templateSymlinks`             | Defaults for `add`                                         |
| `[template] options`                                       | `text/template` options; default `["missingkey=error"]`    |
| `[hooks.EVENT.pre]`, `.post`                               | See [scripts and hooks](./scripts-and-hooks.md)            |
| `[interpreters.EXT]`                                       | Interpreter by script extension                            |
| `[scriptEnv]`, `[env]`                                     | Extra environment for scripts and hooks                    |
| `scriptTempDir`                                            | Where scripts are written to run, if `$TMPDIR` is `noexec` |
| `umask`                                                    | As `0o022`, to stop group-writable files                   |
| `mode`                                                     | `file`, or `symlink` for Stow-like links                   |
| `pager`, `color`, `progress`, `verbose`                    | Output                                                     |
| `useBuiltinGit`, `useBuiltinAge`                           | `auto` uses the builtin only without the binary on `PATH`  |
| `[textconv]`                                               | `pattern`, `command`: transform contents before diffing    |
| `[warnings] configFileTemplateHasChanged`                  | Silence that warning                                       |
| `[gitHub] refreshPeriod`                                   | Cache time for `gitHub*` functions                         |

`edit.command` must stay in the foreground: `code --wait`, `vim -f`.
An editor that forks leaves `chezmoi edit` with an empty buffer.

## Global flags

| Flag                                              | Effect                                                    |
| ------------------------------------------------- | --------------------------------------------------------- |
| `-n`, `--dry-run`                                 | Change nothing; with `-v`, show everything apply would do |
| `-v`, `--verbose`                                 | Print each change as a command and diff                   |
| `--debug`                                         | Trace every step                                          |
| `--force`                                         | Overwrite and remove without asking                       |
| `--interactive`, `--less-interactive`             | Ask before every target, or every changed one             |
| `--error-on-conflict`                             | Exit 1 instead of asking about a conflict, silently       |
| `--no-tty`                                        | Read answers from stdin instead of `/dev/tty`             |
| `--no-pager`, `--color=false`                     | Plain output                                              |
| `-k`, `--keep-going`                              | Carry on past errors                                      |
| `-S DIR`, `-D DIR`, `-c FILE`                     | Another source, destination, or config                    |
| `--persistent-state FILE`, `--cache DIR`          | Another state file or cache                               |
| `-R`, `--refresh-externals[=always\|auto\|never]` | Re-download externals                                     |
| `--source-path`                                   | Arguments are source paths, not targets                   |
| `--skip-secrets`                                  | Skip templates that read a secret                         |
| `--mode file\|symlink`                            | Override `mode`                                           |
| `-o FILE`                                         | Write output to a file                                    |
| `-w DIR`                                          | The git working tree, if not an ancestor of the source    |

## Common flags

Many commands take these:

- `-i TYPES`, `-x TYPES`: include or exclude entries by type, comma
  separated, `no` to negate (`scripts,noalways`). Types: `all`,
  `none`, `dirs`, `files`, `remove`, `scripts`, `symlinks`, `always`
  (scripts without `once_` or `onchange_`), `encrypted`, `externals`,
  `templates`.
- `-r`, `--recursive`: recurse, on by default for `add`, `apply`,
  `re-add`, `status`; off for `destroy`.
- `-P`, `--parent-dirs`: also act on a target's parent directories.
- `--init`: regenerate the config from its template first.
- `-p`, `--path-style`: `relative` (default), `absolute`,
  `source-relative`, `source-absolute`.
- `-f json|yaml` for `managed`, `data` and `dump`; `-t` (tree) and `-0`
  (NUL-separated) for `managed`, `unmanaged` and `ignored`.
- `--override-data JSON`, `--override-data-file FILE`: replace data.

## Commands not covered elsewhere

| Command                                                                | Does                                                                      |
| ---------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| `update`                                                               | `git pull --autostash --rebase`, then `apply`; `--apply=false` pulls only |
| `chezmoi git -- pull --autostash --rebase && chezmoi diff`             | Pull and review, without applying                                         |
| `re-add [TARGET…]`                                                     | Copy every changed non-template target back to the source                 |
| `add --follow`                                                         | Add what a symlink points to, migrating from Stow                         |
| `add --create`, `--exact`, `--template`, `--encrypt`, `--autotemplate` | Add with that attribute; review `--autotemplate`'s guesses                |
| `dump`, `archive`                                                      | The whole target state as JSON or a tarball                               |
| `generate install.sh`                                                  | A bootstrap script, as for Codespaces                                     |
| `generate git-commit-message`                                          | A message describing the source's changes                                 |
| `completion zsh`                                                       | Shell completion                                                          |
| `state dump`, `state delete-bucket`                                    | The persistent state                                                      |
| `purge`                                                                | Delete source, config and state; targets stay                             |
| `upgrade`                                                              | Replace the chezmoi binary                                                |

## Setting up a machine

```sh
chezmoi init USER                       # clones github.com/USER/dotfiles
chezmoi init --ssh USER/repo            # git@github.com:USER/repo.git
chezmoi init gitlab.com/USER --branch work
chezmoi diff && chezmoi apply           # after the user has read the diff
chezmoi init --apply USER               # clone, configure, apply in one
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply USER
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --one-shot USER
```

`USER` alone means `https://USER@github.com/USER/dotfiles.git`; `site/user/repo`
works for other hosts, and a full URL disables guessing.
`--one-shot` applies and then removes chezmoi, its source and config,
for throwaway containers. `--depth 1` makes a shallow clone.

`init` clones first, then writes the config. If a prompt fails for want
of a TTY, the clone stays: rerun `chezmoi init` with the answers, and it
reuses the clone. Run `init` again whenever `.chezmoi.$FORMAT.tmpl`
changes.

In Codespaces and devcontainers the repo is cloned for you, to
`~/dotfiles`: commit an `install.sh` from `chezmoi generate install.sh`,
list it in `.chezmoiignore`, and set
`sourceDir = {{ .chezmoi.sourceDir | quote }}` in the config template.

## Several sources, other VCSs, beyond `~`

chezmoi is built around one source and one branch. Prefer templates and
`.chezmoiignore` for variation. Where two sources are needed, run
chezmoi twice, each with its own `--source`, `--config` and
`--persistent-state`.

A VCS other than git: create the source directory yourself, with an
empty `.git` directory in it so chezmoi finds the working tree, set
`update.command` and `update.args`, and commit by hand.

chezmoi is for the home directory. For a few system files, use a
`run_onchange_` script that copies or links them with `sudo`; for more,
a configuration management tool.
