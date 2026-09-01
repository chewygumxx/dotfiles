#!/bin/false
-- vim:set expandtab shiftwidth=4 filetype=lua:

-- 
-- 
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/wezterm/terminfo.lua
-- 
-- 

local wezterm = require("wezterm")

local M = {}

local TERMINFO = wezterm.home_dir .. "/.local/share/terminfo"

M.setup = function(cfg)
    cfg.term = "wezterm"

    cfg.set_environment_variables = cfg.set_environment_variables or {}
    cfg.set_environment_variables.TERMINFO = TERMINFO
    cfg.set_environment_variables.TERMINFO_DIRS = TERMINFO .. ":/usr/share/terminfo"

    return cfg
end

return M
