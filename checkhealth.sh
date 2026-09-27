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
# @call hands the line to a project-defined check below: a C compiler and the
# tree-sitter CLI are "whichever of several names works", which the generic
# spec types cannot express (they also print the found name, not the desc).
REQUIRED_CHECKS=(
	"@header|Required tools"
	"git|bin|git"
	"rg|bin|ripgrep"
	"ctags|bin|universal-ctags"
	"fzf|bin|fzf"
	"@call|check_cc"
	"@call|check_ts"
	"@header|python3${NC} (TIOCSTI injection)"
	"python3|bin|python3 (required by TIOCSTI injection)"
)

check_cc() {
	if have_native_cmd gcc; then
		ok "gcc"
	elif have_native_cmd clang; then
		ok "clang"
	elif have_native_cmd cc; then
		ok "cc"
	else
		fail "C compiler (gcc/clang)"
		record_missing required "cc"
	fi
}

check_ts() {
	if have_native_cmd tree-sitter; then
		ok "tree-sitter-cli"
	else
		fail "tree-sitter-cli"
		record_missing required "ts"
	fi
}

# ──────────────────────── recommended ────────────────────────
# fzf ships far newer via Homebrew than most distro repos — prefer brew
# when it exists (install_pkg splits the batch on these names).
BREW_FIRST=(fzf)
RECOMMENDED_NOTE="(Missing won't block monkey-nvim, but will degrade gtags experience)"
RECOMMENDED_CHECKS=(
	"global|bin|global (GNU Global, for gtags)|pkg"
	"pygmentize|bin|pygments (gtags parser for non-C/C++ languages)|pkg"
	"python|bin|python (unversioned → python3, gtags pygments parser runtime)|python-unversioned"
)

# ──────────────────────── optional: LSP servers & language tools ─────────────
# Grouped by language (8th spec field); each entry's install strategy mirrors
# install_optional_bin upstream (system package first, brew/go/npm/pip after).
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
	"zig|bin|zig|brew:zig,pkg||||Zig"
	"zls|bin|zls|brew:zls,pkg||||Zig"
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

# ──────────────────────── install steps ────────────────────────
# Verbatim upstream: install the missing ids one by one (with the cc/ts
# special cases), then re-run the required checks (re-print) and hint at
# what is left.

install_missing_required() {
	if ! $INSTALL_MODE || [[ ${#MISSING_REQUIRED[@]} -eq 0 ]]; then
		return 0
	fi
	echo -e "${YELLOW}Installing: ${MISSING_REQUIRED[*]}...${NC}"
	local bin b
	for b in "${MISSING_REQUIRED[@]}"; do
		echo -e "  ${YELLOW}→ installing ${b}...${NC}"
		case "$b" in
		cc)
			# llvm (brew/zypper/arch) brings clang; gcc/g++ cover the rest
			install_pkg "$(pkg_name gcc)" || install_pkg "$(pkg_name clangd)" || true
			;;
		ts)
			npm_install_g tree-sitter-cli
			;;
		*)
			install_pkg "$(pkg_name "$b")" || true
			;;
		esac
	done
	run_required_checks
	if [[ ${#MISSING_REQUIRED[@]} -gt 0 ]]; then
		echo -e "${RED}Run: $(get_install_hint "$(for b in "${MISSING_REQUIRED[@]}"; do pkg_name "$b"; done | tr '\n' ' ')")${NC}"
	fi
	echo ""
}

# Verbatim upstream install table and hints: the generic strategy
# chain cannot reproduce upstream's per-binary fallbacks (e.g. the
# gopls arm reports success unconditionally) nor its curated FAIL
# hints, so both are carried over as-is.

go_install() {
	# 'go install' is silent for its ENTIRE module download + compile, which
	# takes minutes on the first run — announce it so the wait is explainable.
	# The notice goes to stdout on purpose: call sites may discard stderr.
	echo -e "  ${CYAN}→ go install ${1%@*} (building, no output — may take a few minutes)${NC}"
	go install "$@"
}

install_optional_bin() {
	local bin="$1"
	local ok=true
	ensure_go_env
	case "$bin" in
	rg)
		install_pkg "$(pkg_name "$bin")" ||
			{
				echo -e "  ${CYAN}→ cargo install ripgrep (source build, no output — may take several minutes)${NC}"
				cargo install ripgrep 2>/dev/null
			} ||
			ok=false
		;;
	gopls)
		go_install golang.org/x/tools/gopls@latest
		;;
	pylsp)
		install_pkg "$(pkg_name "$bin")" 2>/dev/null ||
			sudo_cmd pip3 install python-lsp-server 2>/dev/null ||
			pip3 install python-lsp-server 2>/dev/null ||
			ok=false
		;;
	cargo)
		ensure_rust || ok=false
		;;
	rust-analyzer)
		if ensure_rust; then
			rustup component add rust-analyzer
		else
			ok=false
		fi
		;;
	bash-language-server)
		npm_install_g bash-language-server
		;;
	shfmt)
		go_install mvdan.cc/sh/v3/cmd/shfmt@latest 2>/dev/null || install_pkg shfmt || ok=false
		;;
	staticcheck)
		go_install honnef.co/go/tools/cmd/staticcheck@latest 2>/dev/null || ok=false
		;;
	black)
		install_pkg "$(pkg_name "$bin")" 2>/dev/null ||
			sudo_cmd pip3 install black 2>/dev/null ||
			pip3 install black 2>/dev/null ||
			ok=false
		;;
	clang-tidy)
		install_pkg "$(pkg_name "$bin")" || ok=false
		;;
	vim-language-server)
		npm_install_g vim-language-server
		;;
	typescript-language-server)
		npm_install_g typescript-language-server typescript
		;;
	tsc)
		npm_install_g typescript
		;;
	vscode-json-language-server)
		npm_install_g vscode-langservers-extracted
		;;
	yaml-language-server)
		npm_install_g yaml-language-server
		;;
	lua-language-server)
		install_pkg "$(pkg_name "$bin")" || brew install lua-language-server 2>/dev/null || ok=false
		;;
	glow)
		install_pkg "$(pkg_name "$bin")" || brew install glow 2>/dev/null || go_install github.com/charmbracelet/glow@latest 2>/dev/null || ok=false
		;;
	marksman)
		install_pkg "$(pkg_name "$bin")" || brew install marksman 2>/dev/null || ok=false
		;;
	efm-langserver)
		go_install github.com/mattn/efm-langserver@latest 2>/dev/null || ok=false
		;;
	prettier)
		npm_install_g prettier
		;;
	markdownlint-cli2)
		npm_install_g markdownlint-cli2
		;;
	zig)
		brew install zig 2>/dev/null || install_pkg "$(pkg_name "$bin")" || ok=false
		;;
	zls)
		brew install zls 2>/dev/null || install_pkg "$(pkg_name "$bin")" || ok=false
		;;
	*)
		install_pkg "$(pkg_name "$bin")" || ok=false
		;;
	esac
	$ok
}

optional_hint() {
	case "$1" in
	clangd) echo "$(get_install_hint clangd)  # or clangd-15+" ;;
	gcc | g++ | python3) echo "$(get_install_hint "$1")" ;;
	go) echo "https://go.dev/dl/" ;;
	gopls) echo "go install golang.org/x/tools/gopls@latest" ;;
	pylsp) echo "$(get_install_hint "$(pkg_name pylsp)")  # or: pip install python-lsp-server" ;;
	cargo) echo "https://rustup.rs/  # then: rustup component add rust-analyzer" ;;
	rust-analyzer) echo "rustup component add rust-analyzer" ;;
	node) echo "https://nodejs.org/  # or: $(get_install_hint nodejs npm)" ;;
	bash-language-server) echo "npm install -g bash-language-server" ;;
	shfmt) echo "go install mvdan.cc/sh/v3/cmd/shfmt@latest" ;;
	staticcheck) echo "go install honnef.co/go/tools/cmd/staticcheck@latest" ;;
	black) echo "$(get_install_hint "$(pkg_name black)")  # or: pip3 install black" ;;
	clang-tidy) echo "$(get_install_hint clang-tidy)" ;;
	vim-language-server) echo "npm install -g vim-language-server" ;;
	typescript-language-server) echo "npm install -g typescript-language-server typescript" ;;
	tsc) echo "npm install -g typescript" ;;
	vscode-json-language-server) echo "npm install -g vscode-langservers-extracted" ;;
	yaml-language-server) echo "npm install -g yaml-language-server" ;;
	lua-language-server) echo "$(get_install_hint lua-language-server)" ;;
	efm-langserver) echo "go install github.com/mattn/efm-langserver@latest" ;;
	prettier) echo "npm install -g prettier" ;;
	markdownlint-cli2) echo "npm install -g markdownlint-cli2" ;;
	marksman) echo "$(get_install_hint marksman)" ;;
	zig) echo "brew install zig  # or: https://ziglang.org/download/" ;;
	zls) echo "brew install zls  # or: https://zigtools.org/zls/install/  (must match zig version)" ;;
	glow) echo "$(get_install_hint glow)  # or: go install github.com/charmbracelet/glow@latest" ;;
	esac
}

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
