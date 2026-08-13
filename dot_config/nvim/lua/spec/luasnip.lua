#!/bin/false
-- vim: expandtab:shiftwidth=4:ft=lua:

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/nvim/lua/spec/luasnip.lua
--
--

--
-- The Snippet Engine
--


---@module "lazy"
---@type LazySpec
local M = {
    url     = "https://github.com/L3MON4D3/LuaSnip.git",
    enabled = true,
    version = "v2.5.0",
    build   = "make install_jsregexp",
}

M.opts = { }


return M
