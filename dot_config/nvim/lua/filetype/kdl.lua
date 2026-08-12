#!/bin/false
-- vim: expandtab:shiftwidth=4

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/nvim/lua/filetype/filetype_kdl.lua
--
--

--
-- KDL filetype settings
--

local M = {}

local M.hlgroup_defs = {
    ["@type.kdl"]                  = { link = "@property" },
    ["@punctuation.bracket.kdl"]   = { link = "PreProc"   },
    ["@punctuation.delimiter.kdl"] = { link = "Macro"     },
}

return M
