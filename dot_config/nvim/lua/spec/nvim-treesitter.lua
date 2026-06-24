-- vim: foldmethod=expr:

--
--
-- ~/.config/nvim/lua/spec/nvim-treesitter.lua
--
--

--
-- https://github.com/nvim-treesitter/nvim-treesitter
--

---@module "lazy"
---@type LazySpec
local M = {
    'nvim-treesitter/nvim-treesitter',
    enabled = true,

    branch  = 'main',
    lazy    = false,
    build   = ':TSUpdate',
}

local ensure_installed = {
    -- https://github.com/nvim-treesitter/nvim-treesitter/blob/main/SUPPORTED_LANGUAGES.md

    "bash",
    -- https://github.com/tree-sitter/tree-sitter-bash

    "comment",
    -- https://github.com/stsewd/tree-sitter-comment

    "css",
    -- https://github.com/tree-sitter/tree-sitter-css

    "csv",
    -- Also tsv and psv
    -- https://github.com/tree-sitter-grammars/tree-sitter-csv

    "desktop",
    -- For both .desktop and .directory files
    -- https://github.com/ValdezFOmar/tree-sitter-desktop
    -- https://specifications.freedesktop.org/desktop-entry-spec/latest/index.html

    "html",
    -- https://github.com/tree-sitter/tree-sitter-html

    "ini",
    -- https://github.com/justinmk/tree-sitter-ini

    "javascript",
    -- https://github.com/tree-sitter/tree-sitter-javascript

    "json",
    -- https://github.com/tree-sitter/tree-sitter-json

    "json5",
    -- https://github.com/Joakker/tree-sitter-json5

    "kdl",
    -- https://github.com/tree-sitter-grammars/tree-sitter-kdl

    "lua",
    -- https://github.com/tree-sitter-grammars/tree-sitter-lua

    "luadoc",
    -- https://github.com/tree-sitter-grammars/tree-sitter-luadoc

    "luap",
    -- Lua Patterns
    -- https://github.com/tree-sitter-grammars/tree-sitter-luap

    "markdown",
    -- https://github.com/tree-sitter-grammars/tree-sitter-markdown

    "markdown_inline",
    -- https://github.com/tree-sitter-grammars/tree-sitter-markdown

    "nix",
    -- https://github.com/nix-community/tree-sitter-nix

    "perl",
    -- https://github.com/tree-sitter-perl/tree-sitter-perl

    "printf",
    -- https://github.com/tree-sitter-grammars/tree-sitter-printf

    "python",
    -- https://github.com/tree-sitter/tree-sitter-python

    "query",
    -- Treesitter query language
    -- https://github.com/tree-sitter-grammars/tree-sitter-query

    "regex",
    -- https://github.com/tree-sitter/tree-sitter-regex

    "sql",
    -- https://github.com/derekstride/tree-sitter-sql

    "tmux",
    -- https://github.com/Freed-Wu/tree-sitter-tmux

    "toml",
    -- https://github.com/tree-sitter-grammars/tree-sitter-toml

    "tsx",
    -- https://github.com/tree-sitter/tree-sitter-typescript

    "typescript",
    -- https://github.com/tree-sitter/tree-sitter-typescript

    "vim",
    -- https://github.com/tree-sitter-grammars/tree-sitter-vim

    "vimdoc",
    -- https://github.com/neovim/tree-sitter-vimdoc

    "xml",
    -- https://github.com/tree-sitter-grammars/tree-sitter-xml

    "yaml",
    -- https://github.com/tree-sitter-grammars/tree-sitter-yaml

    "zsh",
    -- https://github.com/georgeharker/tree-sitter-zsh

}
local ignore_filetypes = {
    'checkhealth',
    'lazy',
    'qf',   -- QuickFix
    'mason',
    'snacks_dashboard',
    'snacks_notif',
    'snacks_win',
    'text',
    'man',
}

-- Ripped this from:
-- https://www.reddit.com/r/neovim/comments/1pndf9e/my_new_nvimtreesitter_configuration_for_the_main/
M.config = function()
    local ts = require('nvim-treesitter')

    vim.treesitter.language.register('ini', 'systemd')

    -- Install core parsers after lazy.nvim finishes loading all plugins
    vim.api.nvim_create_autocmd('User', {
        pattern  = 'LazyDone',
        callback = function() ts.install(ensure_installed, { max_jobs = 8,})  end,
        once     = true,
    })

    -- State tracking for async parser loading
    local parsers_loaded  = {}
    local parsers_pending = {}
    local parsers_failed  = {}

    -- Helper to start highlighting and indentation
    local start = function(buf, lang)
        local ok = pcall(vim.treesitter.start, buf, lang)
        if ok then
            if vim.treesitter.query.get(lang, "indents") then
                vim.bo.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
            end
            if vim.treesitter.query.get(lang, "folds") then
                vim.wo.foldexpr   = "v:lua.vim.treesitter.foldexpr()"
              --vim.wo.foldmethod = "expr"
            end
        end
        return ok
    end

    -- Decoration provider for async parser loading
    vim.api.nvim_set_decoration_provider(vim.api.nvim_create_namespace('treesitter.async'), {
        on_start = vim.schedule_wrap(function()
            if #parsers_pending == 0 then
                return false
            end

            for _, data in ipairs(parsers_pending) do
                if vim.api.nvim_buf_is_valid(data.buf) then
                    if start(data.buf, data.lang) then
                        parsers_loaded[data.lang] = true
                    else
                        parsers_failed[data.lang] = true
                    end
                end
            end
            parsers_pending = {}
        end),
    })

    -- Auto-install parsers and enable highlighting on FileType
    vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('TreesitterSetup', { clear = true }),
        desc = 'Enable treesitter functionality',
        callback = function(event)
          --vim.notify(require('inspect')(event), vim.log.levels.INFO)

            -- Filesize Limit
            local megabyte = 1024 * 1024
            if vim.fn.getfsize(event.file) > (vim.g.large_filesize or megabyte) then
                vim.notify("Filesize exceeded treesitter limit: (see \"Filesize Limit\" of spec/nvim-treesitter.lua)", 
                    vim.log.levels.INFO)
                return
            end

            -- Filetype Ignore
            if vim.tbl_contains(ignore_filetypes, event.match) then
                return
            end

            local lang = vim.treesitter.language.get_lang(event.match) or event.match
            local buf  = event.buf

            if parsers_failed[lang] then
                vim.notify("Treesitter parser failed for lang: " .. lang, vim.log.levels.WARN)
                return
            end

            if parsers_loaded[lang] then
                -- Parser already loaded, start immediately (fast path)
                start(buf, lang)
            else
                -- Queue for async loading
                table.insert(parsers_pending, { buf = buf, lang = lang })
            end

            -- Auto-install missing parsers (async, no-op if already installed)
            ts.install({ lang })
        end,
    })
end

return M
