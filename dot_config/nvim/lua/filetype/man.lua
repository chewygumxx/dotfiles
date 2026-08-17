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

local options = {
    number = true,
}

local hlgroup_defs = {
}


M.autocmd = function()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "man",
        desc  = "Filetype specialised module: Markdown",
        group = vim.api.nvim_create_augroup("cgxx.filetype_markdown", { clear = true }),
        callback = function(opts)
            M.setup(opts.file, opts.buf)
        end,
    })
end

M.setup = function(file, buf) -- Argument 'file' is a placeholder for now
    file = file or vim.fn.expand("%")
    buf  = buf  or 0

    for opt, value in pairs(options) do
        vim.api.nvim_set_option_value(opt, value, { buf = buf })
    end
    for hlgroup, defmap in pairs(hlgroup_defs) do
        vim.api.nvim_set_hl(0, hlgroup .. ".markdown",        defmap)
        vim.api.nvim_set_hl(0, hlgroup .. ".markdown_inline", defmap)
    end
end

return M
