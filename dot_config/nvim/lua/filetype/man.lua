#!/bin/false
-- vim: expandtab:shiftwidth=4:filetype=lua:

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/nvim/lua/filetype/man.lua
--
--

-- 
-- Filetype-specific configuration for manpages
--

local M

local opts = {
    number = true,
}

local hlgroup_defs = {
}

M.setup = function(file, buf)
    file = file or vim.fn.expand("%")
    buf  = buf  or 0

    for opt, value in pairs(opts) do
        vim.api.nvim_set_option_value(opt, value, { buf = buf })
    end
    for hlgroup, defmap in ipairs(hlgroup_defs) do
        vim.api.nvim_set_hl(0, hlgroup, defmap)
    end
end

return M
