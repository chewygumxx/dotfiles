#!/usr/bin/env lua
-- vim:set expandtab shiftwidth=4 filetype=lua:
-- SPDX-License-Identifier: GPL-3.0-only

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/home/dot_config/wezterm/ui.lua
--
--


local M = {}

---@param  cfg Config
---@return Config cfg
local pane_intrinsic = function(cfg)
    cfg.pane_select_font = cfg.font
    cfg.unzoom_on_switch_pane = true

    return cfg
end

---@param  cfg Config
---@return Config cfg
local tab_intrinsic = function(cfg)
    cfg.tab_and_split_indices_are_zero_based = false

    return cfg
end

---@param  cfg Config
---@return Config cfg
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

---@param  cfg Config
---@return Config cfg
M.setup = function(cfg)
    cfg = pane_intrinsic(cfg)
    cfg = tab_intrinsic(cfg)
    cfg = tab_bar(cfg)

    return cfg
end

return M
