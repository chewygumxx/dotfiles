#!/bin/false
-- vim: expandtab:shiftwidth=4:filetype=lua:

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/nvim/lua/after/init.lua
--
--

--
-- Post-setup of runtimepath modules
--

local M = {}

local modules = {
    "option",
    "keymap",
    "usercmd",
    "autocmd",
    "lsp",
    "filetype",
    "highlight",
}

M.setup = function()
    for _, module in ipairs(modules) do
        require("after." .. module).setup()
    end
end

return M
