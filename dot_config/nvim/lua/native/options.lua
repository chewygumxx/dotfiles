-- vim: expandtab:shiftwidth=4:textwidth=0

--
--
-- ~/.config/nvim/native/options.lua
--
--

local M = {}

M.opts = {
    -- System
    clipboard = "unnamedplus",
    undofile  = true,
    mouse = "",

    -- Tabspace
    expandtab  = true,
    shiftwidth = 4,
    tabstop    = 4,

    virtualedit = "block",
    --textwidth = 80,

    -- Color
    termguicolors = true,

    -- Margin
    number         = true,
    relativenumber = true,
    scrolloff      = 5,
    
    -- Show keystrokes right of message buffer
    showcmd = true,

    -- Break at word
    linebreak = true,

    -- Fold
    foldmethod = "expr",
    foldtext   = "v:lua.cgxx_foldtext()",
    fillchars  = "fold: ",
    foldlevel  = 2,

    -- Window Splitting
    splitright = true,

    -- Search:
    -- Ignore case unless uppercase provided.
    ignorecase = true,
    smartcase  = true,

    -- Restore view when jumping
    jumpoptions = "view",

    -- To defenstrate all sense of security and reason
  --modelineexpr = true,
}

_G.cgxx_foldtext = function()
    -- Buffer
    local tabstop   = vim.api.nvim_get_option_value("tabstop", {})
    if tabstop   == 0 then tabstop   = 4  end
    local textwidth = vim.api.nvim_get_option_value("textwidth", {})
    if textwidth == 0 then textwidth = 80 end

    -- Metadata
    local start = vim.v.foldstart           -- Line number of fold beginning
    local count = vim.v.foldend - start + 1 -- Fold size in lines
    local level = vim.v.foldlevel           -- Degree of fold nesting

    -- Label
    local label  = vim.fn.getline(start):gsub("\t", string.rep(" ", tabstop))
    local indent_pos = label:find("%S")
    local indent = indent_pos and (indent_pos - 1) or 0

    if indent >= 4 then
        label = label:gsub("^" .. string.rep(" ", indent), 
                string.rep(" ", indent - 4) .. "~~~ ")
    elseif indent == 2 then
        label = label:gsub("^  ",    "~ ")
    elseif indent == 1 then
        label = label:gsub("^ ",    "~")
    elseif indent == 3 then
        label = label:gsub("^   ",    "~~ ")
    end

    -- Info
    local fold_info    = string.format("[%d lines] [lvl=%i]", count, level)
    local alignment    = string.rep(" ", textwidth - #label - #fold_info - 1)

    return label .. alignment .. fold_info
end

M.setup = function()
    local set_nvim_options = function(nvim_opt_table)
        for opt, value in pairs(nvim_opt_table) do
            vim.api.nvim_set_option_value(opt, value, {})
        end
    end

    set_nvim_options(M.opts)
end

return M
