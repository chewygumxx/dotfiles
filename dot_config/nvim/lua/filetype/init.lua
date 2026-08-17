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

local M = {}
local __this_module = ...


local ft_specialised_mods = {
    man      = true,
    markdown = true,
    kdl      = true,
}
local ft_specialised = function()
    vim.api.nvim_create_autocmd("FileType", {
        desc  = "If available, instantiates filetype-specialised lua module",
        group = vim.api.nvim_create_augroup("cgxx.filetype_specialised", { clear = true }),
        callback = function(opts)
            local filetype = opts.match
            if not ft_specialised_mods[filetype] then
                return
            end

            local modpath = __this_module .. "." .. filetype
            local ok, module = pcall(require, modpath)
            if not ok then
                vim.notify("Failed to require() filetype module: " .. modpath,
                    vim.log.levels.ERROR)
                return
            end

            if module.setup then
                module.setup(opts.file, opts.buf, opts)
            end
        end
    })
end

M.setup = function()
    require(__this_module .. ".ftmatrix").setup()
    ft_specialised()
end

return M
