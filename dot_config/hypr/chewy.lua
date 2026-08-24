#!/bin/false
-- vim:set expandtab shiftwidth=4 filetype=lua:

-- 
-- 
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/hypr/chewy.lua
-- 
-- 

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
