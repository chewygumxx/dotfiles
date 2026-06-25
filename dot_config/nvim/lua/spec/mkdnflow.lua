-- vim: expandtab:shiftwidth=4:

--
--
-- ~/.config/nvim/lua/spec/mkdnflow.lua
--
--

---@module "lazy"
---@type LazySpec
local M = {
    url = 'https://github.com/jakewvincent/mkdnflow.nvim',
    ft  = { 'markdown', 'md', },
}

M.opts = {}

return M
