-- vim: expandtab:shiftwidth=4

--
--
-- ~/.config/yay/init.lua
--
--

--
-- https://jguer.github.io/yay/lua.html
-- https://jguer.github.io/yay/init-lua.html
--

yay.opt = {
    -- Strings
    aururl = "https://aur.archlinux.org",
    aurrpcurl = "https://aur.archlinux.org/rpc?",
    build_dir = os.getenv("XDG_CACHE_HOME") .. "/yay",
    editor = os.getenv("EDITOR") or os.getenv("VISUAL") or "vi",
    editor_flags = "",
    makepkg_bin = "makepkg",
    makepkg_conf = "",
    mflags = "",
    pacman_bin = "pacman",
    pacman_conf = "/etc/pacman.conf",
    redownload = "no",
    git_bin = "git",
    git_flags = "",
    gpg_bin = "gpg",
    gpg_flags = "",
    sort_by = "popularity",
    search_by = "name-desc",
    remove_make = "no",
    sudo_bin = "sudo",
    sudo_flags = "",
    rebuild = "no",
    
    -- Integers
    request_split_n = 150, -- Max packages per AUR RPC request
    completion_refresh_time = 7, -- Completion cache refresh days
    max_concurrent_downloads = 0, -- Parallel PKGBUILD source downloads; 0 uses CPU count.
    
    -- Booleans
    bottom_up = true, -- Show AUR packages before repo packages in mixed results.
    sudo_loop = true, -- Keep sudo session alive in the background during long builds.
    devel = false, -- Check development/VCS packages on sysupgrade.
    clean_after = true, -- Remove untracked files after install.
    keep_src = false, -- Keep pkg/ and src/ after successful builds.
    provides = true, -- Resolve matching providers when dependencies are ambiguous.
    pgp_fetch = true, -- Prompt to import unknown PGP keys from validpgpkeys.
    clean_menu = false,
    diff_menu = false,
    edit_menu = false,
    combined_upgrade = true, -- Use combined repo+AUR upgrade flow on sysupgrade.
    use_ask = false, -- Use pacman's --ask to auto-confirm known conflicts.
    batch_install = false, -- Queue AUR package installs instead of installing each package immediately.
    single_line_results = false, -- Use single-line search result format.
    separate_sources = true, -- Separate query results by source (repo vs AUR).
    debug = false, -- Enable debug logging and local init.lua lookup convenience.
    rpc = true, -- Use AUR RPC for dependency/query operations.
    double_confirm = true, -- Ask for confirmation before and after builds during upgrades.
}

-- Hooks
-- Run Lua before yay prints the upgrade exclusion menu. Return package names
-- from event.data.upgrades to pre-exclude them. Set skip_menu = false, or omit
-- it, to show the native menu after these exclusions are applied.
--
-- yay.create_autocmd("UpgradeSelect", {
--   desc = "skip recently modified AUR upgrades",
--   callback = function(event)
--     local exclude = {}
--     local recent_cutoff = os.time() - (3 * 24 * 60 * 60)
--     for _, pkg in ipairs(event.data.upgrades) do
--       if pkg.repository == "aur" and pkg.last_modified >= recent_cutoff then
--         yay.log.warn("pre-excluding recently modified AUR package:", pkg.name)
--         table.insert(exclude, pkg.name)
--       end
--     end
--
--     return { exclude = exclude, skip_menu = false }
--   end,
-- })
--
-- Run Lua after AUR PKGBUILD repos are downloaded/merged and before the
-- clean/diff/edit menus or source downloads.
--
-- yay.create_autocmd("AURPreInstall", {
--   desc = "inspect or modify AUR package files",
--   callback = function(event)
--     if event.data.pkgbuild:match("forbidden.example") then
--       yay.log.warn(event.match .. ": forbidden source URL")
--       yay.abort(event.match .. ": forbidden source URL")
--     end
--
--     -- File edits are picked up by later menus and build steps.
--     -- local path = event.data.pkgbuild_path
--     -- local f = assert(io.open(path, "a"))
--     -- f:write("\n# edited by yay init.lua\n")
--     -- f:close()
--   end,
-- })
--
-- Run Lua after yay downloads/verifies package sources and before builds or
-- installs. AURPostDownload receives the same payload shape as AURPreInstall.
--
-- yay.create_autocmd("AURPostDownload", {
--   desc = "block forbidden source URLs after download",
--   callback = function(event)
--     if event.data.pkgbuild:match("forbidden.example") then
--       yay.abort(event.match .. ": forbidden source URL")
--     end
--   end,
-- })
--
-- Run Lua once after a successful install/upgrade transaction (skipped on
-- --downloadonly). The callback is fire-and-forget; returning has no effect.
--
-- yay.create_autocmd("PostInstall", {
--   desc = "log every package yay installed",
--   callback = function(event)
--     for _, pkg in ipairs(event.data.packages) do
--       if pkg.installed then
--         yay.log.info(pkg.name .. " " .. pkg.version .. " installed (" .. pkg.source .. ")")
--       end
--     end
--   end,
-- })
--
-- Run Lua during -Ss / -S number menu after ranking, before display. Return
-- an ordered array of {source=, name=} to filter/reorder; nil = unchanged.
--
-- yay.create_autocmd("SearchFilter", {
--   desc = "show only AUR results",
--   callback = function(event)
--     local out = {}
--     for _, r in ipairs(event.data.results) do
--       if r.source == "aur" then
--         out[#out + 1] = { source = r.source, name = r.name }
--       end
--     end
--     return out
--   end,
-- })
