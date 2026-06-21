-- vim: textwidth=0:foldlevel=0

--
--
-- ~/.config/wezterm/wezterm.lua
--    
--

--
--    ( ( Lua5.4 ) )
--

-- *******************
--
--    DEBUG OVERLAY: Ctrl+Shift+Escape
--
--    Access to internal debug Lua REPL where invokation of the following will
--    return a pretty-printed Lua table.
--
--    print(wezterm.color.get_default_colors())
--
-- *******************

local wezterm = require('wezterm')
local M       = wezterm.config_builder()

local intrinsic = function()
    M.automatically_reload_config = false
    M.check_for_updates = false
    M.term = "wezterm"
end

local window = function()
    M.enable_wayland = true
    M.front_end      = 'WebGpu'    -- Vulkan GPU Acceleration, *Essential*

    M.exit_behavior             = "CloseOnCleanExit" -- When shell program spawned from terminal
  --M.exit_behavior             = "Close"            -- When shell program spawned from terminal

    M.window_close_confirmation = "AlwaysPrompt"
  --M.window_close_confirmation = "NeverPrompt"
    M.skip_close_confirmation_for_processes_named = {
        'zsh',
        'fzf-cclip',
        'yazi',       -- For termfilechooser 
    }

    M.detect_password_input = true
  --M.default_cursor_style  = 'BlinkingUnderline' -- Pretty sure zsh vi mode is overriding this.
    M.cursor_blink_ease_in  = 'Linear'
    M.cursor_blink_ease_out = 'Linear'
    M.cursor_blink_rate = 2000

    M.window_decorations = 'NONE'
    M.window_padding     = {
        left   = '6px',
        right  = '6px',
        top    = '7px',
        bottom = '0px'
    }
end

local theme = {
    font  = function()
        M.font         = wezterm.font_with_fallback({
            "AnonymicePro Nerd Font Mono",
            "Noto Sans Symbols 2",
            "Noto Sans Math"
        })
        M.font_size    = 11 -- pt
        M.font_dirs    = { os.getenv("HOME") .. '/ref/font' }
        M.font_locator = 'ConfigDirsOnly' -- Optomisation Attempt, may break intolerably 
        M.line_height  = 1.1

        M.anti_alias_custom_block_glyphs = true
    end,
    color = function()
        M.background = { {
            height   = '100%',
            width    = '100%',
            source   = { Color = "#000000" },
            opacity  = 0.8,
        } }
        
        M.bold_brightens_ansi_colors = "No"
        M.colors = {
            --foreground = '#a0a0d9',
            --foreground = '#b1a3e5',
            foreground = '#9493de',
            --background = '#03030b',    -- Ignored. See in-file variable: M.background
       
            -- ** Cursor
        
            -- Overrides the cell background color when the current cell is occupied by the
            -- cursor and the cursor style is set to Block
            cursor_bg = '#cad6ff',
            -- Overrides the text color when the current cell is occupied by the cursor
            cursor_fg = 'black',
            -- Specifies the border color of the cursor when the cursor style is set to Block,
            -- or the color of the vertical or horizontal bar when the cursor style is set to
            -- Bar or Underline.
            cursor_border = '#a0a0d9',
        
            
            -- ** Selection
            -- The only color variables that respect the alpha in rgba(), hsla(), hwb() and hsv()
            selection_fg = 'none',    -- Preserve foreground colour
            selection_bg = 'rgba(116, 8, 196, 0.1)',
        }
        -- ANSI 0-7
        M.colors.ansi = {            
            "#000000",        --0 Black (also sets background of dynamic characters (progress bars))
            "#dc143c",        --1 Red
            "#0fe192",        --2 Green
            "#c6c45e",        --3 Yellow
            "#5f95fa",        --4 Blue
            "#7408ff",        --5 Magenta
            "#7fc5df",        --6 Cyan
            "#cad6ff",        --7 White
        }
        -- ANSI 8-15
        M.colors.brights = {
          --"#555555",        --08 Bright Black (Gray)
          --"#2d2857",        --08 Bright Black (Gray)
          --"#3d3470",        --08 Bright Black (Gray)
            "#4e4189",        --08 Bright Black (Gray)
            "#e3365e",        --09 Bright Red
            "#0fff72",        --10 Bright Green
            "#ffca44",        --11 Bright Yellow
            "#7fc5ff",        --12 Bright Blue
            "#a430ff",        --13 Bright Magenta
            "#8be9fd",        --14 Bright Cyan
            "#e8e0ff",        --15 Bright White
        }
        -- ANSI 16-255
      --M.colors.indexed = { [136] = '#af8700' },
    end,
}

M.keys = {}
local act     = wezterm.action
local act_cb  = wezterm.action_callback
local keymap  = function(map) table.insert(M.keys, map) end
local input = {
    wezterm_debug_keys  = function()
        M.debug_key_events = true
    end,
    wezterm_intrinsic = function()
        M.disable_default_key_bindings = true
      --M.enable_kitty_keyboard = true -- No idea what this does

        keymap({ mods = "CTRL|SHIFT",     key = "Escape", action = act.ShowDebugOverlay    })
        keymap({ mods = "CTRL|ALT|SHIFT", key = "Escape", action = act.ReloadConfiguration })

        M.command_palette_rows = 15 
        M.command_palette_font = M.font
        M.command_palette_font_size = 13
        M.command_palette_bg_color = "#03030b"
        M.command_palette_fg_color = "#7171d3"
        keymap({ mods = "CTRL|ALT|SHIFT", key = "P",  action = act.ActivateCommandPalette } )
    end,

    essential = function()
        local copy_if_select  = wezterm.action_callback(function(window, pane)
            if window:get_selection_text_for_pane(pane) ~= '' then
                window:perform_action(act.CopyTo('Clipboard'), pane)
                window:perform_action(act.ClearSelection, pane) 
            else
                window:perform_action(act.SendKey { mods = "CTRL", key = 'c', }, pane)
            end
        end)
        keymap({ mods = "CTRL",       key = "c", action = copy_if_select             })
        keymap({ mods = "CTRL|SHIFT", key = "C", action = act.CopyTo("Clipboard")    })
        keymap({ mods = "CTRL|SHIFT", key = "V", action = act.PasteFrom("Clipboard") })

      --keymap({ mods = "LEADER",     key = "J", action = act.ScrollToPrompt(1)      })
      --keymap({ mods = "LEADER",     key = "K", action = act.ScrollToPrompt(-1)     })

        keymap({ mods = "CTRL",       key = "0", action = act.ResetFontSize          })
        keymap({ mods = "CTRL",       key = "-", action = act.DecreaseFontSize       })
        keymap({ mods = "CTRL",       key = "=", action = act.IncreaseFontSize       })
    end,
    
    modes_copy_and_search = function()
        local activate_search = act.Search({ CaseInSensitiveString = "" })
        keymap({ mods = "CTRL|SHIFT", key = "F",  action = activate_search  })
        keymap({ mods = "CTRL|SHIFT", key = "X",  action = act.ActivateCopyMode })
    end,
}
local pane = {
    intrinsic = function()
        M.pane_select_font = M.font
        M.unzoom_on_switch_pane = true
    end,
    input = function()
        local split   = { domain = "CurrentPaneDomain" } -- SplitVert/Horiz
        keymap({ mods = "CTRL|SHIFT", key = ':', action = act.SplitVertical(split)   })
        keymap({ mods = "CTRL|SHIFT", key = '"', action = act.SplitHorizontal(split) })
        keymap({ mods = "CTRL|SHIFT", key = "Z", action = act.TogglePaneZoomState    })
        keymap({ mods = "CTRL|SHIFT", key = "O", action = act.RotatePanes("Clockwise") })
        keymap({ mods = "CTRL|SHIFT", key = "W", action = act.CloseCurrentPane({ confirm = true }) })

        keymap({ mods = "CTRL|SHIFT", key = "H", action = act.ActivatePaneDirection("Left" ) })
        keymap({ mods = "CTRL|SHIFT", key = "J", action = act.ActivatePaneDirection("Down" ) })
        keymap({ mods = "CTRL|SHIFT", key = "K", action = act.ActivatePaneDirection("Up"   ) })
        keymap({ mods = "CTRL|SHIFT", key = "L", action = act.ActivatePaneDirection("Right") })

        keymap({ mods = "CTRL|ALT|SHIFT", key = "H", action = act.AdjustPaneSize({ "Left",  5 }) })
        keymap({ mods = "CTRL|ALT|SHIFT", key = "J", action = act.AdjustPaneSize({ "Down",  5 }) })
        keymap({ mods = "CTRL|ALT|SHIFT", key = "K", action = act.AdjustPaneSize({ "Up",    5 }) })
        keymap({ mods = "CTRL|ALT|SHIFT", key = "L", action = act.AdjustPaneSize({ "Right", 5 }) })

        local nvim_scrollback = wezterm.action_callback(function(window, pane)
            -- Read entire scrollback...
            local area = pane:get_dimensions().scrollback_row
            local text = pane:get_lines_as_escapes(scrollback_area)
            
            -- ... into temporary file
            local temp_file   = "/tmp/" .. os.date("%Y-%m-%d-%H-%M-%S-wezterm-scrollback.log.ansi")
            local temp_handle = io.open(temp_file, 'w+')
            temp_handle:write(text)
            temp_handle:flush()
            temp_handle:close()
            
            -- In new tab of current window,
            -- Invoke Neovim to open file, save a copy, then finally interpret escape codes.
            window:perform_action(act.SpawnCommandInNewTab({
                args = { 'nvim', '+CGInterpretEscape', temp_file },
            }), pane)
        end)
        keymap({ mods = "CTRL|ALT|SHIFT", key = "V",  action = nvim_scrollback })
    end,
}
local tab = {
    intrinsic = function()
        M.tab_and_split_indices_are_zero_based = false
    end,
    bar = function()
        M.enable_tab_bar    = true
        M.use_fancy_tab_bar = false
        M.tab_bar_at_bottom = true
        M.tab_max_width     = 30

        M.hide_tab_bar_if_only_one_tab   = true
        M.show_new_tab_button_in_tab_bar = false

        M.colors.tab_bar = {
            background = '#03030b',
          --background = '#000000',
            active_tab = {
                bg_color = '#2d2857',
                fg_color = '#7fb5ff',
              --intensity = 'Normal', -- "Half", "Normal" or "Bold"    (Default: "Normal")
              --underline = 'None',   -- "None", "Single" or "Souble"  (Default: "None")
              --italic = false,
              --strikethrough = false,
            },
            inactive_tab = {
                bg_color = '#090a24',
                fg_color = '#7408ff',
              --intensity = 'Normal', -- "Half", "Normal" or "Bold"    (Default: "Normal")
              --underline = 'None',   -- "None", "Single" or "Souble"  (Default: "None")
              --italic = false,
              --strikethrough = false,
            },
            inactive_tab_hover = {
                bg_color = '#141337',
                fg_color = '#7408ff',
              --intensity = 'Normal', -- "Half", "Normal" or "Bold"    (Default: "Normal")
              --underline = 'None',   -- "None", "Single" or "Souble"  (Default: "None")
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
              --intensity = 'Normal', -- "Half", "Normal" or "Bold"    (Default: "Normal")
              --underline = 'None',   -- "None", "Single" or "Souble"  (Default: "None")
              --italic = false,
              --strikethrough = false,
            },
        }
    end,
    input = function()
        local rename_tab      = act.PromptInputLine({
            description = 'Rename Tab',
            action = wezterm.action_callback(function(window, pane, line)
                if line then
                    window:active_tab():set_title(line)
                end
            end),
        })
        keymap({ mods = "CTRL|SHIFT",     key = "T", action = act.SpawnTab("CurrentPaneDomain") })
        keymap({ mods = "CTRL|SHIFT",     key = "R", action = rename_tab                        })
        keymap({ mods = "CTRL|ALT|SHIFT", key = "W", action = act.CloseCurrentTab({ confirm = true }) })

        keymap({ mods = "CTRL|SHIFT",     key = "E", action = act.ShowTabNavigator              })
        keymap({ mods = "CTRL|SHIFT",     key = "{", action = act.ActivateTabRelativeNoWrap(-1) })
        keymap({ mods = "CTRL|SHIFT",     key = "}", action = act.ActivateTabRelativeNoWrap(1)  })
        keymap({ mods = "CTRL|ALT|SHIFT", key = "{", action = act.MoveTabRelative(-1)           })
        keymap({ mods = "CTRL|ALT|SHIFT", key = "}", action = act.MoveTabRelative(1)            })

        keymap({ mods = "CTRL|SHIFT",     key = "!", action = act.ActivateTab(0) })
        keymap({ mods = "CTRL|SHIFT",     key = "@", action = act.ActivateTab(1) })
        keymap({ mods = "CTRL|SHIFT",     key = "#", action = act.ActivateTab(2) })
        keymap({ mods = "CTRL|SHIFT",     key = "$", action = act.ActivateTab(3) })
        keymap({ mods = "CTRL|SHIFT",     key = "%", action = act.ActivateTab(4) })
        keymap({ mods = "CTRL|SHIFT",     key = "^", action = act.ActivateTab(5) })
        keymap({ mods = "CTRL|SHIFT",     key = "&", action = act.ActivateTab(6) })
        keymap({ mods = "CTRL|SHIFT",     key = "*", action = act.ActivateTab(7) })
        keymap({ mods = "CTRL|SHIFT",     key = "(", action = act.ActivateTab(8) })
        keymap({ mods = "CTRL|SHIFT",     key = ")", action = act.ActivateTab(9) })

      --for i=1,10,1 do 
      --    local key = tostring(i % 10) -- Tabs one-indexed. key = 0 -> tab 10
      --    keymap({ mods = "CTRL|SHIFT", key = key, action = act.ActivateTab(i) })
      --end
    end,
}

local setup = function()
    intrinsic()

    window()

    theme.font()
    theme.color()

  --input.wezterm_debug_keys()
    input.wezterm_intrinsic()
    input.essential()
    input.modes_copy_and_search()

    pane.intrinsic()
    pane.input()

    tab.intrinsic()
    tab.bar()
    tab.input()
end
setup()

--wezterm.on('chewy-emit',function(window, pane) 
--    wezterm.log_info("hello", pane:get_foreground_process_name())
--    window:set_right_status("test")
--end)
--keymap({ mods = "CTRL|SHIFT", key = "Q", action = act.EmitEvent('chewy-emit') })

return M

