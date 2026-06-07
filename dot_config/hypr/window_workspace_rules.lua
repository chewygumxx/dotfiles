-- vim: expandtab:shiftwidth=4

--
--
-- ~/.config/hypr/window_rules.lua
--
--

local M = {}

local workspace_rules = {
    special_shadow = function()
        -- Render window shadows exclusively in special workspaces

        for i=1,1,10 do 
            hl.workspace_rule({ workspace = tostring(i), no_shadow = true })
        end
        hl.workspace_rule({
            workspace = "special:dashboard",
            no_shadow = false,
        })
        hl.workspace_rule({
            workspace = "special:scratch",
            no_shadow = false,
            on_created_empty = require("chewy").terminal.cmd.float,
        })
    end,
}

local window_rules = {
    terminal_float = function()
        hl.window_rule({
            name = "terminal_float",
            match = { class = "term-float" },

            float = true,
            center = true,
            size = { 1100, 652 },
        })
    end,

    firefox_library = function ()
        hl.window_rule({
            -- History and Bookmarks Window
            name = "firefox_library",
            match = { class = "firefox", title = "Library", },

            float = true,
            center = true,
            size = { 1200, 652 },
        })
    end,

    firefox_extensions = function()
        hl.window_rule({
            name = "firefox-extensions-popups",
            match = { class = "firefox", title = "^Extension.*$", },

            float = true,
        })
    end,

    firefox_main = function()
        hl.window_rule({
            name = "firefox-main",
            match = { class = "firefox" },

            --tile = true,
            workspace = 2,
            no_initial_focus = true,
        })
    end,

    clipboard_manager = function()
        hl.window_rule({
            name = "terminal-clipboard-manager-fzf-cclip",
            match = { class = "fzf-cclip", },

            float = true,
            size = { 1100, 652 },
        })
    end,

    terminal_file_picker = function()
        hl.window_rule({
            name = "terminal-file-picker",
            match = { class = "terminal-file-picker", },

            float = true,
            center = true,
            size = { 1200, 652 },
        })
    end,

    steam_games_library = function()
        hl.window_rule({
            name = "steam-games-library",
            match = { class = "steam", },

            workspace = 3,
        })
    end,
}

M.setup = function()
    for _, workspace_rule in pairs(workspace_rules) do workspace_rule() end
    for _, window_rule in pairs(window_rules) do window_rule() end
end

return M
