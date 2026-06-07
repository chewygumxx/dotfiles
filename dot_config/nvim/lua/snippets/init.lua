--
--
-- ~/.config/nvim/lua/snippets/init.lua
--
--

local M = {}

M.vim_modlines = {
    "vim: noexpandtab:tabstop=4:shiftwidth=4:textwidth=80",
    "vim: foldlevel=2:foldmethod=expr",
}

-- Filetype Derived
M.ft = (function ()
    -- Filetype table of shebangs and single-line comment start and end
    local ft_tbl = {
        bash = {"#!/usr/bin/env bash",    "#",  ""},
        zsh  = {"#!/usr/bin/env zsh",     "#",  ""},
        sh   = {"#!/usr/bin/env sh",      "#",  ""},
        py   = {"#!/usr/bin/env python3", "#",  ""},
        lua  = {"#!/usr/bin/env lua",     "--", ""},
        sql  = {"#!/usr/bin/env sqlite3", "--", ""},
    }
    
    local function resolve_shebang_and_comment_tokens()
        local ft = vim.bo.filetype
        
        -- If current filetype has no entry in filetype table, return nil
        if ft_tbl[ft] == nil then return nil, nil end
        
        local shebang = ft_tbl[ft][1]
        local comment = {
            start = ft_tbl[ft][2],
            finish = ft_tbl[ft][3]
        }
        
        return shebang, comment
    end

    local shebang, comment = resolve_shebang_and_comment_tokens()
    -- If function returns nil for both, no entry in filetype table exists
    -- Return nil
    if shebang == nil and comment == nil then return nil end
    
    local function generate_titlecard(line_height)
        -- Relative filepath from home directory
        local rel_fp = require("global").rel_fp.home
        -- Titlecard following shebang and vim modlines
        local titlecard = {}
        
        -- If line_height number is even
        if math.fmod(line_height, 2) == 0 then 
            -- Make it odd
            line_height = line_height + 1
        end
        
        -- Line the filepath/title will be printed upon
        local median_line_number = math.ceil(line_height/2)
        
        for line_number=1,line_height,1 do
            local append = ""
            if line_number == median_line_number then
                -- Insert relative filepath as title if it's the middle line
                append = " " .. rel_fp
            end
            table.insert(titlecard, comment.start .. append)
        end
        
        return titlecard
    end
    local titlecard = generate_titlecard(5)
    
    local function generate_template()
        -- Template file header at beginning of file
        local template = {}
        
        -- Insert Shebang
        if shebang ~= "" then table.insert(template, shebang) end
        
        -- Insert `vim: :option:` Modlines
        for _, modline in ipairs(M.vim_modlines) do
            table.insert(template, comment.start .. " " .. modline)
        end
        
        -- Insert Empty Line (spacing between metadata and titlecard)
        table.insert(template, "")
        local empty_line_pos = #template
        
        -- Insert Titlecard
        for index, line in ipairs(titlecard) do
            table.insert(template, line)
        end
        
        -- Append tabspace padding and comment.finish to each line with content 
        -- (shebang excepted)
        local textwidth = vim.opt.textwidth
        if comment.finish ~= "" then -- if commend.finish even exists
            for index, line in ipairs(template) do
                if index == 1 and line[2] == '!' or index == empty_line_pos then
                    -- Skip shebang 
                    -- Skip empty line
                else
                    local empty_space = textwidth - (#line + #comment.finish)
                    local number_of_tabspaces = (empty / 4) + 1
                    local padding = string.rep("\t", number_of_tabspaces)
                    
                    template[index] = line .. padding .. comment.finish
                end
            end
        end
        
        return template
    end
    local template = generate_template()
    
    return {
        shebang = shebang, 
        comment = comment, 
        titlecard = titlecard,
        template = template
    }

end)()

return M
