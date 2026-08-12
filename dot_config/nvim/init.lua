-- vim: expandtab:shiftwidth=4

--
--
-- ~/.config/nvim/lua/init.lua
--
--

--
-- Symlink: "~/.config/nvim/init.lua"
--

require("native.auto_commands").setup()    -- Creates augroups
require("native.header_template").setup()
require("native.keymap").setup()           -- Depends on augroup vim.g.file_welcome
require("native.filetypes").setup()
require("native.options").setup()
require("native.user_commands").setup()

-- Plugin Manager, loads colourscheme
require("plugin_manager").setup()
--require("lazy").setup()

-- Initialise after colorscheme
require("highlight").setup()
