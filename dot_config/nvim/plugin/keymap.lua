#!/usr/bin/env lua
-- vim: foldlevel=1:foldmethod=expr

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/nvim/plugin/keymap.lua
--
--

local M = {}

vim.g.timeoutlen = 1000  -- Time to complete keymap sequence
vim.g.mapleader = "\\"

local normal_leader = {
    --{{!CLOSE
    blink_relativenumber = function()
        vim.api.nvim_set_keymap('n', '<leader>nn', '', {
            desc = "Blink option relativenumber temporarily",
            callback = function() 
                local toggle_relativenumber = function()
                    vim.o.relativenumber = not vim.o.relativenumber
                end

                toggle_relativenumber()
                vim.defer_fn(toggle_relativenumber, 2000)
            end,
        })
    end,
    clear_hlsearch = function()
        vim.api.nvim_set_keymap('n', '<leader>h',  '<cmd>noh<CR>', {
            desc = ":noh - Clear highlight of search match",
            noremap = true,
        })
    end,
    flash_linenumber = function()
        vim.api.nvim_set_keymap('n', '<leader>nn', '', {
            desc = "Briefly flash line number gutter",
            callback = function() 
                local old_hl_linenr = vim.api.nvim_get_hl(0, { name = "LineNr" })
                local old_o_number = vim.o.number
                local old_o_relativenumber = vim.o.relativenumber

                vim.api.nvim_set_hl(0, "LineNr", { link = "ErrorMsg" })
                vim.o.number = true
                vim.o.relativenumber = false

                vim.defer_fn(function()
                    vim.api.nvim_set_hl(0, "LineNr", old_hl_linenr)
                    vim.o.number = old_o_number
                    vim.o.relativenumber = old_o_relativenumber
                end, 3000)
            end,
        })
    end,
    format_buffer = function()
        vim.api.nvim_set_keymap('n', '<leader>tw', 'gggqG', {
            desc = "Format buffer line wrapping according to textwidth",
        })
    end,
    inspect = function()
        vim.api.nvim_set_keymap('n', '<leader>in', '<cmd>Inspect<CR>', {
            desc = ":Inspect highlight groups under cursor",
        })
    end,
    reload_foldmethod = function()
        vim.api.nvim_set_keymap('n', '<leader>rf', '', {
            desc = "Reload foldmethod",
            callback = function()
                vim.o.foldmethod = vim.o.foldmethod
                vim.print("foldmethod=" .. vim.o.foldmethod) 
            end
        })
    end,
}
normal_leader.setup = function (self)
  --self.blink_relativenumber()
    self.clear_hlsearch()
    self.flash_linenumber()
    self.format_buffer()
    self.inspect()
    self.reload_foldmethod()
end

local remap_native = {
    --{{!CLOSE
    blackhole_register = function()
        vim.api.nvim_set_keymap('n', 'x', '"_x', {
            desc = "Route single character deletion into blackhole register",
            noremap = true,
        })
        vim.api.nvim_set_keymap('v', 'p', '"_dP', {
            desc = "Route pasted over selection into blackhole register",
            noremap = true,
        })
    end,
    visual_indent_persist = function()
        local desc = "Remain in select mode after indenting"
        vim.api.nvim_set_keymap('n', '>', '>gv', { desc = desc, noremap = true })
        vim.api.nvim_set_keymap('x', '<', '<gv', { desc = desc, noremap = true })
    end,
    file_navigation = function()
        local desc    = "Route gf to gF, go to line number if provided"
        vim.api.nvim_set_keymap('n', 'gf', 'gF', { desc = desc, noremap = true })
        vim.api.nvim_set_keymap('x', 'gf', 'gF', { desc = desc, noremap = true })
    end,
    file_creation = function()
        local desc = "Create new file according to path under cursor"
        vim.api.nvim_set_keymap('n', 'gF', '<cmd>e <cfile><CR>', { desc = desc, noremap = true })
        vim.api.nvim_set_keymap('x', 'gF', '<cmd>e <cfile><CR>', { desc = desc, noremap = true })
    end
}
remap_native.setup = function(self)
    self.blackhole_register()
    self.visual_indent_persist()
    self.file_navigation()
    self.file_creation()
end

local read_only = {
    --{{!CLOSE
    remap_q_quit = function(event)
        vim.api.nvim_buf_set_keymap(event.buf, "n", "q", "<cmd>q<CR>", {
            desc = "Quit read-only buffer",
            noremap = true,
        })
    end,
}
read_only.setup = function (self)
    local set_keymaps = function(event)
          self.remap_q_quit(event)
    end

    vim.api.nvim_create_autocmd({ "BufReadPost" }, {
        --{{!CLOSE
        desc = "Keymap setup for read-only buffers",
        group = vim.g.file_welcome,
        callback = function(event)
            if vim.bo.readonly or not vim.bo.modifiable then
                set_keymaps(event)
            end
        end,
    })
end

function M.setup()
    --for _, api_call in pairs(normal_leader) do api_call() end
    normal_leader:setup()
    remap_native:setup()
    read_only:setup()
end

M.setup()

return M
