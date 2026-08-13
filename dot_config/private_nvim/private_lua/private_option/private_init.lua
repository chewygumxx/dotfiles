#!/bin/false
-- vim: expandtab:shiftwidth=4:filetype=lua:

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/nvim/lua/option/init.lua
--
--

--
-- Declare option settings
--

local M = {}

M.setup = function()
    require("option.misc").setup()
    require("option.view").setup()
    require("option.fold").setup()
end

return M
