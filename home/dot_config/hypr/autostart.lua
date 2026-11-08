-- vim:set expandtab shiftwidth=4 filetype=lua:
-- SPDX-License-Identifier: GPL-3.0-only
-- luacheck: globals hl

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/home/dot_config/hypr/autostart.lua
--
--

local chewy = require("chewy")

---@class Hypr.Autostart
---@field setup? fun(): nil
local M = {}

M.setup = function()
    hl.on("hyprland.start", function()
        hl.dispatch(
            hl.dsp.exec_cmd(
                "systemctl --user start --wait chezmoi-environment.service"
            )
        )
        hl.dispatch(
            hl.dsp.exec_cmd("systemctl --user start hyprland-post.target")
        )

        hl.dispatch(
            hl.dsp.exec_cmd(chewy.terminal.cmd.tiled, { workspace = 1 })
        )
        -- No exec rules here: they match a window by an env token that
        -- exec_cmd sets, else by the spawned PID. Firefox is a child of
        -- the user manager (systemctl only asks it to start the unit), so
        -- it has neither. The firefox_main window rule places it instead.
        hl.dispatch(hl.dsp.exec_cmd(chewy.browser.cmd))
    end)
end

return M
