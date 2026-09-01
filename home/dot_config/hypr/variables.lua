-- vim: expandtab:shiftwidth=4

--
--
-- ~/.config/hypr/variables.lua
--
--

--
-- Hyprland Variables
--     
--     Listed in the order outlined in https://wiki.hypr.land/Configuring/Basics/Variables/
--

local M = { cfg = {} }

M.cfg.general = {
    layout = "master",

    border_size = 2,
    gaps_in    = 5,  -- Between windows
    gaps_out   = 20, -- Between monitor edge
    float_gaps = 30, -- Between monitor edge and floating window

    col = {
        active_border	= { colors = { "rgba(7fb5ffee)", "rgba(8874edee)" }, angle = 45, },
        inactive_border	= { colors = { "rgba(8d53e5aa)", "rgba(7408c4aa)" }, angle = 45, },
    },

    -- Click-and-Drag border resize
    resize_on_border = false,

    -- Low latency gaming or some shit, GPU dependant
    -- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/
    allow_tearing    = false,
}

M.cfg.decoration = {
    -- Window border radius
    rounding = 0,

    active_opacity   = 1.0,
    inactive_opacity = 1.0,

    dim_modal    = false, -- Dim parent of modal
    dim_inactive = false, -- Dim inactive
    dim_strength = 0.0,   -- Dim strength
    dim_special  = 0.15,   -- Dim when in special/magic workspace
    dim_around   = 0.4,   -- Dim strength of dim_around windowrule

    border_part_of_window = true, -- Border of window is part of window

    blur   = { enabled = false, },
    shadow = {
        -- Disabled everywhere except special workspaces via workspace rules 
        enabled = true,
        color   = M.cfg.general.col.active_border.colors[2], 
        color_inactive = M.cfg.general.col.inactive_border.colors[2], 
    },
    glow   = { enabled = false, },
}

M.cfg.animations = require("animations").cfg

M.cfg.master = {
    --https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
    new_status	= "slave",
	mfact		= 0.5,
}

M.cfg.input = {
    kb_model   = "thinkpad",
    kb_layout  = "us",
    kb_variant = "",
    kb_rules   = "evdev",

    kb_options = "ctrl:nocaps",   -- Map CapsLock to Ctrl
  --kb_options = "caps:escape",   -- Map CapsLock to Escape
  --kb_options = "caps:hyper",    -- Map CapsLock to Hyper
  --kb_options = "caps:none",     -- Map CapsLock to Void, for Wezterm

	-- 0 - Cursor movement will not change focus.
	-- 1 - Cursor movement will always change focus to the window under the
	--     cursor.
	-- 2 - Cursor focus will be detached from keyboard focus. Clicking on a
	--     window will move keyboard focus to that window.
	-- 3 - Cursor focus will be completely separate from keyboard focus.
	--     Clicking on a window will not change keyboard focus.
    follow_mouse = 2,

	-- If disabled, mouse focus won’t switch to the hovered window unless the
	-- mouse crosses a window boundary when follow_mouse=1.
	mouse_refocus = false,

	-- If enabled (1 or 2), focus will change to the window under the cursor
	-- when changing from tiled-to-floating and vice versa. If 2, focus will
	-- also follow mouse on float-to-float switches.
	float_switch_override_focus = 0,

    repeat_rate  = 25,  -- Key held down rate
    repeat_delay = 600, -- Delay before repeat

    sensitivity = 0.5, -- Pointer sensitivity: (-1.0 - 1.0), 0 means no modification.

    scroll_method = "2fg", -- 2 Fingers
    --scroll_button = 274,   -- Checked with `wev`, Wayland Event Viewer

    -- If Special contains only floating windows, allow focus to underlying workspace
    special_fallthrough = true, 
}
M.cfg.input.touchpad = {
    disable_while_typing = true,  -- When typing, true. When gaming, false.

    natural_scroll = false, -- Invert scroll
    scroll_factor  = 1.0,   -- Scroll speed

    clickfinger_behavior = true, -- 1, 2, 3 finger tap = LMB, RMB, MMB
}
M.cfg.input.touchdevice = { enabled = false, } -- Touchscreen

M.cfg.misc = {
    force_default_wallpaper  = -1,
    disable_hyprland_logo    = true,
    disable_splash_rendering = true,

    font_family = "AnonymicePro Nerd Font Mono",

    animate_manual_resizes = true, -- Might be cool. Probably look lag-esque.

    disable_autoreload = true, -- Don't automatically reload on config change.

    focus_on_activate = true,

    close_special_on_empty = true, -- Close special workspace on last window close.

    -- Windows open on invoked workspace 
    -- 0 - Disabled
    -- 1 - Single-shot
    -- 2 - Persistent, all children too
    initial_workspace_tracking = 2, 

    middle_click_paste = true, -- Paste primary selection on middle click

    enable_anr_dialog = false, -- App Not Responding dialog 
}

M.cfg.ecosystem = { no_donation_nag = true, }

M.setup = function()
    hl.config(M.cfg)
    if M.cfg.animations then
        require("animations").setup()
    end
end

return M
