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
