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

