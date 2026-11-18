<!--
   -
   - ~chewygumxx/agentic-library.git
   - ::: :/skills/managing-dotfiles-with-chezmoi/references/troubleshooting.md
   -
   -->

# Troubleshooting

Start with `chezmoi doctor`: `ok` is fine, `warning` matters only for
that feature, `error` is a real problem. Then rerun the failing command
with `--debug`, or `-v` for a lighter trace.

## Errors

| Message                                                 | Cause and fix                                                                                                                         |
| ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `could not open a new TTY`                              | A prompt with no terminal. Use the non-interactive form: answers on flags, `--force` once agreed, or `--no-tty` with answers on stdin |
| `FILE has changed since chezmoi last wrote it`          | A conflict: the target was edited. `chezmoi diff FILE`, then `re-add` it or `apply --force` it                                        |
| `map has no entry for key "x"`                          | A template reads missing data. Add it to the config's `data` (often by rerunning `chezmoi init`), or guard it with `hasKey`           |
| `config file template has changed, run chezmoi init`    | `.chezmoi.$FORMAT.tmpl` changed. Run `chezmoi init`, with prompt answers if needed                                                    |
| `fork/exec /tmp/…: exec format error`                   | A templated script renders a newline before `#!`. End the first action with `-}}`                                                     |
| `fork/exec /tmp/…: permission denied`                   | `$TMPDIR` is `noexec`. Set `scriptTempDir = "~/tmp"`                                                                                  |
| `fork/exec …: no such file or directory` on Nix, Termux | A hard-coded `#!/bin/bash`. Use `#!/usr/bin/env bash`, or `#!{{ lookPath "bash" }}` in a template                                     |
| `timeout obtaining persistent state lock`               | Another chezmoi is running, often a script calling chezmoi during `apply`. Use the `CHEZMOI_*` environment instead                    |
| `mkdir …/dot_x/…: no such file or directory` on `add`   | The parent exists only through an external. Create the source directory, with a `.keep`                                               |
| `unknown flag` from `chezmoi git`                       | Put git's flags after `--`: `chezmoi git -- log -1`                                                                                   |
| `.chezmoi.stdin`: `map has no entry for key "stdin"`    | A `modify_` file named `.tmpl`. Drop the suffix; `chezmoi:modify-template` is enough                                                  |
| `error calling fromJson: EOF` in a `modify_` template   | The target does not exist yet. Pipe stdin through `default "{}"` first                                                                |
| `read /dev/stdin: permission denied`                    | chezmoi from snap. Pipe instead of redirecting, `-o FILE` for output, or install another way                                          |
| `user: lookup userid …: input/output error`             | A static musl build on an LDAP or NIS system. Use a distribution package                                                              |

## Surprises

| Symptom                                                 | Cause                                                                                  |
| ------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| A file vanished from `~` on apply                       | Its template rendered empty on this machine, or `exact_` or `.chezmoiremove` caught it |
| A file appears with a strange name, as `.private_x`     | Attributes out of order: `dot_private_x` for `private_dot_x`                           |
| `README.md` or `install.sh` appeared in `~`             | Root files are applied unless listed in `.chezmoiignore`                               |
| An ignore pattern does nothing                          | It names the source (`dot_x`); patterns match targets (`.x`)                           |
| `re-add` reported nothing and the source did not change | The source is a template, which `re-add` skips                                         |
| `run_onchange_` ran again after a rename                | Its state is keyed on name and contents; `run_once_` only on contents                  |
| A `run_once_` script never runs again after a fix       | It succeeded once with that content. Change it, or delete `scriptState`                |
| A hook ran under `--dry-run`                            | Hooks always run; scripts do not                                                       |
| `apply --error-on-conflict` exited 1 with no output     | A conflict. `chezmoi status` shows it as `MM`                                          |
| Every command is slow                                   | Large externals, or `output` calls in templates, run on every command                  |
| An external always shows as changed                     | A tool writes caches into it; ignore that path and its self-update                     |
| `~/.ssh/config` is group-writable                       | The system umask is `002`; set `umask = 0o022`                                         |
| `diff` shows escape codes                               | The pager drops colour: `LESS=-R`, `--no-pager`, or `--color=false`                    |
| `chezmoi edit` opens an empty buffer                    | The editor forked and returned; make it wait (`code --wait`, `vim -f`)                 |
| A `modify_` result gains a blank last line              | `toPrettyJson` ends in a newline, then so does the template; close with `-}}`          |
