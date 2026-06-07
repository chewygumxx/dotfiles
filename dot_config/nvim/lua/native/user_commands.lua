-- vim: expandtab:shiftwidth=4:tabstop=4

--
--
--~/.config/nvim/lua/config/commands.lua
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
        local abominable_extension_validation = function(filepath)
            if filepath:match("%.log%.ansi$") ~= nil then  -- someangel?
                if filepath:match("%.log$") then           -- something.log
                    return filepath .. ".ansi"

                elseif filepath:match("%.ans$") then       -- somethink?.ans
                    if filepath:match("%.log%.ans$") then  -- somewhore.log.ans
                        return filepath .. "i"        

                    else                                   -- somequeen.ans
                        return filepath:gsub("(.-)%.ans$", "%1.log.ansi")
                    end
                elseif filepath:match("%.ansi$") then      -- somewhose.ansi
                    return filepath:gsub("(.-)%.ansi$", "%1.log.ansi")

                elseif filepath:match("%.$") then          -- somehomie.
                    return filepath .. "log.ansi"

                else                                       -- somebooty
                    return filepath .. ".log.ansi"
                end
            else
                return filepath
            end
        end
        local abominable_collision_prevention = function(filepath_requested) 
            local query_fp = filepath_requested
            if vim.fs.exists(query_fp) == nil then
                return query_fp
            end

            -- Validate basename hyphen delimited from uniquify number
            if not query_fp:match(".*%-[%d]-%.log%.ansi$") then 
                query_fp = query_fp:gsub("(.*)%.log%.ansi$", "%1-0.log.ansi")
            end

            while vim.fs.exists(query_fp) do
                query_fp = query_fp:gsub("(.-)%--([%d]-)%.log%.ansi$", function(basename, number_reserved)
                    new_number = number_reserved or -1 + 1
                    return basename .. "-" .. tostring(new_number) .. ".log.ansi"
                end)
            end

            return query_fp
        end
        local decent_extension_validation = function(filepath)
            if filepath:match("%.log%.ansi$") then
                return filepath
            end


            local ext_valid = ".log.ansi"
            local ext_invalid = {
                ".ansi",
                ".ans",
                ".log",
                ".txt",
                ".out",
            }

            -- Split file extensions into inspectable fields
            local fp_exts = {}
            for ext in filepath:gmatch("^.+(%.[^.]*)") do
                table.insert(fp_exts, ext)
            end

            if #fp_exts == 0 then              -- No extensions
                return filepath .. ext_valid
            end
            
            for i=#fp_exts, 1, -1 do           -- Start from the last extension
                for j=1,#ext_invalid,1 do
                    if fp_exts[i] ~= nil and fp_exts[i] == ext_invalid[j] then
                        table.remove(fp_exts, i)
                    end
                end
            end

            local basename = filepath:match("^([^.]*)%.")
            table.insert(fp_exts, basename, 1)
            table.insert(fp_exts, ext_valid)

            return table.concat(fp_exts, "")   -- Preceeding periods of extension strings persist
        end
        local poor_collision_prevention = function(filepath_requested)
            -- The only differentiation this collision prevention function is capable 
            -- is the increment of a number appended to the basename.
            --
            -- It's not much better than the last.
            
            local target_dir  = vim.fs.dirname(filepath_requested)
            local fn_req      = filepath_requested:match("[^/](.*)$")
            local fn_template = fn_req:gsub("^(.-)%--(%d-)%.(.-%.log%.ansi)$", function(base, num, ext)
                return { base = base, num = num, ext = ext }
            end)

            local fn_resemblance   = {}
            for file in vis.fs.dir(target_dir) do
                table.insert(fn_resemblance, file:gsub("^(.-)%--(%d-)%.(.-%.log%.ansi)$",
                    function(base, num, ext) return { base = base, num = num, ext = ext } end
                ))
            end

            local reserved_uniquifiers = {}
            for i=1,#fn_resemblance,1 do
                if  fn_resemblance[i].ext  == fn_template.ext
                and fn_resemblance[i].base == fn_template.base then
                    table.insert(reserved_uniquifiers, fn_resemblance[i].num)
                end
            end

            if #reserved_uniquifiers == 0 then return filepath_requested end
            table.sort(reserved_uniquifiers)
            local uniquifier = tonumber(reserved_uniquifiers[#reserved_uniquifiers]) + 1

            return target_dir .. "/" .. fn_template.base .. uniquifier .. fn_template.ext
        end
        local save_preinterpreted_copy = function()
            -- Save Directory Validation
            local log_dir = vim.fn.stdpath("cache") .. "/log-ansi/"
            if not vim.fn.isdirectory(log_dir) then vim.fn.mkdir(log_dir, "p") end

            -- Filename of Saved Copy 
            local filename_of_current_file = vim.fn.expand("%:t")
            local ansi_filepath_ungendered = log_dir .. filename_of_current_file

            -- Extension Handling
            local ansi_filepath_extension  = decent_extension_validation(ansi_filepath_ungendered)
    
            -- Filename Collision 
            local ansi_filepath_uniquified = poor_collision_prevention(ansi_filepath_extension)
        
            -- Write
            --vim.fs.copy()
            if vim.uv.fs_copyfile(
                vim.fn.expand("%:p"),
                vim.fs.normalize(ansi_filepath_uniquified)
            ) == nil then
                vim.notify("Failed to copy file with vim.uv.fs_copyfile()")
                local handle  = io.open(ansi_filepath_uniquified, "wc+")
                handle:write(table.concat(lines, "\r\n"))
                handle:flush()
                handle:close()
            end
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
        
            -- Save copy with original pre-interpretation escape codes
            -- Unless command invoked with bang, then fuck it
            if bang == false then
                save_preinterpreted_copy()
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

local defunct = {
	-- {{{!CLOSE

    Term = function()
        -- Interpret ANSI Escape Codes
        -- Employed for Neovim as terminal pager (see $PAGER)
        -- - PAGER='nvim -R - +Term'
        vim.api.nvim_create_user_command("Term", function(args)
            local buf  = vim.api.nvim_get_current_buf()
            local b    = vim.api.nvim_create_buf(false, true)
            local chan = vim.api.nvim_open_term(b, {})
            
            vim.api.nvim_chan_send(chan, 
                table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n"))
            vim.api.nvim_win_set_buf(0, b)
        end, { desc = "Interpret ANSI Escape Codes, employed for Neovim as terminal buffer"})
    end,
    Term_2 = function()
    	vim.api.nvim_create_user_command("Term", function()
    		local buf = vim.api.nvim_get_current_buf()
    		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    		local input = table.concat(lines, "\n")
    		local b = vim.api.nvim_create_buf(false, true)
    		local chan = vim.api.nvim_open_term(b, {})
    		vim.api.nvim_win_set_buf(0, b)
    		vim.schedule(function()
    			vim.api.nvim_chan_send(chan, input)
    		end)
    	end, { desc = "Render ANSI escape codes" })
    end,
    -- Redirect command output to new window empty buffer
    RedirToNewWindow = function()
        vim.api.nvim_create_user_command(
            'Redir', 
            function(ctx)
                local lines = vim.split(
                    vim.api.nvim_exec(ctx.args, true), '\n', { plain = true })
                vim.cmd('new')
                vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
                vim.opt_local.modified = false
        end, 
        { nargs = '+', complete = 'command' })
    end,
    
    -- Prepends current buffer with filetype-based header template
    -- CAUTION: Overwrites whatever was once there
    PrependHeader = function()
        vim.api.nvim_create_user_command(
            'PrependHeader', 
            function()
                local generated_header = require("snippets").ft.template
                vim.api.nvim_buf_set_lines(
                    0,                    -- Current Buffer
                    0,                    -- First Line Index (Inclusive)
                    #generated_header,    -- Last Line Index (Exclusive)
                    false,                -- Out-of-Bounds returns error?
                    generated_header)    -- Lines to be printed (replaces)
            end, 
            { 
                desc = 'Prepend current buffer with lua=snippets.ft.template',
                force = false,    -- If somehow command exists, don't replace it.
            }
        )
    end,

    -- Prints pre-configured vim modlines to message buffer for :redir
    PrintModlines = function()
        vim.api.nvim_create_user_command(
            'PrintModlines',
            function()
                for _, line in ipairs(require("snippets").vim_modlines) do
                    print(line)
                end
            end,
            {
                desc = "Print vim modline template to message buffer, (for :redir)",
            }
        )
    end,

    -- Alias for `:lua MiniFiles.open()` of mini.nvim
    FileSys = function()
        vim.api.nvim_create_user_command("FileSys",
            function(args) MiniFiles.open() end,
            { desc = "Open FS management popup buffer of mini.files" })
    end,
}

return M

