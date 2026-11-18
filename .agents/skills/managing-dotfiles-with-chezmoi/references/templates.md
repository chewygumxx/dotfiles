<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/.agents/skills/managing-dotfiles-with-chezmoi/references/templates.md
   -
   -->

# Templates

A source file is a template if its name ends `.tmpl` or it lives in
`.chezmoitemplates/`. `.chezmoiignore`, `.chezmoiremove` and
`.chezmoiexternal.$FORMAT` always are. The language is Go's
`text/template` with the sprig functions and chezmoi's own.

Make one with `chezmoi add --template ~/.gitconfig`, or
`chezmoi chattr +template ~/.gitconfig` for a managed file, or by
naming the source file `.tmpl`. Then write it in the source directory.

## Data

Later sources override earlier ones:

1. `.chezmoi.*`, set by chezmoi.
2. `.chezmoidata.$FORMAT` files and `.chezmoidata/` directories, in
   lexical order, dictionaries deep-merged, lists replaced.
3. The config file's `data` section.

`--override-data '{"k":"v"}'` and `--override-data-file FILE` override
all three for one command. Data keys start with a letter, then letters
and digits. Put shared facts (package lists, colours) in `.chezmoidata`
and per-machine facts (email, work or home) in the config's `data`.

`chezmoi data` prints it all; `chezmoi data --format=yaml` reads easier.

| Variable                                      | Value                                                                 |
| --------------------------------------------- | --------------------------------------------------------------------- |
| `.chezmoi.os`                                 | `linux`, `darwin`, `windows`, `freebsd`, …                            |
| `.chezmoi.arch`                               | `amd64`, `arm64`, …                                                   |
| `.chezmoi.hostname`                           | Up to the first `.`; `.chezmoi.fqdnHostname` in full                  |
| `.chezmoi.username`, `.uid`, `.group`, `.gid` | The user running chezmoi                                              |
| `.chezmoi.homeDir`                            | With `/` separators; `.chezmoi.rawHomeDir` native                     |
| `.chezmoi.sourceDir`, `.destDir`              | The source and destination directories                                |
| `.chezmoi.sourceFile`                         | This template, relative to the source directory                       |
| `.chezmoi.targetFile`                         | This template's target, absolute                                      |
| `.chezmoi.osRelease`                          | `/etc/os-release`, keys camel-cased, Linux only: `.id`, `.prettyName` |
| `.chezmoi.kernel`                             | `/proc/sys/kernel`, Linux only: `.osrelease`                          |
| `.chezmoi.windowsVersion`                     | Windows only: `.productName`, `.currentBuild`, …                      |
| `.chezmoi.config`                             | The parsed config file                                                |
| `.chezmoi.args`, `.flags`                     | The command line                                                      |
| `.chezmoi.version.version`                    | chezmoi's version                                                     |
| `.chezmoi.stdin`                              | In a `modify_` template, the current file                             |

WSL is `.chezmoi.os` `linux` with `microsoft` in
`.chezmoi.kernel.osrelease | lower`. On macOS `hostname` varies with the
network; use `output "scutil" "--get" "ComputerName" | trim`.

## Syntax

```text
{{- if eq .chezmoi.os "darwin" }}
export BROWSER=open
{{- else if and (eq .chezmoi.os "linux") (not .work) }}
export BROWSER=firefox
{{- end }}
[user]
    email = {{ .email | quote }}
{{ range .packages.cli }}{{ . }} {{ end }}
```

- `{{-` trims whitespace and newlines before the action, `-}}` after.
  Most layout bugs are a missing or extra dash.
- `eq` takes several values: `eq .chezmoi.os "linux" "freebsd"` is true
  for either. `and` and `or` stop at the first argument that decides
  them, whatever chezmoi's docs say, so `and (hasKey . "x") .x.y` is
  safe when `x` is missing.
- `{{ $v := … }}` declares, `{{ $v = … }}` assigns.
- A literal `{{` is `{{ "{{" }}`. A file full of them, as a Go or Helm
  template, can switch delimiters by a directive.
- `quote` for TOML and shell strings, `toJson`, `toYaml`, `toToml` for
  structure, `shellQuote` for a shell word.

### Missing keys

Indexing a key that is not there fails the whole command:
`map has no entry for key "x"`. Guard what may be absent:

```text
{{ if hasKey . "work" }}{{ if .work }}…{{ end }}{{ end }}
{{ dig "git" "signingKey" "" . }}
{{ .editor | default "vi" }}   {{/* only if .editor exists */}}
```

`dig` walks nested keys with a default and never fails. A key the
config template always writes, even as `false` or `""`, needs no guard.
Avoid `template.options = ["missingkey=zero"]`: it hides typos in every
file.

## Shared templates and whole-file switches

`.chezmoitemplates/NAME` is called as `{{ template "NAME" . }}`. Pass
`.` explicitly, or it runs with no data. Pass other values to vary it:

```text
{{- template "alacritty" dict "fontsize" 12 "font" "Mono" -}}
```

`includeTemplate "NAME" .` does the same as a function, so its result
can be piped. `include "path"` inserts a source file verbatim, relative
to the source directory. Name the included file with a leading `.` so
chezmoi does not also apply it.

When versions differ entirely:

```text
{{- if eq .chezmoi.os "darwin" -}}
{{-   include ".bashrc_darwin" -}}
{{- else -}}
{{-   template "bashrc_linux.tmpl" . -}}
{{- end -}}
```

The same contents at different paths on different systems: put them in
`.chezmoitemplates/`, call them from each path's `.tmpl`, and ignore
each path where it does not belong.

## Directives

A line containing `chezmoi:template:KEY=VALUE` sets an option for this
file and is removed before execution. Put it in a comment of the
target's language, or in `{{/* */}}`.

| Directive                                     | Effect                                                             |
| --------------------------------------------- | ------------------------------------------------------------------ |
| `left-delimiter="# [[" right-delimiter=]]`    | Other delimiters, for this file only                               |
| `missing-key=zero`                            | `error` (default), `invalid` or `zero`, for this file              |
| `encoding=utf-16-le`                          | Output encoding: `utf-8-bom`, `utf-16-be[-bom]`, `utf-16-le[-bom]` |
| `line-endings=crlf`                           | `crlf`, `lf`, `native`, or any string                              |
| `format-indent-width=4`, `format-indent="\t"` | Indent of `toJson`, `toYaml`, `toToml`                             |

## Functions

All of sprig: strings, lists, dicts (`dict`, `hasKey`, `dig`, `merge`,
`get`), defaults (`default`, `empty`, `coalesce`, `ternary`), `env`,
`sha256sum`, `now` and `date`, regular expressions. chezmoi adds:

| Function                                                                                                                                      | Returns                                                 |
| --------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| `output "cmd" "arg"…`, `outputList "cmd" list`                                                                                                | The command's stdout; fails the template if it fails    |
| `exec "cmd" "arg"…`                                                                                                                           | Whether the command succeeded, its output dropped       |
| `lookPath "cmd"`, `findExecutable "cmd" list`                                                                                                 | A path, or `""`: test for a tool before using it        |
| `stat`, `lstat`, `isExecutable`                                                                                                               | File facts, false if absent                             |
| `glob`, `globCaseInsensitive`                                                                                                                 | Matching paths, relative to the destination             |
| `include`, `includeTemplate`                                                                                                                  | A source file, raw or executed                          |
| `joinPath`                                                                                                                                    | A cleaned path in the OS's separator                    |
| `fromJson`, `fromJsonc`, `fromYaml`, `fromToml`, `fromIni`                                                                                    | Parsed data                                             |
| `toPrettyJson`, `toIni`, `toToml`, `toYaml`                                                                                                   | Serialised data, newline-terminated                     |
| `setValueAtPath "a.b" v dict`, `deleteValueAtPath`, `pruneEmptyDicts`                                                                         | An edited dict                                          |
| `jq "query" input`                                                                                                                            | A list of jq results                                    |
| `replaceAllRegex "re" "new" text`                                                                                                             | sprig's `regexReplaceAll` in pipeline order             |
| `comment "# " text`, `ensureLinePrefix`                                                                                                       | Prefixed lines                                          |
| `quoteList`, `shellQuote`, `shellQuoteList`, `toStrings`                                                                                      | Quoted values                                           |
| `encrypt`, `decrypt`                                                                                                                          | Text in the configured encryption                       |
| `gitHubKeys "user"`                                                                                                                           | `.Key`s of the user's SSH keys, for `authorized_keys`   |
| `gitHubLatestRelease`, `gitHubLatestReleaseAssetURL "o/r" "glob"`, `gitHubReleaseAssetURL`, `gitHubLatestTag`, `gitHubReleases`, `gitHubTags` | GitHub API data, anonymous unless `GITHUB_TOKEN` is set |
| `getRedirectedURL`                                                                                                                            | The final URL after redirects                           |
| `warnf`, `debugf`                                                                                                                             | `""`, printing to stderr (`debugf` under `-v`)          |
| `abortEmpty`                                                                                                                                  | Stops the whole template, rendering it empty            |
| `completion "zsh"`                                                                                                                            | chezmoi's own completion script                         |
| `mozillaInstallHash`, `ioreg`                                                                                                                 | Firefox profile hash, macOS hardware registry           |
| `stdinIsATTY`                                                                                                                                 | Whether prompting is possible                           |

`output` and `exec` run on every render: every `diff`, `status` and
`apply`. Keep them fast and side-effect free, and guard tools that may
be missing with `lookPath`. Password-manager functions are in
[secrets](./secrets.md).

## The config file template

`.chezmoi.$FORMAT.tmpl` at the source root writes the config file on
`chezmoi init`, and on any command given `--init`. It runs before the
source state is read: it sees the existing config's data and template
functions, but not `.chezmoidata` or `.chezmoitemplates`. Only here are
the `prompt*` functions available.

```text
{{- $email := promptStringOnce . "email" "Email address" -}}
{{- $work := promptBoolOnce . "work" "Work machine" false -}}
{{- $osid := .chezmoi.os -}}
{{- if hasKey .chezmoi.osRelease "id" -}}
{{-   $osid = printf "%s-%s" .chezmoi.os .chezmoi.osRelease.id -}}
{{- end -}}
encryption = "age"
[age]
    identity = "~/.config/chezmoi/key.txt"
    recipient = "age1…"
[data]
    email = {{ $email | quote }}
    work = {{ $work }}
    osid = {{ $osid | quote }}
```

- `promptString`, `promptBool`, `promptInt`, `promptChoice "p" list`,
  `promptMultichoice` always ask. Their `…Once . "key" "prompt"` forms
  ask only if `data.key` is not already set, so `init` can be re-run
  without asking again: use those.
- `exit 0` stops `init` cleanly; `writeToStdout` prints to the user.
- Where nobody can answer, as in CI, a container or a Codespace, give
  each prompt a fallback, testing `stdinIsATTY` or `env "CODESPACES"`:

  ```text
  {{- $email := "ci@example.invalid" -}}
  {{- if stdinIsATTY -}}
  {{-   $email = promptStringOnce . "email" "Email address" -}}
  {{- end -}}
  ```

- Once the template changes, every command warns
  `config file template has changed`; run `chezmoi init` to regenerate.
  Until then the old config's data is used, and a key the new template
  adds is missing.

## Testing

```sh
chezmoi execute-template '{{ .chezmoi.os }}/{{ .chezmoi.arch }}'
chezmoi execute-template < "$(chezmoi source-path ~/.gitconfig)"
chezmoi cat ~/.gitconfig
chezmoi execute-template --init --promptString 'Email address=a@b.c' \
  --promptBool 'Work machine=true' < "$(chezmoi source-path)/.chezmoi.toml.tmpl"
printf 'a = 1\n' | chezmoi execute-template --with-stdin \
  '{{ .chezmoi.stdin | fromToml | setValueAtPath "b" 2 | toToml }}'
```

`cat` renders a target as `apply` would; `execute-template` renders text
with this machine's data. A prompt that `--init` was not given an answer
for returns the prompt text, or false, or zero, without asking. Try the
other machine's data with `--override-data`.
