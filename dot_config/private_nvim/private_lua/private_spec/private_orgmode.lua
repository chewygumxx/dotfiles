-- vim: foldlevel=1:foldmethod=expr:

--
--
-- ~/.config/nvim/lua/spec/orgmode.lua
--
--

return {
    'nvim-orgmode/orgmode',
    
    ft = { 'org' },
    
    config = function()
        -- Setup orgmode
        require('orgmode').setup({
            org_agenda_files = '~/nexus/orgmode/**/*',
            org_default_notes_file = '~/nexus/orgmode/refile.org',
        })
        
        -- NOTE: If you are using nvim-treesitter with ~ensure_installed = "all"~ option
        -- add ~org~ to ignore_install
        -- require('nvim-treesitter.configs').setup({
        --   ensure_installed = 'all',
        --   ignore_install = { 'org' },
        -- })
    end,
}
