#!/usr/bin/env lua
-- vim:set expandtab shiftwidth=4 filetype=lua:
-- luacheck: globals hl

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/home/dot_config/hypr/window_workspace_rules.lua
--
--

---@class Hypr.WindowWorkspaceRules
---@field setup? fun(): nil
---@field rules  { wksp: table<string, fun(): nil>, wndw: table<string, table> }
local M = {
    rules = {
        wksp = {},
        wndw = {},
    },
}

---@type table<string, fun(): nil>
M.rules.wksp = {
    special_shadow = function()
        -- Render window shadows exclusively in special workspaces

        for i = 1, 1, 10 do
            hl.workspace_rule({ workspace = tostring(i), no_shadow = true })
        end
        hl.workspace_rule({
            workspace = "special:dashboard",
            no_shadow = false,
        })
        hl.workspace_rule({
            workspace = "special:scratch",
            no_shadow = false,
            on_created_empty = require("chewy")
                .terminal
                .cmd
                .float,
        })
    end,
}

M.rules.wndw = {
    terminal_float = {
        match = { class = "term-float" },

        float = true,
        center = true,
        size = { 1100, 652 },
    },

    -- History and Bookmarks
    firefox_library = {
        match = { class = "firefox", title = "Library" },

        float = true,
        center = true,
        size = { 1200, 652 },
    },

    firefox_extensions_popups = {
        match = { class = "firefox", title = "^Extension.*$" },
        float = true,
    },

    firefox_main = {
        match = { class = "firefox" },
        workspace = 2,
        no_initial_focus = true,
    },

    cclip_fzf = {
        match = { class = "cclip-fzf" },
        float = true,
        size = { 1100, 652 },
    },

    terminal_file_picker = {
        match = { class = "terminal-file-picker" },
        float = true,
        center = true,
        size = { 1200, 652 },
    },

    steam_games_library = {
        match = { class = "steam" },
        workspace = 3,
    },
}

M.setup = function()
    for _, wksp in pairs(M.rules.wksp) do
        wksp()
    end
    for name, wndw in pairs(M.rules.wndw) do
        wndw.name = name
        hl.window_rule(wndw)
    end
end

return M
