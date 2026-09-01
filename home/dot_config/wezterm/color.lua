#!/bin/false
-- vim: expandtab:shiftwidth=4:filetype=lua:

-- 
-- 
-- ~chewygumxx/dotfiles.git
-- ::: :/home/dot_config/wezterm/color.lua
-- 
-- 

-- 
-- 
-- 

local M = {}

M.setup = function(cfg)
    cfg.background = { {
        height   = '100%',
        width    = '100%',
        source   = { Color = "#000000" },
        opacity  = 0.8,
    } }
    
    cfg.colors = {           -- fg/bg: base, cursor, selection
        foreground = '#9493de',
        --foreground = '#a0a0d9',
        --foreground = '#b1a3e5',
        --background = '#03030b',   -- Defunct (See: cfg.background)
   
        cursor_fg = 'black',        -- Block cursor text
        cursor_bg = '#cad6ff',      -- Block cursor background
        cursor_border = '#a0a0d9',  -- Block cursor border
        
        selection_fg = 'none',      -- Preserve foreground
        selection_bg = 'rgba(116, 8, 196, 0.1)',
    }

    -----------
    -- ** ANSI
    -----------

    cfg.bold_brightens_ansi_colors = "No"
    
    cfg.colors.ansi = {     -- ANSI 0-7
        "#000000",        -- 0 Black    (dynamic background (ie. progress bars))
        "#dc143c",        -- 1 Red
        "#0fe192",        -- 2 Green
        "#c6c45e",        -- 3 Yellow
        "#5f95fa",        -- 4 Blue
        "#7408ff",        -- 5 Magenta
        "#7fc5df",        -- 6 Cyan
        "#cad6ff",        -- 7 White
    }
    
    cfg.colors.brights = {  -- ANSI 8-15
      --"#555555",        -- 08 Bright Black (Gray)
      --"#2d2857",        -- 08 Bright Black (Gray)
      --"#3d3470",        -- 08 Bright Black (Gray)
        "#4e4189",        -- 08 Bright Black (Gray)
        "#e3365e",        -- 09 Bright Red
        "#0fff72",        -- 10 Bright Green
        "#ffca44",        -- 11 Bright Yellow
        "#7fc5ff",        -- 12 Bright Blue
        "#a430ff",        -- 13 Bright Magenta
        "#8be9fd",        -- 14 Bright Cyan
        "#e8e0ff",        -- 15 Bright White
    }
    
    cfg.colors.indexed = {  -- ANSI 16-255
        --[136] = '#af8700'
    }

    return cfg
end

return M
