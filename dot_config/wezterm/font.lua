#!/bin/false
-- vim: expandtab:shiftwidth=4:filetype=lua:

-- 
-- 
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/wezterm/font.lua
-- 
-- 

-- 
-- 
-- 

local wezterm = require("wezterm")

local M = {}

M.setup = function(cfg)
    cfg.font   = wezterm.font_with_fallback({
        "AnonymicePro Nerd Font Propo",
        "Noto Sans Symbols 2",
        "Noto Sans Math"
    })
    cfg.font_size    = 11 -- pt
    cfg.line_height  = 1.1
    cfg.font_dirs    = { os.getenv("HOME") .. '/ref/font' }
    cfg.font_locator = 'ConfigDirsOnly' -- Optomisation Attempt, may break intolerably 

    cfg.anti_alias_custom_block_glyphs = true

    return cfg
end

return M
