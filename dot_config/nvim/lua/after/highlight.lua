#!/bin/false
-- vim: expandtab:shiftwidth=4

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/nvim/lua/base/highlight.lua
--
--

--
-- Fundamental universal highlight group options
-- Initialised after treesitter and colorscheme plugins
--

local M = {}

-- Highlight Table
local hlgroup_opts = {
    -- Background Transparency and Anti-Eye Strain
    ["Normal"]     = { ctermbg   = "none",    fg = "#cad6ff", bg = "none",   },
    ["Search"]     = { bold      = true,      fg = "#e0e8ff", bg = "#52408f" },
    ["Title"]      = { bold      = true,      fg = "#cad6ff" },
    ["NonText"]    = { ctermbg   = "none",    bg = "none"    },
    ["Underlined"] = { underline = true },

    -- Paired-Boundary Character
    ["MatchParen"] = { standout = true },

    -- Define @markup Underline, Bold and Strikethrough
    ["@markup.strong"]        = { bold          = true },
    ["@markup.underline"]     = { underline     = true },
    ["@markup.strikethrough"] = { strikethrough = true },
}

function M.setup()
    for group, opts in pairs(hlgroup_opts) do
        vim.api.nvim_set_hl(bufnr, group, opts)
    end
end

return M
