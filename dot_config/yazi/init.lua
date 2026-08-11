-- vim: expandtab:shiftwidth=4

--
--
-- ~/.config/yazi/init.lua
--
--

require("smart-enter"):setup { open_multi = true, }

-- No more status bar
require("no-status"):setup()

require("zoxide"):setup({ update_db = true })

local mux_setup = function()
    local mux_opts = {
        notify_on_switch = false,           -- Show notification when switching previews
        remember_per_file_extension = true, -- Show same previewer per extension
        aliases = {}
    }

    -- Directory
    local eza_tree = function()
        for i=1,3,1 do
            mux_opts.aliases["eza_tree_" .. i] = {
                previewer = "piper",
                args = { table.concat({
                    "printf \"\\e[0;35mRecursion Depth: \\e[0;32m" .. i .. "\\n\" &&",
                    "eza",
                    "--all",
                    "--tree",
                    "--level " .. i,
                    "--group-directories-first",

                    "--color=always",
                    "--icons=always",
                    "--no-quotes",
                    '"$1"' }, " ") }
            }
        end
    end
    local eza_tree_size = function()
        for i=1,3,1 do
            mux_opts.aliases["eza_tree_size_" .. i] = {
                previewer = "piper",
                args = { table.concat({
                    "printf \"\\e[0;95mRecursion Level: \\e[1;92m" .. i .. "\\n\" &&",
                    "eza",
                    "--all",
                    "--tree",
                    "--level " .. i,
                    "--group-directories-first",

                    "--color=always",
                    "--icons=always",
                    "--no-quotes",

                    "--long",
                    "--no-permissions",
                    "--no-user",
                    "--no-time",
                    "--total-size",
                    '"$1"' }, " ") }
            }
        end
    end

    local setup_aliases = function()
        eza_tree()
        --eza_tree_size()
    end 
    setup_aliases()

    require("mux"):setup(mux_opts)
end
mux_setup()

local time_format = function(time)
    if time == 0 then
        time = ""
	elseif os.date("%Y", time) == os.date("%Y") then
		time = os.date("%d/%m %H:%M", time)
	else
		time = os.date("%d/%m  %Y", time)
	end
    
    return time
end
function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
    time = time_format(time)

	local size = self._file:size()
	return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end
function Linemode:mtime()
	local time = math.floor(self._file.cha.mtime or 0)
    return time_format(time)
end

require("pref-by-location"):setup({
    disabled = false,
    
    no_notify = false,  -- Hide "enable" and "disable" notifications.
    
    -- Disable the fallback/default preference (values in `yazi.toml`).
    -- This mean if none of the saved or predifined perferences is matched,
    -- then it won't reset preference to default values in yazi.toml.
    -- For example, go from folder A to folder B (folder B matchs saved preference to show hidden files) -> show hidden.
    -- Then move back to folder A -> keep showing hidden files, because the folder A doesn't match any saved or predefined preference.
    -- disable_fallback_preference = false -- true|false|nil (Optional)
    
    -- You can backup/restore this file. But don't use same file in the different OS.
    save_path =  os.getenv("XDG_DATA_HOME") .. "/yazi/pref-by-location.savefile_or_whatever", -- full path to save file (Optional)
    
    -- https://github.com/MasouShizuka/projects.yazi compatibility
    -- If you use projects.yazi plugin and changed it's default yazi_load_event config, you have to set this value to equal projects.yazi > setup function > save > yazi_load_event. Default is "@projects-load"
    -- project_plugin_load_event = "@projects-load" -- string (Optional)
    
    -- This is predefined preferences.
    prefs = { -- (Optional)
        -- location: String | Lua pattern (Required)
        --   - Support literals full path, lua pattern (string.match pattern): https://www.lua.org/pil/20.2.html
        --     And don't put ($) sign at the end of the location. %$ is ok.
        --   - If you want to use special characters (such as . * ? + [ ] ( ) ^ $ %) in "location"
        --     you need to escape them with a percent sign (%) or use a helper funtion `pref_by_location.is_literal_string`
        --     Example: "/home/test/Hello (Lua) [world]" => { location = "/home/test/Hello %(Lua%) %[world%]", ....}
        --     or { location = pref_by_location.is_literal_string("/home/test/Hello (Lua) [world]"), .....}
        
        -- sort: {} (Optional) https://yazi-rs.github.io/docs/configuration/yazi#mgr.sort_by
        --   - extension: "none"|"mtime"|"btime"|"extension"|"alphabetical"|"natural"|"size"|"random", (Optional)
        --   - reverse: true|false (Optional)
        --   - dir_first: true|false (Optional)
        --   - translit: true|false (Optional)
        --   - sensitive: true|false (Optional)
        
        -- linemode: "none" |"size" |"btime" |"mtime" |"permissions" |"owner" (Optional) https://yazi-rs.github.io/docs/configuration/yazi#mgr.linemode
        --   - Custom linemode also work. See the example below
        -- show_hidden: true|false (Optional) https://yazi-rs.github.io/docs/configuration/yazi#mgr.show_hidden
        
        -- Some examples:
        -- Match any folder which has path start with "/mnt/remote/". Example: /mnt/remote/child/child2
        --{ location = "^/mnt/remote/.*", sort = { "extension", reverse = false, dir_first = true, sensitive = false} },
        -- Match any folder with name "Downloads"
        { location = ".*/net/.*", sort = { "mtime", reverse = true, dir_first = true },linemode = "mtime" },
    },
})

local folder_rules = function()
	ps.sub("ind-sort", function(opt)
		local cwd = cx.active.current.cwd

    	if tostring(cwd):find("/net/") then
			opt.by, opt.reverse, opt.dir_first = "mtime", true, true
		else
			opt.by, opt.reverse, opt.dir_first = "natural", false, true
		end
		return opt
	end)
end
--folder_rules()

