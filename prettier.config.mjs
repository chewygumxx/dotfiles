// vim:set expandtab shiftwidth=4 filetype=javascript:
// SPDX-License-Identifier: GPL-3.0-only

//
//
// ~chewygumxx/dotfiles.git
// ::: :/prettier.config.mjs
//
//

/** @type {import("prettier").Config} */
export default {
    overrides: [
        {
            // *.jsonc files carry comments/trailing commas that the plain
            // "json" parser rejects.
            files: "**/*.jsonc",
            options: { parser: "jsonc" },
        },
    ],
};
