#!/bin/false
-- vim: expandtab:shiftwidth=4:filetype=lua:

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/home/dot_config/wezterm/font.lua
--
--

local wezterm = require("wezterm") ---@type Wezterm

local M = {}

---@param cfg Config
---@return Config cfg
M.setup = function(cfg)
    cfg.font = wezterm.font_with_fallback({
        "AnonymicePro Nerd Font Propo",
        "Noto Sans Symbols 2",
        "Noto Sans Math",
    })
    -- pt
    cfg.font_size   = 11
    cfg.line_height = 1.1
    cfg.font_dirs   = { os.getenv("HOME") .. "/ref/font" }
    -- Optimisation Attempt, may break intolerably
    cfg.font_locator = "ConfigDirsOnly"

    cfg.anti_alias_custom_block_glyphs = true

    return cfg
end

return M
