// vim:set expandtab shiftwidth=4 filetype=typescript:
// SPDX-License-Identifier: GPL-3.0-only

//
//
// ~chewygumxx/dotfiles.git
// ::: :/.prettierrc.mts
//
//

import type { Config } from "prettier";

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
} satisfies Config;
