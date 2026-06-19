-- vim: foldmethod=expr:

--
--
-- ~/.config/nvim/lua/spec/nvim-treesitter.lua
--
--

---@module "lazy"
---@type LazySpec
local M = {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy   = false,
    build  = ':TSUpdate',
}

local ensure_installed = {
    --{{{!CLOSE
    "bash",
    'comment',
    "css",
    "csv",  -- Also tsv and psv
    "desktop",
    "html",
    "ini",
    "javascript",
    "json",
    "json5",
    "kdl",
    "lua",
    "luadoc",
    "luap",
    "markdown",
    "markdown_inline",
    "nix",
    "perl",
    "printf",
    "python",
    "query",
    "regex",
    "sql",
    "tmux",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "xml",
    "yaml",
    "zsh",
}
local ignore_filetypes = {
    --{{{!CLOSE
    'checkhealth',
    'lazy',
    'qf',   -- Plugin jqx quickfix
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
            local megabyte = 1024 * 1024
            if vim.fn.getfsize(event.file) > (vim.g.large_filesize or megabyte) then
                vim.notify("Filesize exceeded treesitter limit: spec/nvim-treesitter.lua:142", 
                    vim.log.levels.INFO)
                return
            end

            if vim.tbl_contains(ignore_filetypes, event.match) then
                return
            end

            local lang = vim.treesitter.language.get_lang(event.match) or event.match
            local buf  = event.buf

            if parsers_failed[lang] then
                vim.notify("treesitter parser failed for lang: " .. lang, vim.log.levels.WARN)
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
