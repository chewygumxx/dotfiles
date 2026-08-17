#!/usr/bin/env lua
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
    cfg.front_end      = 'WebGpu'   

    -- When shell program spawned from terminal
    cfg.exit_behavior   = "Close"
    --cfg.exit_behavior = "CloseOnCleanExit" 

    --cfg.window_close_confirmation = "AlwaysPrompt"
    cfg.window_close_confirmation   = "NeverPrompt"
    cfg.skip_close_confirmation_for_processes_named = {
        'zsh',
        'fzf-cclip',
        'yazi',       -- For termfilechooser 
    }

    cfg.detect_password_input = true
  --cfg.default_cursor_style  = 'BlinkingUnderline'
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
