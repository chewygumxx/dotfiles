#!/bin/false
-- vim: expandtab:shiftwidth=4

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/nvim/after/ftplugin/markdown.lua
--
--

--
-- Markdown filetype settings
--

vim.bo.shiftwidth = 2

local hlgroup_defs = {
    ["@markup.heading"]      = { fg = "#aaa6fa", bold = true },
    ["@markup.heading.1"]    = { fg = "#7fb5ff", bold = true },
    ["@markup.heading.2"]    = { fg = "#8394f6", bold = true },
    ["@markup.heading.3"]    = { fg = "#8874ed", bold = true },
    ["@markup.heading.4"]    = { fg = "#8d53e5", bold = true },
    ["@markup.heading.5"]    = { fg = "#9233dc", bold = true },
    ["@markup.heading.6"]    = { fg = "#7408cf", bold = true },

    ["@markup.link.text"]    = { link = "@function.call" },
    ["@markup.link.label"]   = { link = "@property" },
    ["@markup.link.url"]     = { fg = "#6f25f6", underline = true },
    ["@markup.link.bracket"] = { fg = "#4408a4", underline = false },

    ["@markup.list.markdown"] = { link = "@markup.heading" },

    ["@punctuation.special"] = { fg = "#7408c4" },
    ["@_label.markdown_inline"] = { link = "@punctuation.special" },
}

for hlgroup, defmap in pairs(hlgroup_defs) do
    vim.api.nvim_set_hl(0, hlgroup, defmap)
end

