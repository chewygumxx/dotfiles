-- vim: foldlevel=3:foldmethod=expr

--
--
-- ~/.config/nvim/lua/native/filetypes.lua
--
--

local M = {}

M.setup = function()
    vim.filetype.add({
        extension = {
            zshrc = "zsh",
        },
        filename = {
            ["ignore"]         = "gitignore",
            [".chezmoiignore"] = "gitignore",
        },
        pattern = {
            [".*/hypr/.*%.conf"] = "hyprlang",
            [".*config/zsh/.*"] = "zsh",
            [".*config/environment.d/.*%.conf"] = "systemd",
        },
    })
end

return M
