#!/bin/false
-- vim: expandtab:shiftwidth=4:filetype=lua:

-- 
-- 
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/wezterm/keymap.lua
-- 
-- 

-- 
-- 
-- 

local wezterm = require("wezterm")
local act     = wezterm.action

local M = {}


local wezterm_intrinsic = function(cfg)
    --cfg.enable_kitty_keyboard = true -- No idea what this does

    table.insert(cfg.keys, { mods = "CTRL|SHIFT",     key = "Escape", action = act.ShowDebugOverlay    })
    table.insert(cfg.keys, { mods = "CTRL|ALT|SHIFT", key = "Escape", action = act.ReloadConfiguration })

    return cfg
end

local command_palette = function(cfg)
    cfg.command_palette_rows = 15 
    cfg.command_palette_font = cfg.font
    cfg.command_palette_font_size = 13
    cfg.command_palette_bg_color = "#03030b"
    cfg.command_palette_fg_color = "#7171d3"
    table.insert(cfg.keys, { mods = "CTRL|ALT|SHIFT", key = "P",  action = act.ActivateCommandPalette } )

    return cfg
end

local essential = function(cfg)
    local copy_if_select  = wezterm.action_callback(function(window, pane)
        if window:get_selection_text_for_pane(pane) ~= '' then
            window:perform_action(act.CopyTo('Clipboard'), pane)
            window:perform_action(act.ClearSelection, pane) 
        else
            window:perform_action(act.SendKey { mods = "CTRL", key = 'c', }, pane)
        end
    end)
    table.insert(cfg.keys, { mods = "CTRL",       key = "c", action = copy_if_select             })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT", key = "C", action = act.CopyTo("Clipboard")    })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT", key = "V", action = act.PasteFrom("Clipboard") })

    --table.insert(cfg.keys, { mods = "LEADER",     key = "J", action = act.ScrollToPrompt(1)      })
    --table.insert(cfg.keys, { mods = "LEADER",     key = "K", action = act.ScrollToPrompt(-1)     })

    table.insert(cfg.keys, { mods = "CTRL",       key = "0", action = act.ResetFontSize          })
    table.insert(cfg.keys, { mods = "CTRL",       key = "-", action = act.DecreaseFontSize       })
    table.insert(cfg.keys, { mods = "CTRL",       key = "=", action = act.IncreaseFontSize       })

    return cfg
end

local modes_copy_and_search = function(cfg)
    local activate_search = act.Search({ CaseInSensitiveString = "" })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT", key = "F",  action = activate_search  })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT", key = "X",  action = act.ActivateCopyMode })

    return cfg
end

local pane_intrinsic = function(cfg)
    cfg.pane_select_font = cfg.font
    cfg.unzoom_on_switch_pane = true

    return cfg
end

local pane_input = function(cfg)
    local split   = { domain = "CurrentPaneDomain" } -- SplitVert/Horiz
    table.insert(cfg.keys, { mods = "CTRL|SHIFT", key = ':', action = act.SplitVertical(split)   })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT", key = '"', action = act.SplitHorizontal(split) })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT", key = "Z", action = act.TogglePaneZoomState    })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT", key = "O", action = act.RotatePanes("Clockwise") })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT", key = "W", action = act.CloseCurrentPane({ confirm = true }) })

    table.insert(cfg.keys, { mods = "CTRL|SHIFT", key = "H", action = act.ActivatePaneDirection("Left" ) })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT", key = "J", action = act.ActivatePaneDirection("Down" ) })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT", key = "K", action = act.ActivatePaneDirection("Up"   ) })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT", key = "L", action = act.ActivatePaneDirection("Right") })

    table.insert(cfg.keys, { mods = "CTRL|ALT|SHIFT", key = "H", action = act.AdjustPaneSize({ "Left",  5 }) })
    table.insert(cfg.keys, { mods = "CTRL|ALT|SHIFT", key = "J", action = act.AdjustPaneSize({ "Down",  5 }) })
    table.insert(cfg.keys, { mods = "CTRL|ALT|SHIFT", key = "K", action = act.AdjustPaneSize({ "Up",    5 }) })
    table.insert(cfg.keys, { mods = "CTRL|ALT|SHIFT", key = "L", action = act.AdjustPaneSize({ "Right", 5 }) })

    local nvim_scrollback = wezterm.action_callback(function(window, pane)
        -- Read entire scrollback...
        local area = pane:get_dimensions().scrollback_rows
        local text = pane:get_lines_as_escapes(area)

        -- ... into temporary file
        local temp_file   = "/tmp/" .. os.date("%Y-%m-%d_%H-%M-%S_wezterm-scrollback.log.ansi")
        local temp_handle = io.open(temp_file, 'w+')
        temp_handle:write(text)
        temp_handle:flush()
        temp_handle:close()

        -- In new tab of current window,
        -- Invoke Neovim to open file, save a copy, then finally interpret escape codes.
        window:perform_action(act.SpawnCommandInNewTab({
            args = { 'nvim', '+XXInterpretEscape', temp_file },
        }), pane)
    end)
    table.insert(cfg.keys, { mods = "CTRL|ALT|SHIFT", key = "V",  action = nvim_scrollback })

    return cfg
end

local tab_intrinsic = function(cfg)
    cfg.tab_and_split_indices_are_zero_based = false

    return cfg
end

local tab_bar = function(cfg)
    cfg.enable_tab_bar    = true
    cfg.use_fancy_tab_bar = false
    cfg.tab_bar_at_bottom = true
    cfg.tab_max_width     = 30

    cfg.hide_tab_bar_if_only_one_tab   = true
    cfg.show_new_tab_button_in_tab_bar = false

    cfg.colors.tab_bar = {
        background = '#03030b',
        --background = '#000000',
        active_tab = {
            bg_color = '#2d2857',
            fg_color = '#7fb5ff',
            --intensity = 'Normal', -- "Half", "Normal" or "Bold"
            --underline = 'None',   -- "None", "Single" or "Souble"
            --italic = false,
            --strikethrough = false,
        },
        inactive_tab = {
            bg_color = '#090a24',
            fg_color = '#7408ff',
            --intensity = 'Normal', -- "Half", "Normal" or "Bold"
            --underline = 'None',   -- "None", "Single" or "Souble"
            --italic = false,
            --strikethrough = false,
        },
        inactive_tab_hover = {
            bg_color = '#141337',
            fg_color = '#7408ff',
            --intensity = 'Normal', -- "Half", "Normal" or "Bold"
            --underline = 'None',   -- "None", "Single" or "Souble"
            italic = true,
            --strikethrough = false,
        },
        new_tab = {
            bg_color = '#040512',
            fg_color = '#4e4581',
        },
        new_tab_hover = {
            bg_color = '#806fc0',
            fg_color = '#060616',
            --intensity = 'Normal', -- "Half", "Normal" or "Bold"
            --underline = 'None',   -- "None", "Single" or "Souble"
            --italic = false,
            --strikethrough = false,
        },
    }

    return cfg
end

local input = function(cfg)
    local rename_tab = act.PromptInputLine({
        description = 'Rename Tab',
        action = wezterm.action_callback(function(window, pane, line)
            if line then
                window:active_tab():set_title(line)
            end
        end),
    })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT",     key = "T", action = act.SpawnTab("CurrentPaneDomain") })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT",     key = "R", action = rename_tab                        })
    table.insert(cfg.keys, { mods = "CTRL|ALT|SHIFT", key = "W", action = act.CloseCurrentTab({ confirm = true }) })

    table.insert(cfg.keys, { mods = "CTRL|SHIFT",     key = "E", action = act.ShowTabNavigator              })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT",     key = "{", action = act.ActivateTabRelativeNoWrap(-1) })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT",     key = "}", action = act.ActivateTabRelativeNoWrap(1)  })
    table.insert(cfg.keys, { mods = "CTRL|ALT|SHIFT", key = "{", action = act.MoveTabRelative(-1)           })
    table.insert(cfg.keys, { mods = "CTRL|ALT|SHIFT", key = "}", action = act.MoveTabRelative(1)            })

    table.insert(cfg.keys, { mods = "CTRL|SHIFT",     key = "!", action = act.ActivateTab(0) })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT",     key = "@", action = act.ActivateTab(1) })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT",     key = "#", action = act.ActivateTab(2) })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT",     key = "$", action = act.ActivateTab(3) })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT",     key = "%", action = act.ActivateTab(4) })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT",     key = "^", action = act.ActivateTab(5) })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT",     key = "&", action = act.ActivateTab(6) })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT",     key = "*", action = act.ActivateTab(7) })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT",     key = "(", action = act.ActivateTab(8) })
    table.insert(cfg.keys, { mods = "CTRL|SHIFT",     key = ")", action = act.ActivateTab(9) })

    --for i=1,10,1 do 
    --    local key = tostring(i % 10) -- Tabs one-indexed. key = 0 -> tab 10
    --    table.insert(cfg.keys, { mods = "CTRL|SHIFT", key = key, action = act.ActivateTab(i) })
    --end

    return cfg
end

M.setup = function(cfg)
    cfg.disable_default_key_bindings = true
    cfg.keys = {}

    cfg = wezterm_intrinsic(cfg)
    cfg = command_palette(cfg)
    cfg = essential(cfg)
    cfg = modes_copy_and_search(cfg)
    cfg = pane_intrinsic(cfg)
    cfg = pane_input(cfg)
    cfg = tab_intrinsic(cfg)
    cfg = tab_bar(cfg)
    cfg = input(cfg)

    return cfg
end

return M
