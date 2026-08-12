-- vim: expandtab:shiftwidth=4:foldlevel=3:foldmethod=expr

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
            [".assetsignore"]  = "gitignore",  -- CloudFlare Worker wrangler config
        },
        pattern = {
            [".*gnupg/.*%.conf"] = "gpg",
            [".*/hypr/.*%.conf"] = "hyprlang",
            [".*config/environment.d/.*%.conf"] = "systemd",

            [".*config/zsh/.*"]    = "zsh",
            [".*zsh/func/.*"]      = "zsh",
            [".*zsh/functions/.*"] = "zsh",
        },
    })
end

M.setup()

return M
