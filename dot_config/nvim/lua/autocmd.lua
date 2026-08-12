#!/bin/false
-- vim: expandtab:shiftwidth=4:filetype=lua:

-- 
-- 
-- ~/.config/nvim/lua/autocmd.lua
-- 
-- 

local M = {}

local cursor_last_position = function()
    vim.api.nvim_create_autocmd("BufReadPost", {
        desc = "Move cursor to last position within file",
        callback = function () vim.schedule( function ()
            -- Skip if the cursor was already moved (e.g. by gF, a line-number arg, etc.)
            local cur = vim.api.nvim_win_get_cursor(0)
            if cur[1] ~= 1 or cur[2] ~= 0 then
                return
            end
            vim.cmd('silent! normal! g`"zvzz')
        end) end
    })
end


local readonly_remap_q_quit = function()
    vim.api.nvim_create_autocmd("BufReadPost", {
        desc = "Keymap setup for read-only buffers",
        callback = function(event)
            bufnr = event.buf or 0
            if vim.bo[bufnr].readonly or not vim.bo[bufnr].modifiable then
                vim.keymap.set({ "n", "v" }, "q", "<cmd>q<CR>", {
                    buffer = bufnr,
                    desc   = "Quit read-only buffer",
                    remap  = false,
                })
            end
        end
    })
end

M.setup = function()
    cursor_last_position()
    readonly_remap_q_quit()
end

return M
