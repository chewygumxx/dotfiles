home = "/home/chewygum"
home_tree = home .. "/.local"
config_file = home .. "/.config/luarocks/config-5.1.lua"


accept_unknown_fields = false
arch = "linux-x86_64"
cache = {
   luajit_version_checked = true
}
cache_fail_timeout = 86400
cache_timeout = 60
check_certificates = false
cmake_generator = "Unix Makefiles"
sysconfdir = home .. "/.config/luarocks"
config_files = {
   nearest = config_file,
   system = {
      file = config_file,
      found = true
   },
   user = {
      file = config_file,
      found = true
   }
}
connection_timeout = 30
deploy_bin_dir = home_tree .. "/bin"
deploy_lib_dir = home_tree .. "/lib/lua/5.1"
deploy_lua_dir = home_tree .. "/share/lua/5.1"
deps_mode = "one"
disabled_servers = {}
export_path_separator = ":"
external_deps_dirs = {
    home_tree
}
external_deps_patterns = {
   bin = {
      "?"
   },
   include = {
      "?.h"
   },
   lib = {
      "lib?.a",
      "lib?.so",
      "lib?.so.*"
   }
}
external_deps_subdirs = {
   bin = "bin",
   include = "include",
   lib = {
      "lib64",
      "lib"
   }
}
external_lib_extension = "so"
fs_use_modules = true
gcc_rpath = true
hooks_enabled = true
lib_extension = "so"
lib_modules_path = "lib/lua/5.1"
link_lua_explicitly = false
local_by_default = true
local_cache = home .. "/.cache/luarocks"
lua_extension = "lua"
lua_found = true
lua_modules_path = "share/lua/5.1"
lua_version = "5.1"
no_manifest = false
obj_extension = "o"
processor = "x86_64"
program_version = "3.13.0"

rocks_subdir = "lib/luarocks/rocks-5.1"
rocks_dir = home_tree .. "lib/luarocks/rocks-5.1"
rocks_servers = {
   {
      "https://luarocks.org",
      "https://raw.githubusercontent.com/rocks-moonscript-org/moonrocks-mirror/master/",
      "https://loadk.com/luarocks/"
   }
}
rocks_trees = {
   {
      name = "user",
      root = home_tree
   },
   {
      name = "system",
      root = home_tree
   }
}
runtime_external_deps_patterns = {
   bin = {
      "?"
   },
   include = {
      "?.h"
   },
   lib = {
      "lib?.so",
      "lib?.so.*"
   }
}
runtime_external_deps_subdirs = {
   bin = "bin",
   include = "include",
   lib = {
      "lib64",
      "lib"
   }
}
static_lib_extension = "a"
target_cpu = "x86_64"
upload = {
   api_version = "1",
   server = "https://luarocks.org",
   tool_version = "1.0.0"
}
user_agent = "LuaRocks/3.13.0 linux-x86_64"
variables = {
   AR = "ar",
   BUNZIP2 = "bunzip2",
   CC = "gcc",
   CFLAGS = "-O2 -fPIC",
   CHMOD = "chmod",
   CMAKE = "cmake",
   CP = "cp",
   CURL = "curl",
   CURLNOCERTFLAG = "-k",
   CVS = "cvs",
   FIND = "find",
   GIT = "git",
   GPG = "gpg",
   GUNZIP = "gunzip",
   HG = "hg",
   ICACLS = "icacls",
   LD = "gcc",
   LIBFLAG = "-shared",
   LIB_EXTENSION = "so",
   LN = "ln",
   LS = "ls",
   LUA = home_tree .. "/bin/lua5.1",
   LUALIB = "liblua5.1.so",
   LUA_BINDIR = home_tree .. "/bin",
   LUA_DIR = home_tree,
   LUA_INCDIR = home_tree .. "/include",
   LUA_INCDIR_OK = "ok",
   LUA_LIBDIR = home_tree .. "/lib64",
   LUA_LIBDIR_FILE = "liblua5.1.so",
   LUA_LIBDIR_OK = "ok",
   LUA_VERSION = "5.1",
   MAKE = "make",
   MD5 = "md5",
   MD5SUM = "md5sum",
   MKDIR = "mkdir",
   MKTEMP = "mktemp",
   OBJ_EXTENSION = "o",
   OPENSSL = "openssl",
   PWD = "pwd",
   RANLIB = "ranlib",
   RM = "rm",
   RMDIR = "rmdir",
   ROCKS_TREE = home_tree .. "/luarocks/rocks-5.1",
   RSYNC = "rsync",
   RSYNCFLAGS = "--exclude=.git -Oavz",
   SCP = "scp",
   SCRIPTS_DIR = home_tree .. "/bin",
   SEVENZ = "7z",
   SSCM = "sscm",
   SVN = "svn",
   TAR = "tar",
   TEST = "test",
   TOUCH = "touch",
   UNZIP = "unzip -n",
   WGET = "wget",
   WGETNOCERTFLAG = "--no-check-certificate",
   ZIP = "zip"
}
web_browser = "xdg-open"
wrapper_suffix = ""

