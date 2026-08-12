-- vim:

--
--
-- ~/.config/nvim/lua/native/user_commands.lua
--
--

local M = {}

local user_commands = {
    CGVisNav = function()
        -- Toggle visual line traversal
        vim.b.CGVisNav = false
        local toggle_visual_navigation = function()
            if vim.b.CGVisNav == true then
                vim.b.CGVisNav = false

                vim.api.nvim_buf_set_keymap(0, '', 'j', 'j', { desc = "", noremap = true })
                vim.api.nvim_buf_set_keymap(0, '', 'j', 'j', { desc = "", noremap = true })

                vim.print("Visual Line Navigation: OFF")
            else
                vim.b.CGVisNav = true

                local desc = "Visual line traversal (:CGVisNav)"
                vim.api.nvim_buf_set_keymap(0, '', 'j', 'gj', { desc = desc, noremap = true })
                vim.api.nvim_buf_set_keymap(0, '', 'k', 'gk', { desc = desc, noremap = true })

                vim.print("Visual Line Navigation: ON")
            end
        end
        vim.api.nvim_create_user_command("CGVisNav", toggle_visual_navigation, {
            desc = "Toggle visual line navigation in current buffer",
        })
    end,
    CGRedirAwkwardPager = function()
        -- {{{!CLOSE
        -- Redirect nofile buffer helpers for :map, :highlight, :autocmd on BANG!

        -- Neovim commands that utilise awkward pager
        local awkward_cmds = {
            "map",
            "highlight",
            "autocmd",
            "command"
        }

        -- Redirects output of a given command to a new temp buffer
        local function redirect(cmd, args, bang)
            -- If any arguments were supplied or command NOT executed with "!"
            -- execute command normally
            if args ~= "" or not bang then vim.cmd(cmd .. " " .. args) return end

            vim.cmd("enew")
            vim.bo.buftype    = "nofile"
            vim.bo.bufhidden  = "wipe"
            vim.bo.swapfile   = false
            vim.keymap.set("n", "q", "<cmd>bwipeout!<CR>", {
                buffer = true,
                desc = "Quit temp redirect buffer"
            })

            local output = vim.api.nvim_exec2(cmd, { output = true }).output
            vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, "\n"))
            vim.cmd("1")
            vim.bo.modifiable = false
            vim.bo.readonly   = true
        end

        for _, cmd in ipairs(awkward_cmds) do
            local user_cmd = "CGRedir" .. cmd:gsub("^%l", string.upper)

            vim.api.nvim_create_user_command(user_cmd, function (o) redirect(cmd, o.args, o.bang) end, {
                desc = "Redirects ':" .. cmd .. "' to temp buffer",
                nargs = "*",
                bang = true
            })

            -- Auto-substitute awkward command at command line
            vim.cmd.cnoreabbrev(cmd .. " " .. user_cmd)
        end
    end,
    CGInterpretEscape = function()
        local save_preinterpreted_copy = function(lines)
            -- Save Directory 
            local log_dir = vim.fn.stdpath("cache") .. "/log-ansi/"
            if not vim.fn.isdirectory(log_dir) then vim.fn.mkdir(log_dir, "p") end

            -- If filename has a tail, remove it.
            -- Irrespective of whether filename had tail or not, append '.ansi'.
            -- Awkward if no head
            local filename = vim.fn.expand("%:t"):gsub("^(.-)(%.[^%.]*)$", "%1") .. ".ansi"

            -- Write
            local handle  = io.open(log_dir .. filename, "wc+")
            handle:write(table.concat(lines, "\r\n"))
            handle:flush()
            handle:close()
        end

        local interpret_escape = function(bang)
            vim.wo.number = false               -- < Prepare buffer of equivalent columns to source
            vim.wo.relativenumber = false       -- <
            vim.wo.statuscolumn = ""            -- <
            vim.wo.signcolumn = "no"            -- <
            vim.opt.listchars = { space = " " } -- :h list
        
            -- Omit empty lines. Trim whitespace, and other characters from both start and end of line.
            -- :h trim()
            local buf = vim.api.nvim_get_current_buf()
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            while #lines > 0 and vim.trim(lines[#lines]) == "" do 
                lines[#lines] = nil
            end
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
        
            -- Save copy with original pre-interpretation escape codes.
            -- If command invoked with bang, then fuck it, no save.
            if bang == false then
                save_preinterpreted_copy(lines)
            end

            local function translate_ansi_colons(lines)
                -- For future me when this breaks 
                --
                -- Chained parameters in a single sequence — something like \e[1;38:2::15:225:146m
                -- (bold + truecolour in one CSI sequence) won't match because the outer pattern
                -- requires the entire parameter string to be the truecolour form. This is probably
                -- the most realistic gap depending on what's generating the escape codes. If you
                -- want to handle it, I'd need to match within a broader CSI sequence and substitute
                -- only the matching subportion, which complicates things considerably. Worth checking
                -- whether the actual input ever chains parameters like that before investing in it.
                return vim.tbl_map(function(line)
                  line = line:gsub("\027%[([%d]+:2::[%d]+:[%d]+:[%d]+)m", function(params)
                      local out = params:gsub("(%d+):2::(%d+):(%d+):(%d+)", "%1;2;%2;%3;%4")
                      return "\027[" .. out .. "m"
                  end)
                  return line

                end, lines)
            end
          
            lines = translate_ansi_colons(lines)
          
            vim.api.nvim_chan_send(vim.api.nvim_open_term(buf, {}), table.concat(lines, "\r\n"))
            vim.keymap.set("n", "q", "<cmd>qa!<cr>", { silent = true, buffer = buf })
            vim.api.nvim_create_autocmd("TextChanged", { buffer = buf, command = "normal! G$" })
            vim.api.nvim_create_autocmd("TermEnter", { buffer = buf, command = "stopinsert" })
        end

        vim.api.nvim_create_user_command("CGInterpretEscape", function(cmd_tbl) interpret_escape(cmd_tbl.bang) end , {
            desc = "Translate and interpret escape codes in terminal buffer",
            bang = true,
        })
    end
}
user_commands.setup = function(self)
    self:CGVisNav()
  --self:CGRedirAwkwardPager()
    self:CGInterpretEscape()
end

function M.setup()
    user_commands:setup()
end

M.setup()

return M

