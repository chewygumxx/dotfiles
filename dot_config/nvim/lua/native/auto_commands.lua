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

local header_template = function()
    local source_dirs = {
        "~/.config/zsh",
        "~/.local/share/chezmoi/dot_config/zsh",
        "~/doc/synexus/.zsh",

        "~/.config/hypr",
        "~/.config/nvim/lua",
        "~/.config/luarocks",
        "~/.config/wezterm",
        "~/.config/yay",
        "~/.config/yazi",

        "~/.local/share/hyprland",
        "~/.local/share/lua",
        "~/.local/share/luarocks",
        "~/.local/share/yazi/plugins",
        "~/.local/share/nvim",

        "~/.local/share/chezmoi/dot_config",
        "~/.local/share/chezmoi/dot_local/share",
    }

    local shebangs = {
        sh     = "#!/bin/sh",
        bash   = "#!/usr/bin/env bash",
        just   = "#!/usr/bin/env -S just --working-directory . --justfile",
        lua    = "#!/usr/bin/env lua",
        python = "#!/usr/bin/env python3",
        zsh    = "#!/usr/bin/env zsh",
    }
    local get_shebang = function(home_path, buf)
        for _,dir in ipairs(source_dirs) do
            if home_path:find(dir .. '/', 1, true) == 1 then
                return "#!/bin/false"
            end
        end

        return shebangs[vim.bo[buf].filetype]
    end

    -- The order matters, first to match is replaced and returned.
    local header_path_substitute = {
        { patt = "local/share/chezmoi/dot_", repl = "" },
        { patt = "%.local/share/chezmoi/", repl = "" },
        { patt = "~/doc/synaptic%-nexus", repl = "~chewygumxx/synaptic-nexus.git:" },
        { patt = "~/dev/_gist/(%w+)", repl = "~chewygumxx/%1.git:" },
        { patt = "~/dev/(%w+)", repl = "~chewygumxx/%1.git:" },
    }
    
    local header_path = function(home_path)
        -- Chezmoi intrinsic
        if home_path:find("%.chezmoi", 1, true) then
            return
        end
    
        for _,substitute in ipairs(header_path_substitute) do
            local pattern = substitute.patt
            local replace = substitute.repl
    
            local header_path, match = home_path:gsub(pattern, replace)
            if match == 1 then
                return header_path
            end
        end
    
        return home_path
    end

    local modeline = "vim: expandtab:shiftwidth=4"

    local insert_header = function(filename, buf)
        local comment = vim.bo[buf].commentstring
        if comment == "" then
            return
        end
        local home_path = vim.fn.fnamemodify(filename, ":~")

        local header_lines = {
            string.format(comment, modeline),
            "",
            string.format(comment, ""),
            string.format(comment, ""),
            string.format(comment, header_path(home_path)),
            string.format(comment, ""),
            string.format(comment, ""),
            "",
        }

        local shebang = get_shebang(home_path, buf)
        if shebang ~= nil then
            table.insert(header_lines, 1, shebang)
        end

        vim.api.nvim_buf_set_lines(buf, 0, 0, false, header_lines)
    end

    vim.api.nvim_create_user_command("CGInsertHeader", 
        function()
            insert_header(vim.fn.expand("%"), vim.api.nvim_get_current_buf())
        end,
        { desc = "Prepend buffer with a header, templated according to filepath and extension." }
    )

    vim.api.nvim_create_autocmd("BufNewFile", {
        group = vim.api.nvim_create_augroup("cgxx.header_template", { clear = true }),
        desc  = "Marks buffer as new for pending header insertion.",
        callback = function(aucmd_tbl)
            vim.b[aucmd_tbl.buf].cgxx_pending_header = true
        end,
    })

    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("cgxx.header_template_apply", { clear = true }),
        desc  = "Inserts templated header once filetype (and commentstring) is known.",
        callback = function(aucmd_tbl)
            if vim.b[aucmd_tbl.buf].cgxx_pending_header then
                vim.b[aucmd_tbl.buf].cgxx_pending_header = nil
                insert_header(aucmd_tbl.file, aucmd_tbl.buf)
            end
        end,
    })
end

M.setup = function()
    cursor_last_position()
    header_template()
end

return M
