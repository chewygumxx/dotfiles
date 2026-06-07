#!/usr/bin/env lua
-- vim: foldlevel=2:foldmethod=expr

--
--
-- ~/.config/nvim/lua/config/filetypes.lua
--
--

local M = {}

local filetype_maps = {
    { pattern = ".*/hypr/.*%.conf", ft = "hyprlang" }
}

M.setup = function()
    for _, map in pairs(filetype_maps) do
        vim.filetype.add({ pattern = { [map.pattern] = map.ft } })
    end
end

return M
