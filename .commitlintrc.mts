// vim:set expandtab shiftwidth=4 filetype=typescript:
// SPDX-License-Identifier: GPL-3.0-only

//
//
// ~chewygumxx/dotfiles.git
// ::: :/.commitlintrc.mts
//
//

import type { UserConfig } from "@commitlint/types";
import { RuleConfigSeverity } from "@commitlint/types";

interface Enumerable {
    name: string;
    fullName: string;
    description: string;
}

const types: { enum: Enumerable[] } = {
    enum: [
        {
            name: "feat",
            fullName: "Feature",
            description: "Implementing new functionality/tool",
        },
        {
            name: "fix",
            fullName: "Fix",
            description: "Correct misconfiguration",
        },
        {
            name: "tweak",
            fullName: "Tweak",
            description: "Minor preference adjustment",
        },

        {
            name: "chore",
            fullName: "Chore",
            description: "Repository maintenance, organisation and management",
        },
        {
            name: "style",
            fullName: "Style",
            description: "Formatting, whitespace, indentation",
        },
        {
            name: "docs",
            fullName: "Docs",
            description: "Documentation and comments",
        },
        {
            name: "ci",
            fullName: "CI",
            description: "Continuous integration/deployment",
        },

        {
            name: "refactor",
            fullName: "Refactor",
            description: "Purely structural",
        },
        {
            name: "perf",
            fullName: "Performance",
            description: "Performance improvement",
        },
        {
            name: "build",
            fullName: "Build",
            description:
                "Compilation, tools and dependency (eg. chezmoi script, template, external, execution)",
        },
        {
            name: "test",
            fullName: "Test",
            description: "Test utilities eg. JSONschema validation",
        },
        {
            name: "revert",
            fullName: "Revert",
            description: "It's rewind time, rollback",
        },
    ],
};

const scopes: { delimiters: string[]; enum: Enumerable[] } = {
    delimiters: ["/"],
    enum: [
        {
            name: "btop",
            fullName: "Btop",
            description: "System Resource Monitor",
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
            name: "yay",
            fullName: "Yay",
            description: "AUR Helper and Pacman Wrapper",
        },
        { name: "yazi", fullName: "Yazi", description: "File Manager" },
        { name: "zsh", fullName: "Z Shell", description: "Shell" },
    ],
};

const lvl = {
    off: RuleConfigSeverity.Disabled,
    wrn: RuleConfigSeverity.Warning,
    err: RuleConfigSeverity.Error,
};

function promptQuestionEnum(enumerable: Enumerable[]) {
    return Object.fromEntries(
        enumerable.map((item) => [
            item.name,
            {
                title: item.fullName,
                description: item.description,
            },
        ]),
    );
}

const Configuration: UserConfig = {
    extends: ["@commitlint/config-conventional"],
    parserPreset: "conventional-changelog-conventionalcommits",

    rules: {
        "header-max-length": [lvl.err, "always", 50],
        "type-enum": [lvl.err, "always", types.enum.map((type) => type.name)],
        "scope-delimiter-style": [lvl.err, "always", scopes.delimiters],
        "scope-enum": [
            lvl.err,
            "always",
            scopes.enum.map((scope) => scope.name),
        ],
        "subject-case": [lvl.wrn, "always", ["start-case", "sentence-case"]],
        "subject-empty": [lvl.err, "never"],
        "body-max-line-length": [lvl.err, "always", 72],
    },

    prompt: {
        settings: {
            useExclamationMark: true,
            enableMultipleScopes: true,
            scopeEnumSeparator: scopes.delimiters.at(0),
        },
        messages: {
            skip: "(optional)",
            max: "(max %d)",
            min: "(min %d)",
            emptyWarning: "%s must not be empty",
            upperLimitWarning: "%s over max: %d",
            lowerLimitWarning: "%s below min: %d",
        },
        questions: {
            type: {
                description: "Select Type",
                enum: promptQuestionEnum(types.enum),
            },
            scope: {
                description: "Select Scope",
                enum: promptQuestionEnum(scopes.enum),
            },
            subject: { description: "Subject" },
            body: { description: "Body" },
            isBreaking: { description: "Breaking Changes?" },
            breakingBody: {
                description: "Breaking change commits require a body",
            },
            breaking: { description: "Breaking Changes Description" },
            isIssueAffected: { description: "Relevant Issues?" },
            issuesBody: {
                description: "If issues are closed, the commit requires a body",
            },
            issues: {
                description: 'Issue References (eg. "fix #123", "re #456")',
            },
        },
    },
};

export default Configuration;
