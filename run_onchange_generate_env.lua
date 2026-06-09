#!/usr/bin/env lua
-- vim: noexpandtab:tabstop=4:shiftwidth=4:textwidth=80

-- 
--
-- ~/.config/generate_env.lua
--
--

-- Directories
local home    = os.getenv("HOME")
local bin     = home .. "/.local/bin"
local lib     = home .. "/.local/lib"
local data    = home .. "/.local/share"
local state   = home .. "/.local/state"
local cache   = home .. "/.local/cache"
local config  = home .. "/.config"
local runtime = "/run/user/1000"

-- Programs
local editor  = "nvim"

-- Environment Variables
local env_map = {
    -- Intrinsic
    LC_ALL      = "C.UTF-8",
    HOME        = home,
    PACMAN_WRAP = "yay",
    
    -- XDG Base Directory Specification 
	-- -- https://specifications.freedesktop.org/basedir/latest/
	-- 
	-- -- See ~/.config/user-dirs.dirs and `man xdg-user-dirs`
    XDG_CONFIG_HOME = config,  
    XDG_DATA_HOME   = data,
    XDG_STATE_HOME  = state,
    XDG_CACHE_HOME  = cache,
    XDG_RUNTIME_DIR = runtime,
    
    -- Graphical
    DISPLAY           = ":0",
    MONITOR_PRIMARY   = "eDP-1",
    MONITOR_SECONDARY = "HDMI-1",
    XCURSOR_SIZE      = "24",
    HYPRCURSOR_SIZE   = "24",

  --QT_STYLE_OVERRIDE                   = "kvantum",
  --QT_AUTO_SCREEN_SCALE_FACTOR         = "1",
  --QT_QPA_PLATFORM                     = "wayland;xcb",
  --QT_WAYLAND_DISABLE_WINDOWDECORATION = "1",
  --QT_QPA_PLATFORMTHEME                = "qt5ct",

    SCREENSHOT_DIR    = "~/ref/image/top-screenshot/",

    -- Application
    EDITOR  = "nvim",
    VISUAL  = "nvim",
  --PAGER   = "nvim -R - +CGInterpretEscape",
    PAGER   = "less",
    TERMCMD = "wezterm",
    BROWSER = "firefox",
    PATH    = table.concat({
        -- Userspace
        bin,
        data .. "/go/bin",
        data .. "/gem/ruby/3.2.0/bin",
        data .. "/gem/ruby/3.3.0/bin",
        data .. "/gem/ruby/3.4.0/bin",

        -- System
        "/usr/bin/site_perl",
        "/usr/bin/vendor_perl",
        "/usr/bin/core_perl",
        "/usr/local/sbin",
        "/usr/local/bin",
        "/usr/bin",
    }, ":"),

	-- Android
	ANDROID_USER_HOME = data .. "/android",

	-- Cargo
	CARGO_HOME = data .. "/cargo",

    -- fzf
    FZF_CTRL_R_OPTS= table.concat({
        "--border",
        "--height 40%",
        "--reverse",
        "--with-nth 2..",
    }, " "),

	-- GitHub CLI
	GH_TELEMETRY = "false",

    -- Golang
    GOROOT = "/usr/lib/go",
    GOPATH = data .. "/go",
    GOBIN  = data .. "/go/bin",

	-- Gradle
	GRADLE_USER_HOME = data .. "/gradle",

    -- Lua
    LUA             = "/usr/bin/luajit",
    LUA_INCDIR      = "/usr/include/luajit-2.1",
    LUA_LIBDIR      = "/usr/lib64",
    LUAROCKS_CONFIG = config .. "/luarocks/config-5.1.lua",
    
    -- Node Package Manager
  --NPM_CONFIG_USERCONF   = config .. "/npm/npmrc",
    NPM_CONFIG_USERCONFIG = config .. "/npm/npmrc",
	NPM_CONFIG_CACHE      = cache  .. "/npm",
	
	-- Node Version Manager
	NVM_DIR  = data .. "/nvm",

    -- Perl
  --PERL5LIB = lib .. "/perl5",
	PERL_CPANM_HOME = cache .. "/cpanm",
	
	-- Rustup
	RUSTUP_HOME = data .. "/rustup",

	-- SSH
	SSH_AUTH_SOCK = runtime .. "/ssh-agent.socket",
    SSH_CHEWYTELE = "u0_a492@192.168.4.22:8022",

	-- Terminfo
	TERMINFO = data .. "/terminfo",
	TERMINFO_DIRS = table.concat({ data .. "/terminfo", "/usr/share/terminfo" }, ":"),

    -- Zsh
    ZDOTDIR  = config .. "/zsh",

    -- Zellij
  --ZELLIJ_CONF_DIR = config .. "/zellij",
}

local write_outfile = function(env_file_type, filepath, env_table, line_format)
	os.execute("mkdir -p $(dirname " .. filepath .. ")")
    local file, err = io.open(filepath, "w")
    if not file then
        print("Error opening file:", err)
        os.exit(10)
    end

	-- TODO(@chewygumxx): Prepend generated files with generation information

    for key, value in pairs(env_table) do
        file:write(string.format(line_format, key, value))
    end

    file:close()
    print(string.format("%-20s", env_file_type), filepath)
end

write_outfile("environment.d.conf",
    config .. "/environment.d/generated-environment.d.conf",
    env_map,
    "%s=%s\n")
write_outfile("zshenv",
    config .. "/zsh/env.zsh",
    env_map,
    "export %s='%s'\n")
