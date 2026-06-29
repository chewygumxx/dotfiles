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
        },
        filename = {
            ["ignore"]         = "gitignore",
            [".chezmoiignore"] = "gitignore",
        },
        pattern = {
            [".*/hypr/.*%.conf"] = "hyprlang",
        },
    })
end

return M
