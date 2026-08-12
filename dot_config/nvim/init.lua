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

-- Fundamental settings
-- Stable and rudimentary fallback options, keymaps, highlights, et cetera.
-- Settings are not to be considered stable, nor safe from overwrite.
-- Defines essentials including, non-exhaustively:
-- - vim.g.mapleader
-- - Yank to system clipboard
-- - Yank to blackhole register
-- - Transparent background
-- Before all, in the event Neovim initialisation fails
require("stable").setup()

-- Initialisation Order
local init_modules = {
    -- Filetype heuristic resolution matrix
    -- Before plugin_manager,  for lazy-load filetype triggers
    "util.ftmatrix",

    -- Universal augroup definitions
    -- Before plugin_manager,  for augroup dependent plugin spec
    "util.augroup",

    -- Plugin lazy-load management
    -- After  stable.keymap,   for lazy-load keymap triggers involving vim.g.mapleader
    -- After  util.ftmatrix,   for lazy-load filetype triggers
    -- After  util.augroup,    for augroup dependent plugin spec
    -- Before after.highlight, for treesitter parsing and colorscheme overwrite
    "plugin_manager",

    -- Modules of the './lua/after/' directory are intended for setup via
    -- './after/trigger.lua'
    -- Prevents settings overwrite by plugins not designated for lazy loading.
    -- These include colorscheme highlight overwrites and persistent keymaps.
}

for _, module in ipairs(init_modules) do
    require(module).setup()
end
