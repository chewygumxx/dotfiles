-- vim: expandtab:shiftwidth=4

--
--
-- ~/.config/hypr/hyprland.lua
--
--

--
-- Monitors
--

hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1200@60",
    position = "0x0",
    scale    = 1,
})

hl.monitor({ -- Fallback
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

--
-- Sourcing
--

require("variables").setup()
require("keybinds").setup()
require("window_workspace_rules").setup()
require("autostart").setup()
