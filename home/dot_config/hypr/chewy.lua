-- vim:set expandtab shiftwidth=4 filetype=lua:
-- SPDX-License-Identifier: GPL-3.0-only

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/home/dot_config/hypr/chewy.lua
--
--

---@class Chewy.Browser
---@field cmd string

---@class Chewy.Terminal.Cmd
---@field base string
---@field float? string
---@field tiled? string

---@class Chewy.Terminal
---@field cmd Chewy.Terminal.Cmd

---@class Chewy.Clipman
---@field cmd string

---@class Chewy.Screenshot.Cmd
---@field all? string
---@field select? string

---@class Chewy.Screenshot
---@field destination string
---@field cmd Chewy.Screenshot.Cmd

---@class Chewy
---@field browser? Chewy.Browser
---@field terminal? Chewy.Terminal
---@field clipman? Chewy.Clipman
---@field screenshot? Chewy.Screenshot
local M = {}

M.browser = {
    cmd = "systemctl --user start firefox",
}

M.terminal = {
    cmd = { base = "wezterm start --always-new-process ", }
}
M.terminal.cmd.float = M.terminal.cmd.base .. "--class term-float"
M.terminal.cmd.tiled = M.terminal.cmd.base .. "--class term-tiled"

M.clipman = {
    cmd = M.terminal.cmd.base .. "--class cclip-fzf 'cclip-fzf'"
}

M.screenshot = {
    destination = "~/ref/image/top/screenshot/$(date +%Y-%m-%d_%H-%M-%S).screenshot.png",
    cmd = {},
}
M.screenshot.cmd.all    = "grim "                 .. M.screenshot.destination
M.screenshot.cmd.select = "grim -g \"$(slurp)\" " .. M.screenshot.destination

return M
