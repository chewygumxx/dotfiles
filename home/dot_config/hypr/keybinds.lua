-- vim: expandtab:shiftwidth=4

--
--
-- ~/.config/hypr/keybinds.lua
--
--

local chewy = require("chewy")
local M = {}

local mod = "SUPER + "

--hl.bind(mod .. "I", function() hl.dsp.exec_cmd(chewy.terminal.cmd.base .. "sh -c echo \"" .. hl.get_active_window() .. "\"; read -r _") end)

local general = function()
    -- Exit Hyprland
    hl.bind(mod .. "SHIFT + Escape", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

    -- Terminal
    hl.bind(mod .. "Return",         hl.dsp.exec_cmd(chewy.terminal.cmd.tiled))
    hl.bind(mod .. "SHIFT + Return", hl.dsp.exec_cmd(chewy.terminal.cmd.float))

    -- Clipboard Manager
    hl.bind(mod .. "V", hl.dsp.exec_cmd(chewy.clipman.cmd))

    -- Screenshot
    hl.bind("Print",        hl.dsp.exec_cmd(chewy.screenshot.cmd.all))
    hl.bind(mod .. "Print", hl.dsp.exec_cmd(chewy.screenshot.cmd.select))
end 

local window = function()
    -- Termination
    hl.bind(mod .. "W",         hl.dsp.window.close()) -- Graceful
    hl.bind(mod .. "SHIFT + W", hl.dsp.window.kill()) -- Forced

    -- State
    hl.bind(mod .. "S", hl.dsp.window.float({ action = "toggle" }))
    hl.bind(mod .. "F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
    
    -- Mouse
    hl.bind(mod .. "mouse:272", hl.dsp.window.drag(),   { mouse = true })
    hl.bind(mod .. "mouse:273", hl.dsp.window.resize(), { mouse = true })

    -- Cardinal Direction
    local cardinals = {
        { "left",  "H", -60,   0 },
        { "down",  "J",   0,  60 }, 
        { "up",    "K",   0, -60 },
        { "right", "L",  60,   0 },
    }
    for _, cardinal in ipairs(cardinals) do
        local direction, key, x, y = table.unpack(cardinal)

        -- Focus
        hl.bind(mod .. key, hl.dsp.focus({ direction = direction }))

        -- Swap/Move
        hl.bind(mod .. "SHIFT + " .. key, function()
            if hl.get_active_window().floating then  
                hl.dispatch(hl.dsp.window.move({ x = x, y = y, relative = true })) -- Float
            else
                hl.dispatch(hl.dsp.window.swap({ direction = direction })) -- Tiled
            end
        end)

        -- Resize
        hl.bind(mod .. "ALT + " .. key, hl.dsp.window.resize({ x = x, y = y, relative = true }))
    end
end

local workspace = function()
    -- Focus and send window to workspace adjacent
    hl.bind(mod .. "bracketleft",          hl.dsp.focus({ workspace = "r-1"}))
    hl.bind(mod .. "bracketright",         hl.dsp.focus({ workspace = "r+1"}))
    hl.bind(mod .. "SHIFT + bracketleft",  hl.dsp.window.move({ workspace = "r-1"}))
    hl.bind(mod .. "SHIFT + bracketright", hl.dsp.window.move({ workspace = "r+1"}))

    -- Focus and send window to workspace [0-9]
    for i=1,10,1 do
        key = i % 10 -- Map key 0 to workspace 10
        hl.bind(mod .. key,               hl.dsp.focus({ workspace = i }))
        hl.bind(mod .. "SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    end

    -- Focus and send window to workspace magic
    -- The key '`' is grave
    hl.bind(mod .. "grave",         hl.dsp.workspace.toggle_special("scratch"))
    hl.bind(mod .. "SHIFT + grave", hl.dsp.window.move({ workspace = "special:scratch" }))
  --hl.bind(mod .. "Tab",           hl.dsp.workspace.toggle_special("dashboard"))
  --hl.bind(mod .. "SHIFT + Tab",   hl.dsp.window.move({ workspace = "special:dashboard" }))
end

local function_keys = function()
    hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
    hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
    hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
    hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"))

    hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl --exponent set 10%+"))
    hl.bind("XF86MonBrightnessDown",
        hl.dsp.exec_cmd("brightnessctl --min-value=$(( $(brightnessctl max) / 10 )) --exponent set 10%-") )
end

M.setup = function()
    general()
    window()
    workspace()
    function_keys()
end

return M
