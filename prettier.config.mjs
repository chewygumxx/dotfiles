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
            // *.jsonc files carry comments that the plain "json" parser
            // rejects. trailingComma is forced to "none" because
            // chewygumxx/sync-repo-metadata parses with jsonc-parser, which
            // rejects trailing commas despite the "jsonc" name.
            files: "**/*.jsonc",
            options: { parser: "jsonc", trailingComma: "none" },
        },
    ],
};
