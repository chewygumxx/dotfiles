-- vim: expandtab:shiftwidth=4

--
--
-- ~/.config/hypr/autostart.lua
--
--

local chewy = require("chewy")
local M = {}

M.setup = function()
    hl.on("hyprland.start", function()
        hl.dispatch(hl.dsp.exec_cmd("systemctl --user start hyprland-post.target"))

        hl.dispatch(hl.dsp.exec_cmd(chewy.terminal.cmd.tiled, { workspace = 1 }))
        hl.dispatch(hl.dsp.exec_cmd(chewy.browser.cmd, {
            tile = true,
            workspace = "2 silent",  -- These do not fucking work
            no_initial_focus = true  -- These do not fucking work
        }))
    end)
end

return M
