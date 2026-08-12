#!/bin/false
-- vim: expandtab:shiftwidth=4:filetype=lua:

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/nvim/lua/general/option.lua
--
--

local M = {}

M.opts = {
    -- System
    clipboard = "unnamedplus",
    undofile  = true,
    mouse     = "",

    -- Tabspace
    expandtab  = true,
    shiftwidth = 4,
    tabstop    = 4,

    virtualedit = "block",
    --textwidth = 80,

    -- Color
    termguicolors = true,

    -- Margin
    number         = true,
    relativenumber = true,
    scrolloff      = 5,
    
    -- Break at word
    linebreak = true,

    -- Fold
    foldmethod = "expr",
    fillchars  = "fold: ",
    foldlevel  = 2,

    -- Window Splitting
    splitright = true,

    -- Search:
    -- Ignore case unless uppercase provided.
    ignorecase = true,
    smartcase  = true,

    -- Restore view when jumping
    jumpoptions = "view",

    -- Consign all security to oblivion
  --modelineexpr = true,
}

M.setup = function()
    for opt, value in pairs(nvim_opt_table) do
        vim.api.nvim_set_option_value(opt, value, {})
    end
    require("util.foldtext").setup()
end

return M
