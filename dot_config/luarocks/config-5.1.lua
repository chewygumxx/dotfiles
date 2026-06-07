lua_version = "5.1"
local_by_default = true

home = "/home/chewygum"
home_tree = home .. "/.local"
config_file = home .. "/.config/luarocks/config-5.1.lua"

deploy_bin_dir = home_tree .. "/bin"

local_cache = home .. "/.cache/luarocks"

variables.LUA = home_tree .. "/bin/lua5.1"
variables.LUA_VERSION = 5.1
rocks_trees = {
   {
      name = "user",
      root = "/home/chewygum/.local"
   },
   {
      name = "system",
      root = "/usr"
   }
}
