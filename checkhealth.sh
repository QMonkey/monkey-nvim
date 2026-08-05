#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

PASS="[${GREEN}✓${NC}]"
FAIL="[${RED}✗${NC}]"
WARN="[${YELLOW}!${NC}]"

ALL_PASSED=true
INSTALL_MODE=false

usage() {
	cat <<EOF
Usage: $0 [OPTIONS]

Check and optionally install dependencies for monkey-nvim.

OPTIONS
  -i, --install    Install missing dependencies
  -h, --help       Show this help

Exit code: 1 if any required dependency is missing, 0 otherwise.
EOF
	exit 0
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	-i | --install) INSTALL_MODE=true ;;
	-h | --help) usage ;;
	*)
		echo "Unknown option: $1"
		usage
		;;
	esac
	shift
done

# ──────────────────────────── helpers ────────────────────────────

check_bin() {
	if command -v "$1" &>/dev/null; then
		echo -e "  ${PASS} ${2:-$1}"
		return 0
	else
		echo -e "  ${FAIL} ${2:-$1}"
		return 1
	fi
}

check_cmd() {
	local desc="$1"
	shift
	if "$@" &>/dev/null; then
		echo -e "  ${PASS} ${desc}"
		return 0
	else
		echo -e "  ${FAIL} ${desc}"
		ALL_PASSED=false
		return 1
	fi
}

check_nvim_version() {
	local ver
	ver=$(nvim --version 2>/dev/null | head -1 | grep -oP '\d+\.\d+' || true)
	if [[ -z "$ver" ]]; then
		echo -e "  ${FAIL} neovim (not found)"
		ALL_PASSED=false
		return 1
	fi
	local major minor
	major=${ver%%.*}
	minor=${ver#*.}
	if ((major > 0 || (major == 0 && minor >= 12))); then
		echo -e "  ${PASS} neovim ${ver}"
		return 0
	else
		echo -e "  ${FAIL} neovim ${ver} (need >= 0.12)"
		ALL_PASSED=false
		return 1
	fi
}

check_cc() {
	if command -v gcc &>/dev/null; then
		echo -e "  ${PASS} gcc"
		return 0
	elif command -v clang &>/dev/null; then
		echo -e "  ${PASS} clang"
		return 0
	elif command -v cc &>/dev/null; then
		echo -e "  ${PASS} cc"
		return 0
	else
		echo -e "  ${FAIL} C compiler (gcc/clang)"
		return 1
	fi
}

check_ts() {
	if command -v tree-sitter &>/dev/null; then
		echo -e "  ${PASS} tree-sitter-cli"
		return 0
	else
		echo -e "  ${FAIL} tree-sitter-cli"
		return 1
	fi
}

os_detect() {
	case "$(uname -s)" in
	Linux)
		if [ -f /etc/os-release ]; then
			. /etc/os-release
			case "$ID" in
			ubuntu | debian | linuxmint | pop | elementary | zorin) echo "debian" ;;
			arch | manjaro | endeavouros) echo "arch" ;;
			opensuse | opensuse-leap | opensuse-tumbleweed | opensuse-microos | suse | sles) echo "opensuse" ;;
			centos | rhel | fedora | rocky | almalinux | ol) echo "centos" ;;
			*) echo "linux-unknown" ;;
			esac
		else
			echo "linux-unknown"
		fi
		;;
	Darwin) echo "macos" ;;
	*) echo "unknown" ;;
	esac
}

OS=$(os_detect)

sudo_cmd() {
	if command -v sudo &>/dev/null; then
		sudo "$@"
	else
		"$@"
	fi
}

install_pkg() {
	if ! $INSTALL_MODE; then return 1; fi
	case "$OS" in
	debian)
		case "$*" in
		*fzf*)
			if command -v brew &>/dev/null; then
				brew install "$@"
			else
				if ! command -v brew &>/dev/null; then
					/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
					eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
					brew install "$@" || sudo_cmd apt-get install -y "$@"
				fi
			fi
			;;
		*)
			sudo_cmd apt-get install -y "$@"
			;;
		esac
		;;
	opensuse) sudo_cmd zypper --non-interactive install -y "$@" ;;
	centos)
		sudo_cmd yum install -y epel-release || true
		sudo_cmd yum install -y "$@"
		;;
	arch) sudo_cmd pacman -S --noconfirm "$@" ;;
	macos) brew install "$@" ;;
	*) return 1 ;;
	esac
}

install_optional_bin() {
	local bin="$1"
	local ok=true
	case "$bin" in
		rg)
			install_pkg "$(pkg_name "$bin")" || cargo install ripgrep 2>/dev/null || ok=false
			;;
		gopls)
			go install golang.org/x/tools/gopls@latest
			;;
		pylsp)
			sudo pip3 install python-lsp-server
			;;
		rust-analyzer)
			rustup component add rust-analyzer
			;;
		bash-language-server)
			sudo npm install -g bash-language-server
			;;
		vim-language-server)
			sudo npm install -g vim-language-server
			;;
		typescript-language-server)
			sudo npm install -g typescript-language-server typescript
			;;
		tsc)
			sudo npm install -g typescript
			;;
		vscode-json-language-server)
			sudo npm install -g vscode-langservers-extracted
			;;
		yaml-language-server)
			sudo npm install -g yaml-language-server
			;;
		lua-language-server)
			install_pkg "$(pkg_name "$bin")" || brew install lua-language-server 2>/dev/null || ok=false
			;;
		glow)
			install_pkg "$(pkg_name "$bin")" || brew install glow 2>/dev/null || go install github.com/charmbracelet/glow@latest 2>/dev/null || ok=false
			;;
		marksman)
			install_pkg "$(pkg_name "$bin")" || brew install marksman 2>/dev/null || ok=false
			;;
		*)
			install_pkg "$(pkg_name "$bin")" || ok=false
			;;
	esac
	$ok
}

get_install_hint() {
	case "$OS" in
	debian) echo "sudo apt-get install ${*}" ;;
	opensuse) echo "sudo zypper install ${*}" ;;
	centos) echo "sudo yum install ${*}" ;;
	arch) echo "sudo pacman -S ${*}" ;;
	macos) echo "brew install ${*}" ;;
	*) echo "install ${*} manually" ;;
	esac
}

# ────────────────── dependency definitions ──────────────────

declare -A REQUIRED=()
REQUIRED["git"]="git"
REQUIRED["rg"]="ripgrep"
REQUIRED["ctags"]="universal-ctags"
REQUIRED["cc"]="C compiler (gcc/clang)"
REQUIRED["ts"]="tree-sitter-cli"
REQUIRED["fzf"]="fzf"

# packages for each OS (maps binary -> package name)
declare -A APT_NAMES=(
	["rg"]="ripgrep"
	["ctags"]="universal-ctags"
	["clangd"]="clangd"
	["gcc"]="gcc"
	["g++"]="g++"
	["go"]="golang-go"
	["python3"]="python3"
	["node"]="nodejs"
	["fzf"]="fzf"
)
declare -A PACMAN_NAMES=(
	["rg"]="ripgrep"
	["ctags"]="ctags"
	["clangd"]="clang"
	["gcc"]="gcc"
	["g++"]="gcc"
	["go"]="go"
	["python3"]="python"
	["node"]="nodejs"
	["lua-language-server"]="lua-language-server"
	["marksman"]="marksman"
	["glow"]="glow"
	["fzf"]="fzf"
)
declare -A BREW_NAMES=(
	["ctags"]="universal-ctags"
	["clangd"]="llvm"
	["gcc"]="gcc"
	["g++"]="gcc"
	["go"]="go"
	["python3"]="python"
	["node"]="node"
	["lua-language-server"]="lua-language-server"
	["marksman"]="marksman"
	["glow"]="glow"
	["fzf"]="fzf"
)
declare -A ZYPPER_NAMES=(
	["rg"]="ripgrep"
	["ctags"]="universal-ctags"
	["clangd"]="clang"
	["gcc"]="gcc"
	["g++"]="gcc-c++"
	["go"]="go"
	["python3"]="python3"
	["node"]="nodejs"
	["lua-language-server"]="lua-language-server"
	["marksman"]="marksman"
	["glow"]="glow"
	["fzf"]="fzf"
)
declare -A YUM_NAMES=(
	["rg"]="ripgrep"
	["ctags"]="universal-ctags"
	["clangd"]="clang-tools-extra"
	["gcc"]="gcc"
	["g++"]="gcc-c++"
	["go"]="golang"
	["python3"]="python3"
	["node"]="nodejs"
	["lua-language-server"]="lua-language-server"
	["marksman"]="marksman"
	["glow"]="glow"
	["fzf"]="fzf"
)

pkg_name() {
	local bin="$1"
	case "$OS" in
	debian) echo "${APT_NAMES[$bin]:-$bin}" ;;
	opensuse) echo "${ZYPPER_NAMES[$bin]:-$bin}" ;;
	centos) echo "${YUM_NAMES[$bin]:-$bin}" ;;
	arch) echo "${PACMAN_NAMES[$bin]:-$bin}" ;;
	macos) echo "${BREW_NAMES[$bin]:-$bin}" ;;
	*) echo "$bin" ;;
	esac
}

# ──────────── language-grouped optional deps ────────────

declare -A DEPS_BY_GROUP
DEPS_BY_GROUP["C/C++"]="gcc g++ clangd"
DEPS_BY_GROUP["Go"]="go gopls"
DEPS_BY_GROUP["Python"]="python3 pylsp"
DEPS_BY_GROUP["Rust"]="cargo rust-analyzer"
DEPS_BY_GROUP["Lua"]="lua-language-server"
DEPS_BY_GROUP["Shell"]="node bash-language-server"
DEPS_BY_GROUP["Vim"]="node vim-language-server"
DEPS_BY_GROUP["JavaScript/TypeScript"]="node typescript-language-server tsc"
DEPS_BY_GROUP["JSON"]="node vscode-json-language-server"
DEPS_BY_GROUP["YAML"]="node yaml-language-server"
DEPS_BY_GROUP["Markdown"]="marksman"
DEPS_BY_GROUP["Optional tools"]="glow"

# ──────────────────── main ────────────────────

echo -e "${BOLD}monkey-nvim dependency check${NC}"
echo ""

echo -e "${BOLD}Neovim version${NC}"
check_nvim_version
echo ""

# Check the OS
echo -e "${BOLD}Platform${NC}"
echo -e "  OS: ${CYAN}$(uname -s)${NC}"
case "$OS" in
debian) echo -e "  Package manager: ${CYAN}apt${NC}" ;;
opensuse) echo -e "  Package manager: ${CYAN}zypper${NC}" ;;
centos) echo -e "  Package manager: ${CYAN}yum${NC}" ;;
arch) echo -e "  Package manager: ${CYAN}pacman${NC}" ;;
macos) echo -e "  Package manager: ${CYAN}homebrew${NC}" ;;
*) echo -e "  ${WARN} Unsupported OS — install dependencies manually" ;;
esac
echo ""

# ──── required tools ────
echo -e "${BOLD}Required tools${NC}"
MISSING_REQUIRED=()

check_bin "git" || { MISSING_REQUIRED+=("git"); ALL_PASSED=false; }
check_bin "rg" "ripgrep" || { MISSING_REQUIRED+=("rg"); ALL_PASSED=false; }
check_bin "ctags" "universal-ctags" || { MISSING_REQUIRED+=("ctags"); ALL_PASSED=false; }
check_cc || { MISSING_REQUIRED+=("cc"); ALL_PASSED=false; }
check_ts || { MISSING_REQUIRED+=("ts"); ALL_PASSED=false; }
check_bin "fzf" || { MISSING_REQUIRED+=("fzf"); ALL_PASSED=false; }
echo ""

if $INSTALL_MODE && [[ ${#MISSING_REQUIRED[@]} -gt 0 ]]; then
	echo -e "${YELLOW}Installing: ${MISSING_REQUIRED[*]}...${NC}"
	for b in "${MISSING_REQUIRED[@]}"; do
		if [[ "$b" == "ts" ]]; then
			echo -e "  ${YELLOW}→ installing tree-sitter-cli via npm...${NC}"
			if sudo npm install -g tree-sitter-cli 2>/dev/null; then
				echo -e "  ${GREEN}Done.${NC}"
			else
				echo -e "  ${RED}Failed. Run: sudo npm install -g tree-sitter-cli${NC}"
			fi
		else
			pkgs=()
			pkgs+=("$(pkg_name "$b")")
			if install_pkg "${pkgs[@]}"; then
				echo -e "  ${GREEN}${b} installed.${NC}"
			else
				echo -e "  ${RED}Failed for ${b}. Run: $(get_install_hint "${pkgs[*]}")${NC}"
			fi
		fi
	done
	echo ""
fi

if $INSTALL_MODE; then
	MISSING_OPTIONAL=()
	for group in "C/C++" "Go" "Python" "Rust" "Lua" "Shell" "Vim" "JavaScript/TypeScript" "JSON" "YAML" "Markdown" "Optional tools"; do
		for bin in ${DEPS_BY_GROUP[$group]}; do
			if ! command -v "$bin" &>/dev/null; then
				MISSING_OPTIONAL+=("$bin")
			fi
		done
	done

	if [[ ${#MISSING_OPTIONAL[@]} -gt 0 ]]; then
		echo -e "${YELLOW}Installing optional LSP servers & tools: ${MISSING_OPTIONAL[*]}...${NC}"
		for bin in "${MISSING_OPTIONAL[@]}"; do
			echo -e "  ${YELLOW}→ installing ${bin}...${NC}"
			if install_optional_bin "$bin"; then
				echo -e "  ${GREEN}✓ ${bin} installed${NC}"
			else
				echo -e "  ${RED}✗ failed to install ${bin}${NC}"
				echo -e "    hint: $(get_install_hint "${bin}")"
			fi
		done
		echo -e "${GREEN}Done with optional installs.${NC}"
	else
		echo -e "${GREEN}All optional LSP servers & tools already installed.${NC}"
	fi
	echo ""
fi

# ──── optional LSP servers ────
echo -e "${BOLD}Optional: LSP servers & language tools${NC}"
echo "  (Install only what you need; missing servers won't block monkey-nvim)"
echo ""

if ! $INSTALL_MODE; then
	declare -A INSTALL_HINTS
	INSTALL_HINTS["clangd"]="$(get_install_hint clangd)  # or clangd-15+"
	INSTALL_HINTS["gcc"]="$(get_install_hint gcc)"
	INSTALL_HINTS["g++"]="$(get_install_hint g++)"
	INSTALL_HINTS["go"]="https://go.dev/dl/"
	INSTALL_HINTS["gopls"]="go install golang.org/x/tools/gopls@latest"
	INSTALL_HINTS["python3"]="$(get_install_hint python3)"
	INSTALL_HINTS["pylsp"]="pip install python-lsp-server"
	INSTALL_HINTS["cargo"]="https://rustup.rs/  # then: rustup component add rust-analyzer"
	INSTALL_HINTS["rust-analyzer"]="rustup component add rust-analyzer"
	INSTALL_HINTS["node"]="https://nodejs.org/  # or: $(get_install_hint nodejs npm)"
	INSTALL_HINTS["bash-language-server"]="npm install -g bash-language-server"
	INSTALL_HINTS["vim-language-server"]="npm install -g vim-language-server"
	INSTALL_HINTS["typescript-language-server"]="npm install -g typescript-language-server typescript"
	INSTALL_HINTS["tsc"]="npm install -g typescript"
	INSTALL_HINTS["vscode-json-language-server"]="npm install -g vscode-langservers-extracted"
	INSTALL_HINTS["yaml-language-server"]="npm install -g yaml-language-server"
	INSTALL_HINTS["lua-language-server"]="$(get_install_hint lua-language-server)"
	INSTALL_HINTS["marksman"]="$(get_install_hint marksman)"
	INSTALL_HINTS["glow"]="$(get_install_hint glow)  # or: go install github.com/charmbracelet/glow@latest"
fi

for group in "C/C++" "Go" "Python" "Rust" "Lua" "Shell" "Vim" "JavaScript/TypeScript" "JSON" "YAML" "Markdown" "Optional tools"; do
	echo -e "  ${BOLD}${group}${NC}"
	for bin in ${DEPS_BY_GROUP[$group]}; do
		status=0
		check_bin "$bin" &>/dev/null || status=$?
		if [[ $status -eq 0 ]]; then
			echo -e "    ${PASS} ${bin}"
		else
			echo -e "    ${FAIL} ${bin}  ${NC}${INSTALL_HINTS[$bin]}"
		fi
	done
	echo ""
done

# ──── terminal capabilities ────
echo -e "${BOLD}Terminal capabilities${NC}"
if [[ -n "${COLORTERM:-}" ]]; then
	echo -e "  ${PASS} COLORTERM=${COLORTERM}"
elif [[ "$TERM" =~ (256color|tmux|screen|alacritty|kitty|wezterm|xterm-kitty) ]]; then
	echo -e "  ${PASS} TERM=${TERM} (true color capable)"
else
	echo -e "  ${WARN} TERM=${TERM} — true color may not work"
fi
if [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" || "$OS" == "macos" ]]; then
	echo -e "  ${PASS} Clipboard support available"
else
	echo -e "  ${WARN} No display server — clipboard may be unavailable"
fi
if [[ "$LANG" == *".UTF-8" || "$LANG" == *".utf8" ]]; then
	echo -e "  ${PASS} LANG=${LANG}"
else
	echo -e "  ${WARN} LANG=${LANG} (UTF-8 recommended)"
fi
echo ""

# ──── config files ────
echo -e "${BOLD}Config files${NC}"
NVIM_DIR="${HOME}/.config/nvim"
REPO_DIR=""
if [[ -L "$NVIM_DIR" ]]; then
	TARGET=$(readlink -f "$NVIM_DIR" 2>/dev/null || readlink "$NVIM_DIR")
	REPO_DIR=$(dirname "$TARGET")
	echo -e "  ${PASS} nvim dir → ${TARGET}"
elif [[ -d "$NVIM_DIR" ]]; then
	echo -e "  ${WARN} ~/.config/nvim exists but is not a symlink"
else
	echo -e "  ${FAIL} ~/.config/nvim not found (run: ln -sf $(pwd) ~/.config/nvim)"
	ALL_PASSED=false
fi

SWAP_DIR="${HOME}/.local/state/nvim/swap"
if [ -d "$SWAP_DIR" ]; then
	echo -e "  ${PASS} swap/ dir exists"
else
	echo -e "  ${WARN} swap/ dir not found (auto-created on first nvim launch)"
fi

CACHE_DIR="${HOME}/.cache/sessions"
if [ -d "$CACHE_DIR" ]; then
	echo -e "  ${PASS} session cache dir exists"
else
	echo -e "  ${WARN} session cache dir not found (auto-created on first session save)"
fi

echo ""

# ──── summary ────
if $ALL_PASSED; then
	echo -e "${GREEN}${BOLD}All required dependencies satisfied.${NC}"
	exit 0
else
	echo -e "${RED}${BOLD}Some required dependencies are missing.${NC}"
	if ! $INSTALL_MODE; then
		echo -e "Run ${CYAN}$0 --install${NC} to install them automatically."
	fi
	exit 1
fi
