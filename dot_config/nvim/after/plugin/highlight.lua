--
--
-- ~/.config/nvim/lua/config/highlight.lua
--
--

local M = {}

-- Highlight Table
M.hlg_tbl = {
    -- Background Transparency and Anti-Eye Strain
    { "Normal",     { ctermbg   = "none",    fg = "#cad6ff", bg = "none",   } },
    { "Search",     { bold      = true,      fg = "#e0e8ff", bg = "#52408f" } },
    { "Title",      { bold      = true,      fg = "#cad6ff" } },
    { "NonText",    { ctermbg   = "none",    bg = "none"    } },
    { "Underlined", { underline = true } },

    -- Anti-Boundary Character
    { "MatchParen", { standout = true } },

    -- Define @markup Underline, Bold and Strikethrough
    { "@markup.strong",        { bold          = true } },
    { "@markup.underline",     { underline     = true } },
    { "@markup.strikethrough", { strikethrough = true } },

    -- KDL
    { "@type.kdl",                  { link = "@property" } },
    { "@punctuation.bracket.kdl",   { link = "PreProc"   } },
    { "@punctuation.delimiter.kdl", { link = "Macro"     } },

    -- Zsh
  --{ "zshOperator",    { link = "Operator"                  } },
  --{ "zshSubstDelim",  { link = "@punctuation.special.bash" } },
  --{ "zshTypes",       { link = "@keyword"                  } },
  
  --{ "zshVariableDef", { link = "@constant"      } },
  --{ "zshVariableDef", { link = "@property"      } },
  --{ "zshDeref",       { link = "Question"       } },
  --{ "zshShortDeref",  { link = "zshVariableDef" } },
 
  --{ "zshCommands",    { link = "@function.call" } },

  --{ "zshFunction",    { link = "@function"      } },
  --{ "zshKSHFunction", { link = "zshFunction"    } },


}

function M.setup()
    for _, hlg_setting in ipairs(M.hlg_tbl) do
        vim.api.nvim_set_hl(0, hlg_setting[1], hlg_setting[2])
    end
end

return M
