-- vim:

--
--
-- ~/.config/nvim/lua/spec/comment.nvim.lua 
--
--

local M = {
    "numtostr/comment.nvim",
    enabled = true,
}

M.opts = {
    padding = false,    -- Add a space between comment and content
    sticky  = true,     -- Whether the cursor should remain at its position
    ignore  = nil,      -- Lines ignored
                           
    -- Toggle mappings in NORMAL
    toggler = {
        line  = 'gcc',
        block = 'gbc',
    },                     

    -- Operator-pending mappings in NORMAL and VISUAL
    opleader = {
        line  = 'gc',
        block = 'gb',
    },                     
                           
    extra = {           
        above = 'gcO',  -- Add comment on the line above
        below = 'gco',  -- Add comment on the line below
        eol   = 'gcA',  -- Add comment at the end of line
    },
    
    mappings = {        -- Enable keybindings
        basic = true,   -- Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
        extra = true,   -- Extra mapping; `gco`, `gcO`, `gcA`
    },                     
                           
    pre_hook  = nil,    -- Function called before
    post_hook = nil,    -- Function called after 
}

return M
