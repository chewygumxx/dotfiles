#!/bin/false
-- vim: expandtab:shiftwidth=4

-- 
-- 
-- ~/.config/nvim/lua/native/auto_commands.lua
-- 
-- 

local M = {}

local cursor_last_position = function()
    vim.api.nvim_create_autocmd("BufReadPost", {
        group    = vim.api.nvim_create_augroup("cgxx.file_welcome", { clear = true }),
        desc     = "Move cursor to last position within file",
        callback = function ()
            vim.schedule(function ()
                -- Skip if the cursor was already moved (e.g. by gF, a line-number arg, etc.)
                local cur = vim.api.nvim_win_get_cursor(0)
                if cur[1] ~= 1 or cur[2] ~= 0 then
                    return
                end
                vim.cmd('silent! normal! g`"zvzz')
            end)
        end,
    })
end


M.setup = function()
    cursor_last_position()
end

M.setup()

return M
