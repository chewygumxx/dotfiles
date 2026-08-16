#!/bin/false
-- vim: expandtab:shiftwidth=4:filetype=lua:

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/dot_config/nvim/lua/usercmd/init.lua
--
--

--
-- Authoritative user command creation and definition
--

local M = {}

local def_usercmd = vim.api.nvim_create_user_command

local visual_traversal = function()
    local desc = "Visual traversal in current buffer"
    local vt   = require("util.visual_traversal").command
    def_usercmd("XXVisTrav",        vt("toggle"),  { desc = "Toggle: "  .. desc })
    def_usercmd("XXVisTravToggle",  vt("toggle"),  { desc = "Toggle: "  .. desc })
    def_usercmd("XXVisTravEnable",  vt("enable"),  { desc = "Enable: "  .. desc })
    def_usercmd("XXVisTravDisable", vt("disable"), { desc = "Disable: " .. desc })
end

local interpret_escape = function()
    local desc = "Translate and interpret escape codes in terminal buffer"
    local ie   = require("usercmd.interpret_escape")
    def_usercmd("XXInterpretEscape", ie.command, { desc = desc, bang = true, })
end

local redirect_awkward_pager = function()
    local desc    = "Redirect to temporary buffer (bypass bang!): "
    local vimcmds = { "autocmd", "command", "highlight", "map" }
    local rap     = require("usercmd.redirect_awkward_pager").command
    for _, vimcmd in ipairs(vimcmds) do
        local capitalvcmd, _ = vimcmd:gsub("^%l", string.upper)
        def_usercmd("XXRedir" .. capitalvcmd, rap(vimcmd), {
            desc  = desc .. vimcmd,
            nargs = "*",
            bang  = true
        })
        -- Only abbreviate when vimcmd is in the command position and is
        -- invoked as the command itself
        vim.cmd(("cnoreabbrev <expr> %s (getcmdtype() == ':' && getcmdline() == '%s') ? 'XXRedir%s' : '%s'")
            :format(vimcmd, vimcmd, capitalvcmd, vimcmd))   
    end
end

local insert_header = function()
    local desc = "Prepend buffer with a header, templated according to filepath and extension."
    local ih   = require("util.header")
    vim.api.nvim_create_user_command("XXInsertHeader", ih.command, { desc = desc })
end

M.setup = function()
    visual_traversal()
    interpret_escape()
    redirect_awkward_pager()
    insert_header()
end

return M
