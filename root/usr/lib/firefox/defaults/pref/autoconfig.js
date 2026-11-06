// vim:set expandtab shiftwidth=4 filetype=javascript:
// SPDX-License-Identifier: GPL-3.0-only

//
//
// ~chewygumxx/dotfiles.git
// ::: :/root/usr/lib/firefox/defaults/pref/autoconfig.js
//
//

//
// AutoConfig-Primary
// Exists near exclusively to define the AutoConfig-Secondary file.
//
// https://support.mozilla.org/en-US/kb/customizing-firefox-using-autoconfig
// https://web.mit.edu/~firefox/www/maintainers/autoconfig.html
// https://wiki.archlinux.org/title/Firefox#Settings_storage
//

// [REQUIRED] AutoConfig-Secondary Filename
//
// The filepath of the AutoConfig-Secondary is constrained to be a direct
// child of the application directory such that it is a sibling to the
// executable firefox binary itself. Also, first line of AutoConfig-Secondary
// is ignored.
//
// On Arch Linux:
// - Firefox Directory:    /usr/lib/firefox/
// - Firefox Executable:   /usr/lib/firefox/firefox
// - AutoConfig-Secondary: /usr/lib/firefox/firefox.cfg
//
pref("general.config.filename", "firefox.cfg");

// [REQUIRED] Disable Deobfuscation
//
// Firefox expects the AutoConfig-Secondary file to be obfuscated via byte
// shift of 13. This time no.
//
pref("general.config.obscure_value", 0);
