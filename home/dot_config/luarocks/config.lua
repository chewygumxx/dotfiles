-- vim: expandtab:shiftwidth=4

--
--
-- ~/.config/luarocks/config.lua
--
--

--
-- Symlinked by multiple different version specific luarocks configs.
--

home = os_getenv("HOME")
home_tree = os_getenv("XDG_DATA_HOME") .. "/luarocks"
homeconfdir = os_getenv("XDG_CONFIG_HOME") .. "/luarocks"
local_cache = os_getenv("XDG_CACHE_HOME") .. "/luarocks"
local_by_default = true
rocks_trees = {
    {
        name = "user",
        root = home_tree,
    },
    {
        name = "system",
        root = "/usr"
    }
}
