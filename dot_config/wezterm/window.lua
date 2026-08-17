#!/bin/false
-- vim: expandtab:shiftwidth=4:filetype=lua:

-- 
-- 
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/wezterm/window.lua
-- 
-- 

-- 
-- 
-- 

local M = {}

M.setup = function(cfg)
    -- Vulkan GPU Acceleration, *Essential*
    cfg.front_end = 'WebGpu'   

    -- When shell program spawned from terminal
    cfg.exit_behavior = "Close"

    cfg.window_close_confirmation = "NeverPrompt"

    cfg.detect_password_input = true
    cfg.cursor_blink_ease_in  = 'Linear'
    cfg.cursor_blink_ease_out = 'Linear'
    cfg.cursor_blink_rate = 2000

    cfg.window_decorations = 'NONE'
    cfg.window_padding     = {
        left   = '6px',
        right  = '6px',
        top    = '7px',
        bottom = '0px'
    }

    return cfg
end

return M
