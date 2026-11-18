<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/.agents/skills/managing-dotfiles-with-chezmoi/references/secrets.md
   -
   -->

# Secrets and encryption

A dotfiles repo can stay public if no secret is ever written into it.
There are four places a secret may live instead, best first:

1. **A password manager**, read by a template function at apply time.
2. **The local config file's `data`**, which never leaves the machine;
   keep it mode `0600`.
3. **The system keyring**, through `keyring`.
4. **An encrypted file** in the repo, `encrypted_`, with age or gpg.

## Handling secrets as an agent

- `chezmoi diff`, `cat`, `dump`, `archive` and `execute-template` print
  rendered contents, decrypted files and password-manager values
  included. Keep such output out of the conversation: add
  `--exclude=encrypted`, check a templated secret by its shape
  (`chezmoi cat FILE | wc -c`), or ask the user to look.
- `chezmoi data` and `cat-config` print the config's `data`, which may
  hold secrets.
- `chezmoi add` scans for secrets but only **warns**, adding the file
  anyway with exit 0. Pass `--secrets=error`, or set
  `add.secrets = "error"`, and when it fires, template the value out or
  add the file with `--encrypt`.
- Before any commit, read `chezmoi git -- diff --cached` for plaintext
  secrets. Never set `git.autoPush` on the user's behalf.
- `--skip-secrets` skips templates that call a secret function, for
  commands run where no password manager is unlocked.

## Password managers

Each function calls the manager's CLI, which must be installed and
signed in, and caches the answer for the rest of the command.

| Manager             | Function, typical use                                                                                                                    |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| 1Password (`op`)    | `onepasswordRead "op://vault/item/field"`; `onepassword "uuid"`, `onepasswordItemFields`, `onepasswordDocument`                          |
| Bitwarden (`bw`)    | `(bitwarden "item" "ID").login.password`; `(bitwardenFields "item" "ID").token.value`; `bitwardenAttachment`; `bitwardenSecrets` (`bws`) |
| rbw                 | `(rbw "name").data.password`, `rbwFields`                                                                                                |
| pass, passage       | `pass "path"` (first line); `passFields`, `passRaw`                                                                                      |
| gopass              | `gopass "path"`, `gopassRaw`, `gopassCat`                                                                                                |
| KeePassXC           | `(keepassxc "entry").Password`; `keepassxcAttribute "entry" "attr"`; set `keepassxc.database`                                            |
| LastPass (`lpass`)  | `(index (lastpass "id") 0).password`, `lastpassRaw`                                                                                      |
| HashiCorp Vault     | `(vault "secret/path").data.data.password`                                                                                               |
| AWS Secrets Manager | `awsSecretsManager "arn"` (JSON), `awsSecretsManagerRaw`                                                                                 |
| Azure Key Vault     | `azureKeyVault "name" ["vault"]`                                                                                                         |
| Doppler             | `doppler "KEY" ["project" ["config"]]`, `dopplerProjectJson`                                                                             |
| Dashlane (`dcli`)   | `dashlanePassword "filter"`, `dashlaneNote`                                                                                              |
| Keeper              | `keeper "uid"`, `keeperFindPassword`, `keeperDataFields`                                                                                 |
| Proton Pass         | `protonPass "uri"`, `protonPassJSON`, `protonPassAttachment`                                                                             |
| passhole (`ph`)     | `passhole "path" "field"`                                                                                                                |
| ejson               | `ejsonDecrypt "file"`, `ejsonDecryptWithKey`                                                                                             |
| Keyring             | `keyring "service" "user"`; set it with `chezmoi secret keyring set --service=S --user=U`                                                |
| Any other CLI       | Set `secret.command`; `secret "arg"…` (text), `secretJSON "arg"…` (parsed)                                                               |

Each manager's command and options are config variables, as
`[onepassword] command = "op"`, `[keepassxc] database = "…"`. The full
signatures are in chezmoi's reference, under
`https://www.chezmoi.io/reference/templates/`.

```text
export CF_API_TOKEN={{ onepasswordRead "op://Personal/cloudflare/token" | quote }}
[github]
    token = {{ keyring "github" .github.user | quote }}
```

A file stored whole in the manager comes back with
`{{- onepasswordDocument "uuid" -}}` or `bitwardenAttachment`.

Install the manager on a new machine from a `read-source-state.pre`
hook, which runs before any template does; see
[scripts and hooks](./scripts-and-hooks.md).

## Encryption

`chezmoi add --encrypt FILE` stores the file encrypted, as
`encrypted_…age` or `…asc`; `chezmoi edit` decrypts and re-encrypts it
around the editor, and `apply` decrypts into the target. For an agent,
`chezmoi decrypt` and `chezmoi encrypt` read stdin, so an encrypted
source can be changed without an editor:

```sh
chezmoi decrypt < "$(chezmoi source-path ~/.netrc)" > "$tmp"
# edit "$tmp"
chezmoi encrypt < "$tmp" > "$(chezmoi source-path ~/.netrc)" && rm -f "$tmp"
```

### age

```toml
encryption = "age"                 # top level, before any [section]
[age]
    identity = "~/.config/chezmoi/key.txt"
    recipient = "age1…"            # or recipients = [...], recipientsFile
```

`chezmoi age-keygen --output=~/.config/chezmoi/key.txt` writes a key
whose `# public key:` comment is the recipient. chezmoi's builtin age
is used when no `age` binary is on `PATH` (`useBuiltinAge`); it supports
neither passphrases, symmetric mode nor SSH keys. `age.passphrase = true`
prompts on every command that decrypts, `status` and `diff` included.

To be asked for a passphrase only once per machine, commit the identity
itself passphrase-encrypted and decrypt it on first apply:

```sh
chezmoi cd   # or work in "$(chezmoi source-path)"
chezmoi age-keygen | chezmoi age encrypt --passphrase --output=key.txt.age
echo key.txt.age >> .chezmoiignore
```

```sh
#!/bin/sh
# run_onchange_before_decrypt-private-key.sh.tmpl
if [ ! -f "${HOME}/.config/chezmoi/key.txt" ]; then
    mkdir -p "${HOME}/.config/chezmoi"
    chezmoi age decrypt --output "${HOME}/.config/chezmoi/key.txt" \
        --passphrase "{{ .chezmoi.sourceDir }}/key.txt.age"
    chmod 600 "${HOME}/.config/chezmoi/key.txt"
fi
```

That script calls chezmoi while `apply` holds its lock, which works
because chezmoi's `decrypt` and `age` commands do not take it.

### gpg

```toml
encryption = "gpg"
[gpg]
    recipient = "KEYID"            # or symmetric = true
    args = ["--quiet"]
```

### transcrypt and git-crypt

`encryption = "transparent"`: git encrypts on commit, and chezmoi sees
plaintext. Map `encrypted_* filter=crypt diff=crypt merge=crypt` in the
repo's `.gitattributes`.

### Re-encrypting

To rotate a key or move from gpg to age: apply everything, change the
config, then for each file in
`chezmoi managed --include encrypted --path-style absolute`,
`chezmoi forget --force FILE` and `chezmoi add --encrypt FILE`.
`chezmoi re-add --re-encrypt` re-encrypts the files it re-adds.
