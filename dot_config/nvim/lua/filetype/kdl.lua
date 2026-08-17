#!/bin/false
-- vim: expandtab:shiftwidth=4:filetype=lua:

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/nvim/lua/filetype/kdl.lua
--
--

--
-- KDL filetype settings
--

local M = {}

local opts = {
}

local hlgroup_defs = {
    ["@type"]                  = { link = "@property" },
    ["@punctuation.bracket"]   = { link = "PreProc"   },
    ["@punctuation.delimiter"] = { link = "Macro"     },
}

M.set = function(file, buf)
    file = file or vim.fn.expand("%")
    buf  = buf  or 0

    for opt, value in pairs(opts) do
        vim.api.nvim_set_option_value(opt, value, { buf = buf })
    end
    for hlgroup, defmap in ipairs(hlgroup_defs) do
        vim.api.nvim_set_hl(0, hlgroup .. ".kdl", defmap)
    end
end

M.autocmd = function()

end

M.setup = function()
    M.autocmd()
end

return M
