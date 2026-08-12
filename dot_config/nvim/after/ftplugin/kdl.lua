#!/bin/false
-- vim: expandtab:shiftwidth=4

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/nvim/after/ftplugin/kdl.lua
--
--

--
-- KDL filetype settings
--

local M = {}

local hlgroup_defs = {
    ["@type.kdl"]                  = { link = "@property" },
    ["@punctuation.bracket.kdl"]   = { link = "PreProc"   },
    ["@punctuation.delimiter.kdl"] = { link = "Macro"     },
}

M.setup = function()
    for hlgroup, defmap in pairs(hlgroup_defs) do
        vim.api.nvim_set_hl(0, hlgroup, defmap)
    end
end

return M
