#!/bin/false
-- vim: expandtab:shiftwidth=4

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/nvim/lua/stable/init.lua
--
--

--
-- Setup stable and fundamental fallback environment
--

local M = {}

local modules = {
    "option",
    "keymap",
    "usercmd",
    "autocmd",
    "highlight",
}

M.setup = function()
    for _, module in ipairs(modules) do
        require("stable." .. module).setup()
    end
end

return M
