---
ctime: 2026-11-06
mtime: 2026-11-06
spdx: GPL-3.0-only
title: "Conversation with ChatGPT: Yazi Plugin Spec Refactor"
description:
tags:
---

<!--
   -
   - ~chewygumxx/dotfiles.git
   - ::: :/docs/note/2026-11-06_chatgpt-conversation-yazi-plugin-spec-refactor.md
   -
   -->

# Conversation with ChatGPT: Yazi Plugin Spec Refactor

## chewygumxx Prompt 1

Please improve the following Lua code to be readable

```lua
local mux_setup = function()
    local mux_opts = {
        notify_on_switch = false,           -- Show notification when switching previews
        remember_per_file_extension = true, -- Show same previewer per extension
        aliases = {},
    }

    -- Directory
    local eza_args_extra = table.concat({
        "--all",
        "--group-directories-first",
        "--color=always",
        "--icons=always",
        "--no-quotes",
    }, " ")
    for i = 1, 3, 1 do
        mux_opts.aliases["eza_tree_" .. i] = {
            previewer = "piper",
            args = {
                table.concat({
                    "printf \"\\e[0;35mTree Level: \\e[0;32m" .. i .. "\\n\" &&",
                    "eza",
                    "--tree",
                    "--level " .. i,
                    eza_args_extra,
                    '"$1"',
                }, " "),
            },
        }
    end

    return mux_opts
end
require("mux"):setup(mux_setup())
```

---

## ChatGPT Response 1

I'd simplify this by removing the single-use function, using `string.format()`
for interpolation, and separating the shell command template from the alias
definitions.

```lua
local mux_opts = {
    notify_on_switch = false,
    remember_per_file_extension = true,
    aliases = {},
}

-- Directory preview configuration
local eza_opts = table.concat({
    "--all",
    "--group-directories-first",
    "--color=always",
    "--icons=always",
    "--no-quotes",
}, " ")

local tree_command = [[printf '\e[0;35mTree Level: \e[0;32m%d\n' && eza --tree --level=%d %s "$1"]]

-- Register tree previewers for depths 1–3
for level = 1, 3 do
    mux_opts.aliases["eza_tree_" .. level] = {
        previewer = "piper",
        args = {
            tree_command:format(level, level, eza_opts),
        },
    }
end

require("mux"):setup(mux_opts)
```

### What changed?

1. Removed `mux_setup()` — Since the function was only invoked once, it
   introduced an unnecessary level of indirection.
2. Replaced nested concatenation with `string.format()` — Separates the
   command's structure from its variable arguments.
3. Used Lua's long-string syntax (`[[...]]`) — Eliminates the need to escape
   backslashes and quotation marks within the shell command.
4. Renamed `i` to `level` — Makes the loop's purpose immediately apparent.
5. Removed the redundant loop step — `for level = 1, 3` already increments by
   one.
6. Preserved the existing behaviour — Including previewer aliases, ANSI
   colours, arguments, and per-extension preferences.

One additional consideration: if you're going to introduce more `eza`
previewers, I'd retain `eza_opts` as a separate variable. Otherwise, you could
incorporate those options directly into `tree_command` and eliminate another
layer of interpolation.

My preference is the version above: it separates configuration, command
construction, and alias registration without introducing unnecessary
abstractions.

---

## chewygumxx Prompt 2

This is my current `~/.config/yazi/init.lua` file and I would like to refactor
it such that plugin specification resembles my current [Neovim config][nvim-conf-specs]

How may I do so?

```lua
-- vim:set expandtab shiftwidth=4 filetype=lua:
-- SPDX-License-Identifier: GPL-3.0-only

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/home/dot_config/yazi/init.lua
--
--

require("smart-enter"):setup({ open_multi = true })

-- No more status bar
require("no-status"):setup()

require("zoxide"):setup({ update_db = true })

local mux_opts = {
    notify_on_switch = false,
    remember_per_file_extension = true,
    aliases = {},
}

-- Directory preview configuration
local eza_opts = table.concat({
    "--all",
    "--group-directories-first",
    "--color=always",
    "--icons=always",
    "--no-quotes",
}, " ")

local tree_command = [[printf '\e[0;35mTree Level: \e[0;32m%d\n' && eza --tree --level=%d %s "$1"]]

-- Register tree previewers for depths 1–3
for level = 1, 3 do
    mux_opts.aliases["eza_tree_" .. level] = {
        previewer = "piper",
        args = {
            tree_command:format(level, level, eza_opts),
        },
    }
end

require("mux"):setup(mux_opts)
local time_format = function(time)
    if time == 0 then
        time = ""
    elseif os.date("%Y", time) == os.date("%Y") then
        time = os.date("%d/%m %H:%M", time)
    else
        time = os.date("%d/%m  %Y", time)
    end

    return time
end

function Linemode:size_and_mtime()
    local time = math.floor(self._file.cha.mtime or 0)
    time       = time_format(time)

    local size = self._file:size()
    return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end

function Linemode:mtime()
    local time = math.floor(self._file.cha.mtime or 0)
    return time_format(time)
end

```

---

## ChatGPT Response 2

You can reproduce the architecture of your Neovim configuration quite closely,
including individual plugin specification files, a central plugin loader, and a
minimal `init.lua`.

I inspected your [Neovim plugin specifications][nvim-conf-specs] and
[`lua/plugin.lua`][nvim-conf-plugin]

Your Neovim configuration follows a useful pattern:

- `init.lua` orchestrates initialisation.
- `lua/plugin.lua` manages plugin specifications and their loading.
- `lua/spec/*.lua` contains individual plugin definitions.
- Each specification returns a table containing the plugin identifier and
  configuration.

I'd preserve that architecture for Yazi, with one important adaptation.

Yazi's `require()` is not equivalent to Neovim's `require()`. Yazi intercepts
it to load Yazi plugins, rather than arbitrary Lua modules from your
configuration directory. For ordinary Lua files, you can use `dofile()`
instead. This distinction was explicitly confirmed by Yazi's maintainer.
([\[Ref \#3\] Yazi Issue #1811][yazi-issue-1811])
([\[Ref \#4\] Yazi Docs: Plugin][yazi-doc-plugin])

That means you don't need a plugin manager like `lazy.nvim`, but you do need a
small loader to import your specifications.

### 1. Proposed directory structure

```text
~/.config/yazi/
├── init.lua
├── yazi.toml
├── keymap.toml
├── theme.toml
│
├── lua/
│   ├── plugin.lua
│   ├── linemode.lua
│   │
│   └── spec/
│       ├── smart-enter.lua
│       ├── no-status.lua
│       ├── zoxide.lua
│       └── mux.lua
│
└── plugins/
    ├── smart-enter.yazi/
    ├── no-status.yazi/
    ├── zoxide.yazi/
    └── mux.yazi/
```

The distinction between the two directories is intentional:

| Directory          | Responsibility                           |
| ------------------ | ---------------------------------------- |
| `lua/spec/`        | Your configuration for each plugin       |
| `plugins/`         | The actual Yazi plugin implementations   |
| `lua/plugin.lua`   | Specification loading and initialisation |
| `lua/linemode.lua` | Custom Yazi UI behaviour                 |
| `init.lua`         | Application initialisation entry point   |

This is almost identical to your Neovim architecture, except Yazi doesn't provide lazy.nvim's automatic specification discovery.

### 2. Refactor `init.lua`

Your entire `init.lua` can be reduced to:

```lua
-- vim:set expandtab shiftwidth=4 filetype=lua:
-- SPDX-License-Identifier: GPL-3.0-only

local config_dir = os.getenv("YAZI_CONFIG_HOME")

if not config_dir then
    local xdg_config = os.getenv("XDG_CONFIG_HOME")
        or (os.getenv("HOME") .. "/.config")

    config_dir = xdg_config .. "/yazi"
end

local function load(name)
    return dofile(config_dir .. "/lua/" .. name .. ".lua")
end

load("plugin").setup(config_dir)
load("linemode").setup()
```

This respects your XDG directory configuration and Yazi's `YAZI_CONFIG_HOME`
override, assuming those variables contain absolute paths as expected by
Yazi.
([\[Ref \#5\] Yazi Docs: Config][yazi-doc-config])

The root configuration now has two responsibilities: Load plugin specifications
and initialise custom line modes.

### 3. Create `lua/plugin.lua`

This module is analogous to your Neovim `lua/plugin.lua`.

```lua
local M = {}

M.specs = {
    "smart-enter",
    "no-status",
    "zoxide",
    "mux",
}

function M.setup(config_dir)
    for _, name in ipairs(M.specs) do
        local path = string.format("%s/lua/spec/%s.lua", config_dir, name)
        local spec = dofile(path)

        if spec.enabled ~= false then
            local plugin = require(spec[1])

            if spec.opts == nil then
                plugin:setup()
            else
                plugin:setup(spec.opts)
            end
        end
    end
end

return M
```

Each specification follows a small, consistent contract:

```lua
return {
    "plugin-name",
    enabled = true,
    opts = {},
}
```

The loader supports `enabled = false`, although it's optional. It also
distinguishes between an absent `opts` field and an empty table, preserving
your original `setup()` calls for plugins without configuration.

Unlike lazy.nvim, this loader does not install plugins, resolve dependencies,
or discover specifications automatically. `M.specs` explicitly defines both
membership and initialisation order.

### 4. Create individual plugin specifications

#### `lua/spec/smart-enter.lua`

```lua
local M = {
    "smart-enter",
    opts = {
        open_multi = true,
    },
}

return M
```

#### `lua/spec/no-status.lua`

```lua
local M = {
    "no-status",
}

return M
```

#### `lua/spec/zoxide.lua`

```lua
local M = {
    "zoxide",
    opts = {
        update_db = true,
    },
}

return M
```

#### `lua/spec/mux.lua`

This is where most of your existing configuration belongs.

```lua
local M = {
    "mux",
}

M.opts = {
    notify_on_switch = false,
    remember_per_file_extension = true,
    aliases = {},
}

-- Directory preview configuration
local eza_opts = table.concat({
    "--all",
    "--group-directories-first",
    "--color=always",
    "--icons=always",
    "--no-quotes",
}, " ")

local tree_command = [[printf '\e[0;35mTree Level: \e[0;32m%d\n' && eza --tree --level=%d %s "$1"]]

-- Register tree previewers for depths 1–3
for level = 1, 3 do
    M.opts.aliases["eza_tree_" .. level] = {
        previewer = "piper",
        args = {
            tree_command:format(level, level, eza_opts),
        },
    }
end

return M
```

This mirrors your Neovim specifications particularly well.

For example, your existing Neovim `comment.nvim.lua` uses:

```lua
local M = {
    "numToStr/Comment.nvim",
    lazy = true,
}

M.opts = {
    -- ...
}

return M
```

The same structural convention is now applied to your Yazi plugins, without
conflating the two applications' different plugin APIs.

### 5. Extract `lua/linemode.lua`

Your custom line modes aren't plugin specifications in the same sense as `mux`
or `zoxide`.

I'd therefore give them their own module, just as you've separated non-plugin
configuration in Neovim.

```lua
local M = {}

local function format_time(timestamp)
    if timestamp == 0 then
        return ""
    end

    if os.date("%Y", timestamp) == os.date("%Y") then
        return os.date("%d/%m %H:%M", timestamp)
    end

    return os.date("%d/%m  %Y", timestamp)
end

function M.setup()
    function Linemode:size_and_mtime()
        local time = format_time(math.floor(self._file.cha.mtime or 0))
        local size = self._file:size()

        return string.format(
            "%s %s",
            size and ya.readable_size(size) or "-",
            time
        )
    end

    function Linemode:mtime()
        return format_time(math.floor(self._file.cha.mtime or 0))
    end
end

return M
```

The line mode names and formatting behaviour remain unchanged. Yazi supports
registering such custom methods on `Linemode`, which can then be selected
through `yazi.toml`.
([\[Ref \#5\] Yazi Docs: `yaml.toml`][yazi-doc-yazitoml])

```toml
[mgr]
linemode = "size_and_mtime"
```

### 6. Considerations for future development

There's one architectural distinction worth keeping in mind.

Your Neovim configuration currently delegates specification importing to
lazy.nvim:

```lua
{ import = "spec" }
```

Lazy.nvim handles discovering and loading all the specification files.

Your new Yazi configuration instead declares them explicitly:

```lua
M.specs = {
    "smart-enter",
    "no-status",
    "zoxide",
    "mux",
}
```

Both approaches are perfectly reasonable.

If you later accumulate dozens of Yazi plugins, you could introduce automatic
specification discovery, where the loader enumerates the files in `lua/spec/`
and imports them.

However, I wouldn't introduce that complexity yet. It would require additional
filesystem enumeration logic, and deterministic plugin initialisation order
would need consideration.

#### An important limitation of Yazi's plugin system

Do not attempt to replace:

```lua
dofile(config_dir .. "/lua/spec/mux.lua")
```

with:

```lua
require("spec.mux")
```

Although the latter works as expected in Neovim, Yazi interprets `require()`
through its plugin loader. Yazi plugins live under `plugins/<name>.yazi/`, and
their loading semantics differ from ordinary Lua modules.
([\[Ref \#6\] GitHub: Yazi Issue \#1811][yazi-issue-1811])
([\[Ref \#7\] DeepWiki: Yazi Plugin Loading][yazi-issue-1811])

You can build a custom Lua module loader around `loadfile()` or `package.path`,
but I wouldn't do so merely to emulate Neovim's syntax. Yazi's special
`require()` behaviour makes that an unnecessary complication.

### My Recommendation

I'd adopt this exact architecture, particularly because it aligns with the
explicit modular initialisation convention already present in your Neovim
repository.

There is a subtle benefit beyond readability: Your plugin specifications become
declarative configuration, rather than executable setup scripts.

Each spec says what configuration a plugin should receive; `plugin.lua` decides
how that configuration is applied.

Consequently, changes to plugin initialisation behaviour—conditional
enablement, logging, validation, or configuration overrides—can eventually be
implemented centrally rather than duplicated across every specification.

For your current four plugins, the loader is deliberately modest. It
establishes the separation of concerns without recreating lazy.nvim inside
Yazi.

---

## References

1. [GitHub: chewygumxx/nvim-config · Plugin Specs (`lua/specs/`)][nvim-conf-specs]
2. [GitHub: chewygumxx/nvim-config · `lua/plugin.lua`][nvim-conf-plugin]
3. [Yazi Docs: Plugins (BETA)][yazi-doc-plugin]
4. [Yazi Docs: Configuration][yazi-doc-config]
5. [Yazi Docs: yazi.toml][yazi-doc-yazitoml]
6. [GitHub: sxyzi/yazi · Issue \#1811 \[Lua\] unable to import][yazi-issue-1811]
7. [DeepWiki: Yazi Plugin Loading and Package Management][yazi-plug-mgmt]

[nvim-conf-specs]: https://github.com/chewygumxx/nvim-config/tree/0f0fbf6df3ac6b462e719178891d8308320703f0/lua/spec "[GitHub Permalink] chewygumxx/nvim-config:main:db9162a · lua/spec/"
[nvim-conf-plugin]: https://github.com/chewygumxx/nvim-config/blob/0f0fbf6df3ac6b462e719178891d8308320703f0/lua/plugin.lua "[GitHub Permalink] chewygumxx/nvim-config:main:db9162a · lua/plugin.lua"
[yazi-issue-1811]: https://github.com/sxyazi/yazi/issues/1811 "GitHub: sxyazi/yazi · Issue #1811: [Lua] unable to import"
[yazi-doc-plugin]: https://yazi-rs.github.io/docs/plugins/overview/ "Plugins (BETA) | Yazi"
[yazi-doc-config]: https://yazi-rs.github.io/docs/configuration/overview/ "Configuration | Yazi"
[yazi-doc-yazitoml]: https://yazi-rs.github.io/docs/configuration/yazi/ "yazi.toml | Yazi"
[yazi-plug-mgmt]: https://deepwiki.com/sxyazi/yazi/4.2-built-in-plugins "Plugin Loading and Package Management | sxyazi/yazi | DeepWiki"

<!-- vim:set expandtab shiftwidth=2 filetype=markdown foldlevel=3: -->
