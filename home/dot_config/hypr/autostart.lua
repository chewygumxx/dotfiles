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
        hl.dispatch(hl.dsp.exec_cmd("systemctl --user start --wait chezmoi-environment.service"))
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
