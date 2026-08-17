#!/bin/false
-- vim: expandtab:shiftwidth=4

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/nvim/lua/filetype/markdown.lua
--
--

--
-- Markdown filetype settings
--

local M = {}

local opts = {
    shiftwidth = 2,
}

local hlgroup_defs = {
    ["@markup.heading"]      = { fg = "#aaa6fa", bold = true },
    ["@markup.heading.1"]    = { fg = "#7fb5ff", bold = true },
    ["@markup.heading.2"]    = { fg = "#8394f6", bold = true },
    ["@markup.heading.3"]    = { fg = "#8874ed", bold = true },
    ["@markup.heading.4"]    = { fg = "#8d53e5", bold = true },
    ["@markup.heading.5"]    = { fg = "#9233dc", bold = true },
    ["@markup.heading.6"]    = { fg = "#7408cf", bold = true },
    ["@markup.list"]         = { link = "@markup.heading.markdown" },


    -- Depends on custom 
    ["@markup.link.text"]    = { link = "@function.call" },
    ["@markup.link.text"]    = { link = "@function.call" },
    ["@markup.link.label"]   = { link = "@property" },
    ["@markup.link.url"]     = { fg = "#6f25f6", underline = true },
    ["@markup.link.bracket"] = { fg = "#4408a4", underline = false },

    ["@punctuation.special"] = { fg = "#7408c4" },
    ["@_label"]              = { link = "@punctuation.special.markdown" },
}

M.setup = function(file, buf)
    file = file or vim.fn.expand("%")
    buf  = buf  or 0

    for opt, value in pairs(opts) do
        vim.api.nvim_set_option_value(opt, value, { buf = buf })
    end
    for hlgroup, defmap in ipairs(hlgroup_defs) do
        vim.api.nvim_set_hl(0, hlgroup .. ".markdown",        defmap)
        vim.api.nvim_set_hl(0, hlgroup .. ".markdown_inline", defmap)
    end
end

return M
