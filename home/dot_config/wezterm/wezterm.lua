-- vim:set expandtab shiftwidth=4 filetype=lua:

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/home/dot_config/wezterm/wezterm.lua
--
--

local wezterm = require('wezterm')

local require_guard = function(modpath)
    local ok, module = pcall(require, modpath)
    if not ok then
        wezterm.log_error("Failed to require() module: " .. modpath)
        return
    end
    return module
end

local cfg = wezterm.config_builder()

cfg.enable_wayland = true
cfg.check_for_updates = false
cfg.debug_key_events = false
cfg.automatically_reload_config = false

local setup = function(cfg)
    local terminfo = require_guard("terminfo")
    if terminfo and terminfo.setup then
        cfg = terminfo.setup(cfg)
    end

    local window = require_guard("window")
    if window and window.setup then
        cfg = window.setup(cfg)
    end

    local font = require_guard("font")
    if font and font.setup then
        cfg = font.setup(cfg)
    end

    local color = require_guard("color")
    if color and color.setup then
        cfg = color.setup(cfg)
    end

    -- Dependent upon cfg.font
    local keymap = require_guard("keymap")
    if keymap and keymap.setup then
        cfg = keymap.setup(cfg)
    end

    return cfg
end

return setup(cfg)

