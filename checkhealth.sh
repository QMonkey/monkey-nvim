#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────────────────────
# monkey-nvim dependency check
#
# The check framework lives in scripts/ (a `git subtree` of
# github.com/QMonkey/monkey-scripts) — this file only declares WHAT to check.
# ──────────────────────────────────────────────────────────────

. "$(dirname "${BASH_SOURCE[0]:-$0}")/scripts/checkhealth.sh" || {
	echo "monkey-scripts not found — update this checkout (git pull / re-clone)," >&2
	echo "or run install.sh, which bootstraps monkey-scripts itself." >&2
	exit 1
}

# ──────────────────────── identity ────────────────────────
PROJECT=monkey-nvim

# ──────────────────────── version gate ────────────────────────
MAIN_VERSION="nvim|ver:0.12|neovim|none"
MAIN_VERSION_TITLE="Neovim version"

# ──────────────────────── required ────────────────────────
# cc and tree-sitter carry their own install strategies (system gcc; npm
# tree-sitter-cli) — the generic install_missing_required runs them through
# install_strategy like any other spec.
REQUIRED_CHECKS=(
	"@header|Required tools"
	"git|bin|git"
	"rg|bin|ripgrep"
	"ctags|bin|universal-ctags"
	"fzf|bin|fzf"
	"cc|anyof:gcc clang cc|C compiler|pkg:gcc"
	"tree-sitter|bin|tree-sitter-cli|npm:tree-sitter-cli"
	"@header|python3${NC} (TIOCSTI injection)"
	"python3|bin|python3 (required by TIOCSTI injection)"
)

# ──────────────────────── recommended ────────────────────────
# fzf ships far newer via Homebrew than most distro repos — prefer brew
# when it exists (install_pkg splits the batch on these names).
BREW_FIRST=(fzf zig zls)
RECOMMENDED_NOTE="(Missing won't block monkey-nvim, but will degrade gtags experience)"
RECOMMENDED_CHECKS=(
	"global|bin|global (GNU Global, for gtags)|pkg"
	"pygmentize|bin|pygments (gtags parser for non-C/C++ languages)|pkg"
	"python|bin|python (unversioned → python3, gtags pygments parser runtime)|python-unversioned"
)

# ──────────────────────── optional: LSP servers & language tools ─────────────
# Grouped by language (8th spec field); each entry's install field lists the
# fallback chain (system package first, brew/go/npm/pip after).
OPTIONAL_SECTION_TITLE="Optional: LSP servers & language tools"
OPTIONAL_INSTALL_TITLE="Installing optional LSP servers & tools"
OPTIONAL_SECTION_NOTE="(Install only what you need; missing servers won't block monkey-nvim)"
INSTALL_OPTIONAL=1
OPTIONAL_ALL_PRESENT_MSG="All optional LSP servers & tools already installed."
OPTIONAL_DONE_MSG="Done with optional installs."
OPTIONAL_CHECKS=(
	"gcc|bin|gcc|pkg||||C/C++"
	"g++|bin|g++|pkg||||C/C++"
	"clangd|bin|clangd|pkg||||C/C++"
	"clang-tidy|bin|clang-tidy|pkg||||C/C++"
	"go|bin|go|pkg||||Go"
	"gopls|bin|gopls|go:golang.org/x/tools/gopls@latest||||Go"
	"staticcheck|bin|staticcheck|go:honnef.co/go/tools/cmd/staticcheck@latest||||Go"
	"python3|bin|python3|pkg||||Python"
	"pylsp|bin|pylsp|pkg,pip:python-lsp-server||||Python"
	"black|bin|black|pkg,pip:black||||Python"
	"zig|bin|zig|pkg||||Zig"
	"zls|bin|zls|pkg||||Zig"
	"cargo|bin|cargo|rustup||||Rust"
	"rust-analyzer|bin|rust-analyzer|rustup-component:rust-analyzer||||Rust"
	"lua-language-server|bin|lua-language-server|pkg,brew:lua-language-server||||Lua"
	"node|bin|node|pkg||||Shell"
	"bash-language-server|bin|bash-language-server|npm:bash-language-server||||Shell"
	"shfmt|bin|shfmt|go:mvdan.cc/sh/v3/cmd/shfmt@latest,pkg||||Shell"
	"node|bin|node|pkg||||Vim"
	"vim-language-server|bin|vim-language-server|npm:vim-language-server||||Vim"
	"node|bin|node|pkg||||JavaScript/TypeScript"
	"typescript-language-server|bin|typescript-language-server|npm:typescript-language-server typescript||||JavaScript/TypeScript"
	"tsc|bin|tsc|npm:typescript||||JavaScript/TypeScript"
	"node|bin|node|pkg||||JSON"
	"vscode-json-language-server|bin|vscode-json-language-server|npm:vscode-langservers-extracted||||JSON"
	"node|bin|node|pkg||||YAML"
	"yaml-language-server|bin|yaml-language-server|npm:yaml-language-server||||YAML"
	"marksman|bin|marksman|pkg,brew:marksman||||Markdown"
	"efm-langserver|bin|efm-langserver|go:github.com/mattn/efm-langserver@latest||||Markdown"
	"prettier|bin|prettier|npm:prettier||||Markdown"
	"markdownlint-cli2|bin|markdownlint-cli2|npm:markdownlint-cli2||||Markdown"
	"glow|bin|glow|pkg,brew:glow,go:github.com/charmbracelet/glow@latest||||Optional tools"
)

# ──────────────────────── config ────────────────────────
# src|dst|desc|mode|name — init.lua saves sessions to stdpath('data')/sessions
# and mkdir -p's them on first write; swap/ is created on first nvim launch.
CONFIG_LINKS=(
	"$(pwd)|$HOME/.config/nvim|nvim dir||~/.config/nvim"
)
# type|params|ok|incomplete|missing
CONFIG_HINTS=(
	"path|$HOME/.local/state/nvim/swap|swap/ dir exists||swap/ dir not found (auto-created on first nvim launch)"
	"any|$HOME/.config/efm-langserver $HOME/.config/efm-langserver/config.yaml !$(pwd)/configs/efm-langserver|efm-langserver config|efm-langserver config not linked (run: ln -sfn $(pwd)/configs/efm-langserver ~/.config/efm-langserver)|"
	"path|$HOME/.local/share/nvim/sessions|sessions/ dir exists||sessions/ dir not found (auto-created on first session save)"
)

# ──────────────────────── terminal ────────────────────────
CHECK_TERMINAL_CAPS=1
TERMCAPS_STYLE=colorterm
CHECK_LANG=1
CHECK_CLIPBOARD=warn

checkhealth_main "$@"
