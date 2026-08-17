#!/bin/false
-- vim: expandtab:shiftwidth=4:filetype=lua:
-- luacheck: globals vim

-- 
-- 
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/nvim/lua/filetype/init.lua
-- 
-- 

-- 
-- Filetype module initialisation
-- 

local M
local __this_module = ...

-- Filetype Dedicated Module
-- Granularity is limited by the filetype matching the basename of the
-- module file. Processing per type of filetype (eg. source or executable),
-- contextual purpose, filepath, et cetera, must be handled
-- - Filetype-specific lua module
-- - Priority/specificity/lock system
-- - Sequentially post-filetype handling
local autocmd_dedicated_ft_module = function()
    vim.api.nvim_create_autocmd("FileType", {
        desc  = "If available, instantiates filetype-specialised lua module",
        group = vim.api.nvim_create_augroup("cgxx.filetype_dedicated_module"),
        callback = function(opts)
            local file = opts.file or vim.fn.expand("%")
            local buf  = opts.buf  or 0
            require(__this_module .. vim.bo[buf].filetype).setup(file, buf, {
                data  = data,
                event = event,
                id    = id,
                group = group,
                match = match,
            })
        end
    })
end

M.autocmd = function()
end

M.setup = function()
    require(... .. ftmatrix).setup()
    -- Resolution
    -- Specialised
    M.autocmd()
end

return M
