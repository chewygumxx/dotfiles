--
--
-- ~/.config/nvim/lua/plugin_config/neorg_highlights.lua
--
--

local M = {}

-- Array of tables, where each table defines hlgs
-- See M.setup() and M.prep_settings_array()
M.settings_array = { 
    { "@neorg.todo_items.undone.norg",    { fg = "#606060" } },
    { "@neorg.todo_items.done.norg",      { fg = "#66d9af" } },
    { "@neorg.todo_items.cancelled.norg", { fg = "#DC143C" } },
}

-- * Lists
M.lists = {
    prefix_array = {"@neorg.lists.unordered", "@neorg.lists.ordered"},
    settings_by_tier = {
        { fg = "#7fb5ff" },
        { fg = "#8394f6" },
        { fg = "#8874ed" },
        { fg = "#8d53e5" },
        { fg = "#9233dc" },
        { fg = "#7408c4" },
    },
}

function M.lists:define_paragraph_segment()
    for index, prefix in ipairs(self.prefix_array) do
        for tier, tier_setting in ipairs(self.settings_by_tier) do
            local hlg_setting = {
                string.format(
                    "%s.%i.%s", prefix, tier, "paragraph_segment.norg"),
                tier_setting
            }
            
            table.insert(M.settings_array, hlg_setting)
        end
    end
end

-- Defines the prefix to link to its symmetrically opposing paragraph segment
--     Links 6 to 1, 5 to 2, ... 1 to 6
--     Must be called *after* M.lists:define_paragraph_segment()
function M.lists:prefix_link_paragraph_segment()
    for index, prefix in ipairs(self.prefix_array) do
        for tier = 6, 1, -1 do
            local hlg_setting = { 
                string.format("%s.%i.%s", prefix, tier, "prefix.norg"),
                { link = string.format(
                    "%s.%i.%s", prefix, 7 - tier, "paragraph_segment.norg") }
            }
            
            table.insert(M.settings_array, hlg_setting)
        end
    end
end


-- * Setup
function M.prep_settings_array()
    M.lists:define_paragraph_segment()
    M.lists:prefix_link_paragraph_segment()
    
    return M.settings_array
end

function M.setup()
    for _, hlg_setting in ipairs(M.prep_settings_array()) do
        vim.api.nvim_set_hl(0, hlg_setting[1], hlg_setting[2])
    end
    for index = 1, #M.settings_array, 1 do
        local hlg_setting = M.settings_array[index]
        vim.api.nvim_set_hl(0, hlg_setting[1], hlg_setting[2])
    end
end

return M
