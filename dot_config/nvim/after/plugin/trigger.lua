#!/bin/false
-- vim: expandtab:shiftwidth=4:filetype=lua:

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/nvim/after/trigger.lua
--
--

--
-- Trigger setup of "<conf>/lua/after/." modules
--

local M = {}

M.setup = function()
    vim.notify("hi", vim.log.level.INFO)
    require("after").setup()
end

return M
