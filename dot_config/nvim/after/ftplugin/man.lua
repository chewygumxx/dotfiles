-- vim: expandtab:shiftwidth=4

--
--
-- ~/.config/nvim/after/ftplugin/man.lua
--
--

-- Stop fucking up my options

local opts = require("native.options").opts

vim.api.nvim_set_option_value("number", opts.number, {})
vim.api.nvim_set_option_value("relativenumber", opts.relativenumber, {})
