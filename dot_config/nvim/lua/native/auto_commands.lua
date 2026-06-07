--
--
-- ~/.config/nvim/lua/native/auto_commands.lua
--
--

local M = {}

local augroup = "cgxx.file_welcome"
vim.api.nvim_create_augroup(augroup , { clear = true })

local autosave = function()
    --{{{!CLOSE
    local autosave_timer = vim.loop.new_timer()
    autosave_timer:start(0, 300000, vim.schedule_wrap(
        function()
            if vim.bo.modified then vim.cmd("silent! write") end
        end
    ))
end
local fold_state_last_pos = function()
    local fold_logic = function()
        -- Attempt to open and close folds according to enclosed markers

        local marker_open  = "{{{!OPEN"
        local marker_close = "{{{!CLOSE"
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

        for linenumber, line in ipairs(lines) do
            if line:find(marker_close, 1, true) then
                vim.api.nvim_win_set_cursor(0, { linenumber, 0 })
                pcall(vim.cmd, "normal! zc")

                --vim.notify("Found close at line: " .. linenumber, vim.log.levels.INFO )
            elseif line:find(marker_open, 1, true) then
                vim.api.nvim_win_set_cursor(0, { linenumber, 0 })
                pcall(vim.cmd, "normal! zo")

                --vim.notify("Found open at line: " .. linenumber, vim.log.levels.INFO )
            end
        end
    end

    local last_position = function()
        -- (g`"): Goto last position
        --  (zv): Open folds to reveal cursor (zv)
        vim.cmd('silent! normal! g`"zv')
        --  (zz): Redraw cursor line to centre of window
        vim.cmd('silent! normal! zz')
    end

    vim.api.nvim_create_autocmd("User", {
        group   = augroup,
        pattern = "cgxx.treesitter.complete", -- When ../spec/nvim-treesitter:180 has initialised
        desc    = "Open and close fold markers and return to last position",
        callback = function()
            fold_logic()
            last_position()
        end,
    })
end

M.setup = function()
    --autosave()  -- May consider writing to a temp file rather than the original
    --fold_state_last_pos()
end

return M
