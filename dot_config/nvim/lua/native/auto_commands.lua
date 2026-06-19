-- vim:

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
    local fileext_to_comment = {
        lua  = "--",
        sql  = "--",
        rs   = "//",
        js   = "//",
        py   = "#",
        sh   = "#",
        zsh  = "#",
        toml = "#",
        conf = "#",
        ini  = ";",

        target  = "#",
        service = "#",
        desktop = ";",
    }

    local insert_header = function(filename, buf)
        local ext = vim.fn.fnamemodify(filename, ":e")
        if ext == "" then
            return
        end

        local line_comment = fileext_to_comment[ext]
        if line_comment == nil then
            return
        end

        local header_lines = {
            line_comment .. " vim:",
            "",
            line_comment,
            line_comment,
            line_comment .. " " .. vim.fn.fnamemodify(filename, ":~"),
            line_comment,
            line_comment,
            "",
        }
        vim.api.nvim_buf_set_lines(buf, 0, 0, false, header_lines)
    end

    local matched_exts = {}
    for key, _ in pairs(fileext_to_comment) do
        table.insert(matched_exts, "*." .. key)
    end
    vim.api.nvim_create_autocmd("BufNewFile", {
        group = vim.api.nvim_create_augroup("cgxx.header_template", { clear = true } ),
        pattern = matched_exts,
        desc = "Inserts templated header based on extension and path.",
        callback = function(aucmd_tbl)
            insert_header(aucmd_tbl.file, aucmd_tbl.buf)
        end,
    })

    vim.api.nvim_create_user_command("CGInsertHeader", 
        function() insert_header(vim.fn.expand("%"), vim.api.nvim_get_current_buf()) end,
        { desc = "Prepend buffer with a header, templated according to filepath and extension." }
    )
end

M.setup = function()
    --autosave()  -- May consider writing to a temp file rather than the original
    cursor_last_position()
    header_template()
end

return M
