#!/usr/bin/env lua
-- vim: expandtab:shiftwidth=4

-- 
-- 
-- ~/.config/nvim/after/lsp/marksman.lua
-- 
-- 

local M = {}

M.cmd          = { "marksman", "server" } -- Initialise
M.filetypes    = { "markdown" }
M.root_markers = { ".marksman.toml" }

return M
