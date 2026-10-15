// vim:set expandtab shiftwidth=4 filetype=typescript:
// SPDX-License-Identifier: GPL-3.0-only

//
//
// ~chewygumxx/dotfiles.git
// ::: :/.commitlintrc.mts
//
//

import { defineConfig } from "@chewygumxx/commitlint-config";

export default defineConfig({
    scopes: [
        {
            name: "btop",
            fullName: "Btop",
            description: "System Resource Monitor",
        },
        {
            name: "ccstatusline",
            fullName: "ccstatusline",
            description: "Claude Code Status Line",
        },
        {
            name: "chromium",
            fullName: "Ungoogled Chromium",
            description: "Web Browser",
        },
        {
            name: "claude",
            fullName: "Claude Code",
            description: "Agentic Coding Tool",
        },
        {
            name: "chezmoi",
            fullName: "Chezmoi",
            description: "Dotfiles Manager",
        },
        {
            name: "firefox",
            fullName: "Mozilla Firefox",
            description: "Web Browser",
        },
        {
            name: "gh",
            fullName: "GitHub CLI",
            description: "GitHub's Command Line Tool",
        },
        { name: "git", fullName: "Git", description: "Version Control System" },
        { name: "gpg", fullName: "GnuPG", description: "GNU OpenPGP Tool" },
        {
            name: "herdr",
            fullName: "Herdr",
            description: "Terminal Multiplexer",
        },
        {
            name: "hypr",
            fullName: "Hyprland",
            description: "Wayland Compositor",
        },
        {
            name: "mise",
            fullName: "Mise",
            description: "Project development environment management",
        },
        {
            name: "nushell",
            fullName: "Nushell",
            description: "Data-aware shell",
        },
        {
            name: "ssh",
            fullName: "OpenSSH",
            description: "Cryptographic Network Protocol",
        },
        {
            name: "systemd",
            fullName: "Systemd",
            description: "Service Manager",
        },
        {
            name: "termux",
            fullName: "Termux",
            description: "Terminal Emulator for Android",
        },
        {
            name: "waybar",
            fullName: "Waybar",
            description: "Wayland Status Bar",
        },
        {
            name: "wezterm",
            fullName: "WezTerm",
            description: "Terminal Emulator",
        },
        {
            name: "worktrunk",
            fullName: "Worktrunk",
            description: "Git Worktree Manager",
        },
        {
            name: "yay",
            fullName: "Yay",
            description: "AUR Helper and Pacman Wrapper",
        },
        { name: "yazi", fullName: "Yazi", description: "File Manager" },
        { name: "zsh", fullName: "Z Shell", description: "Shell" },
    ],
});
