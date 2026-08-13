#!/bin/false
-- vim: expandtab:shiftwidth=4:filetype=lua:

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/nvim/init.lua
--
--

--
-- Neovim initialisation root
--

-- Initialisation Order
local modules = {
    "filetype",  -- Filetype heuristic resolution matrix

    "option",
    "keymap",
    "autocmd",
    "usercmd",

    -- Plugin lazy-load management
    -- After  keymap,     for lazy-load keymap triggers involving vim.g.mapleader
    -- After  filetype,   for lazy-load filetype triggers
    -- After  autocmd,    for augroup dependent plugin spec
    -- Before highlight,  for treesitter parsing and colorscheme overwrite
    "util.plugin_manager",

    "highlight"
}

for _, module in ipairs(modules) do
    require(module).setup()
end
