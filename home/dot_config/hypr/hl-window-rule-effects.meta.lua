#!/bin/false
-- vim:set expandtab shiftwidth=4 filetype=lua:
-- SPDX-License-Identifier: GPL-3.0-only

--
--
-- ~chewygumxx/dotfiles.git
-- ::: :/home/dot_config/hypr/hl-window-rule-effects.meta.lua
--
--

--
-- The stub Hyprland ships (/usr/share/hypr/stubs/hl.meta.lua) only declares
-- name, match, and enabled on HL.WindowRuleSpec: its generator doesn't yet
-- reflect the window rule "effect" properties documented at
-- https://wiki.hypr.land/Configuring/Window-Rules/. This reopens the class
-- (LuaCATS merges same-named ---@class declarations) to add only the effect
-- fields window_workspace_rules.lua actually sets, so lua_ls stops flagging
-- working config as unknown fields and checks their value types (a
-- misspelled key in a table literal still goes unreported). `size` also
-- takes [number, number]: emmylua misreads HL.Vec2Like's {number, number}
-- as a table keyed "number". Add a field here when a rule starts using it.
-- Delete once upstream's scripts/generateLuaStubs.py covers rule effects.
--

---@meta

---@class HL.WindowRuleSpec
---@field float?             boolean
---@field center?            boolean
---@field size?              HL.Vec2Like | [number, number]
---@field workspace?         HL.WorkspaceSelector
---@field no_initial_focus?  boolean
---@field focus_on_activate? boolean
