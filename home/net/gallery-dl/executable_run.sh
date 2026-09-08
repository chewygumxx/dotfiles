#!/usr/bin/env bash
# vim:set expandtab shiftwidth=4 filetype=bash:
# SPDX-License-Identifier: GPL-3.0-only
#
#
# ~chewygumxx/dotfiles.git
# ::: :/home/net/gallery-dl/executable_run.sh
#
#

gallery-dl \
    --cofig-json gallery-dl.conf \
    --input-file-delete tweet_urls.xargs.txt
