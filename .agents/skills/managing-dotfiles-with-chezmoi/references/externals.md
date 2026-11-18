<!--
   -
   - ~chewygumxx/agentic-library.git
   - ::: :/skills/managing-dotfiles-with-chezmoi/references/externals.md
   -
   -->

# Externals

`.chezmoiexternal.$FORMAT`, anywhere in the source state, declares files
and archives fetched from elsewhere and treated as if they were in the
source. Each key is a target path relative to the file's own directory.
It is always a template, so URLs can follow the machine.

```toml
[".oh-my-zsh"]
    type = "archive"
    url = "https://github.com/ohmyzsh/ohmyzsh/archive/master.tar.gz"
    exact = true
    stripComponents = 1
    refreshPeriod = "168h"
[".oh-my-zsh/custom/themes/powerlevel10k"]
    type = "archive"
    url = "https://github.com/romkatv/powerlevel10k/archive/v1.15.0.tar.gz"
    exact = true
    stripComponents = 1
[".vim/autoload/plug.vim"]
    type = "file"
    url = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    refreshPeriod = "168h"
[".local/bin/age"]
    type = "archive-file"
    url = "https://github.com/FiloSottile/age/releases/download/v1.1.1/age-v1.1.1-{{ .chezmoi.os }}-{{ .chezmoi.arch }}.tar.gz"
    path = "age/age"
    executable = true
[".config/nvim/pack/plugins/start/chezmoi.vim"]
    type = "git-repo"
    url = "https://github.com/alker0/chezmoi.vim.git"
    refreshPeriod = "168h"
    [".config/nvim/pack/plugins/start/chezmoi.vim".pull]
        args = ["--ff-only"]
```

`.chezmoiexternals/` holds several such files, all read as if at the
source root, though externals of its subdirectories are not supported.
Externals in an ignored directory are ignored.

## Types

| `type`         | Target                                                                      |
| -------------- | --------------------------------------------------------------------------- |
| `file`         | A file with the URL's contents                                              |
| `archive`      | A directory of the archive's contents                                       |
| `archive-file` | One member, `path`, of the archive, as a file or symlink                    |
| `git-repo`     | `git clone`, then `git pull`; git owns the directory, chezmoi only runs git |

- Archives may be `tar`, `tar.gz`/`tgz`, `tar.bz2`/`tbz2`, `xz`,
  `tar.zst` or `zip`, guessed from the URL and then the contents, or set
  by `format`. A compressed single file takes `decompress`: `gzip`,
  `bzip2`, `xz`, `zstd`.
- `path` and `include` match names inside the archive: list them with
  `tar tzf`. `path = "zellij"` does not match `./zellij`.
- A `git-repo` needs a `git` binary, private repos need an SSH URL, and
  its contents appear in neither `diff` nor `dump`, but in `unmanaged`.
  To manage extra files inside one, use an `archive` of the branch.

## Fields

| Field                                            | Use                                                                    |
| ------------------------------------------------ | ---------------------------------------------------------------------- |
| `url`, `urls`                                    | `https://`, `http://` or `file://`; `urls` tried in order              |
| `refreshPeriod`                                  | Re-download after this long: `24h`, `168h`; default never              |
| `stripComponents`                                | Leading path components to drop from archive members                   |
| `include`, `exclude`                             | Archive member patterns; an `exclude` match wins                       |
| `exact`                                          | Delete files in the target that the archive lacks                      |
| `executable`, `private`, `readonly`              | The attributes, for the file or directory                              |
| `encrypted`                                      | The download is encrypted with the configured method                   |
| `checksum.sha256`, `.sha384`, `.sha512`, `.size` | Verify the download                                                    |
| `filter.command`, `filter.args`                  | Pipe the download through a command first                              |
| `targetPath`                                     | Target path when the key is only a name; several entries may share one |
| `clone.args`, `pull.args`                        | Extra `git clone` and `git pull` arguments                             |
| `archive.extractAppleDouble`                     | Keep macOS `._` files; default false                                   |

`file` and `archive` downloads are cached in `~/.cache/chezmoi`.
Pin a version in the URL and add a `checksum.sha256` for anything that
runs; use `refreshPeriod` for moving branches. `-R` (`--refresh-externals`)
re-downloads everything now; `-R=never` uses only the cache, for
working offline.

- Externals are checked on every `diff`, `apply` and `verify`, so large
  ones make every command slow. Unpack big archives once from a
  `run_onchange_` script instead.
- A tool that writes caches into an external's directory makes it show
  as changed: ignore the cache path, as `.oh-my-zsh/cache/**`, and turn
  off the tool's own self-update.
- `chezmoi add` fails with `mkdir …: no such file or directory` on a
  file in a directory only an external creates. Make the source
  directory and a `.keep` in it first:
  `mkdir -p "$(chezmoi source-path)/dot_config"`, then `touch` its `.keep`.
- `managed --include externals` lists what externals provide.

## Submodules and imports

A git submodule in the source directory is read as source state, so a
file in it named `run_test.sh` becomes a script. Give the submodule's
directory the `external_` attribute, which stops attribute parsing below
it. `init` and `update` recurse into submodules unless
`--recurse-submodules=false` or `update.recurseSubmodules = false`.

`chezmoi import --destination ~/.oh-my-zsh --strip-components 1
--exact --remove-destination archive.tar.gz` copies an archive into the
source state once, as files you then own and commit, where an external
would keep fetching it.
