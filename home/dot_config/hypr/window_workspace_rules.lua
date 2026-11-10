#!/usr/bin/env lua
-- vim:set expandtab shiftwidth=4 filetype=lua:
-- SPDX-License-Identifier: GPL-3.0-only
-- luacheck: globals hl

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/home/dot_config/hypr/window_workspace_rules.lua
--
--

---@class Hypr.WindowWorkspaceRules
---@field setup? fun(): nil
---@field rules  { wksp: Hypr.WorkspaceRule[], wndw: HL.WindowRuleSpec[] }
local M = {
    rules = {
        wksp = {},
        wndw = {},
    },
}

---@class Hypr.WorkspaceRule
---@field name  string
---@field apply fun(): nil

-- Both rule lists are arrays, applied in order by setup()

---@type HL.EventSubscription?
local scratch_sub

---@type Hypr.WorkspaceRule[]
M.rules.wksp = {
    {
        name = "special_shadow",
        apply = function()
            -- Render window shadows exclusively in special workspaces

            for i = 1, 10 do
                hl.workspace_rule({ workspace = tostring(i), no_shadow = true })
            end
            hl.workspace_rule({
                workspace = "special:dashboard",
                no_shadow = false,
            })
            hl.workspace_rule({
                workspace = "special:scratch",
                no_shadow = false,
            })
        end,
    },

    {
        name = "scratch_terminal",
        apply = function()
            -- Spawn a floating terminal when special:scratch is created empty
            -- (replaces the deprecated `on_created_empty` workspace rule)

            -- Replace, not add to, any subscription from an earlier setup()
            -- in this Lua state, or special:scratch would get one terminal
            -- per call
            if scratch_sub and scratch_sub:is_active() then
                scratch_sub:remove()
            end
            scratch_sub = hl.on("workspace.created", function(ws)
                if ws.name ~= "special:scratch" or not ws.is_empty then
                    return
                end
                hl.dispatch(
                    hl.dsp.exec_cmd(
                        require("chewy").terminal.cmd.float,
                        { workspace = ws.name .. " silent" }
                    )
                )
            end)
        end,
    },
}

---@type HL.WindowRuleSpec[]
M.rules.wndw = {
    {
        name = "terminal_float",
        match = { class = "term-float" },

        float = true,
        center = true,
        size = { 1100, 652 },
    },

    -- History and Bookmarks
    {
        name = "firefox_library",
        match = { class = "firefox", title = "Library" },

        float = true,
        center = true,
        size = { 1200, 652 },
    },

    {
        name = "firefox_extensions_popups",
        match = { class = "firefox", title = "^Extension.*$" },
        float = true,
    },

    {
        name = "firefox_main",
        match = { class = "firefox" },
        workspace = 2,
        no_initial_focus = true,
        -- xdg-open hands URLs to the running instance, which then asks to be
        -- activated. Overrides misc.focus_on_activate for firefox only: the
        -- window is marked urgent rather than focused on every new tab.
        focus_on_activate = false,
    },

    {
        name = "cclip_fzf",
        match = { class = "cclip-fzf" },
        float = true,
        size = { 1100, 652 },
    },

    {
        name = "terminal_file_picker",
        match = { class = "terminal-file-picker" },
        float = true,
        center = true,
        size = { 1200, 652 },
    },

    {
        name = "steam_games_library",
        match = { class = "steam" },
        workspace = 3,
    },
}

-- Safe to call again: it does not modify the rule tables, and scratch_terminal
-- replaces its own event subscription. No early return on a second call,
-- since whether a config reload keeps this Lua state, and its rules, is
-- undocumented.
M.setup = function()
    for _, wksp in ipairs(M.rules.wksp) do
        wksp.apply()
    end
    for _, wndw in ipairs(M.rules.wndw) do
        hl.window_rule(wndw)
    end
end

return M
