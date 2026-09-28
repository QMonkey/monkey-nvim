#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────────────────────
# monkey-nvim one-shot installer
# Usage: curl -fsSL https://raw.githubusercontent.com/QMonkey/monkey-nvim/master/install.sh | bash
#
# The shared installer (sudo, packages, clone, checkhealth, symlinks,
# completion) lives in scripts/ — a `git subtree` of
# github.com/QMonkey/monkey-scripts. On the curl|bash path there is no
# checkout at all, so install.sh clones THIS repo and runs the copy of
# install.sh inside it — that copy carries its own scripts/, so the
# installer and the framework it loads are always the same revision.
# ──────────────────────────────────────────────────────────────

# ──────────────────────── repository identity ────────────────────────
# Declared before the framework is sourced: the bootstrap below needs both
# values, and clones into the very directory clone_monkey_project would
# have used — one clone per run, not two.
PROJECT=monkey-nvim
PROJECT_REPO=https://github.com/QMonkey/monkey-nvim.git
INSTALL_DIR="${INSTALL_DIR:-$HOME/Documents/monkey-nvim}"

# No scripts/ next to this file: either a checkout predating the subtree
# commit (pull it in and carry on) or `curl | bash`, which has no checkout
# at all. The latter clones THIS project and runs the install.sh from that
# checkout, so installer and scripts/ always come from the same revision.
_monkey_scripts="$(dirname "${BASH_SOURCE[0]:-$0}")/scripts"
if [ ! -f "$_monkey_scripts/install.sh" ]; then
	_monkey_self="${BASH_SOURCE[0]:-$0}"
	_monkey_dir="$(dirname "$_monkey_self")"
	if [ -f "$_monkey_self" ] && [ -d "$_monkey_dir/.git" ]; then
		git -C "$_monkey_dir" pull --ff-only || true
		_monkey_scripts="$_monkey_dir/scripts"
		if [ ! -f "$_monkey_scripts/install.sh" ]; then
			echo "monkey-scripts missing from $_monkey_dir (no scripts/ subtree)." >&2
			echo "  git -C $_monkey_dir pull    # outdated checkout — or the repo never added the subtree" >&2
			exit 1
		fi
	else
		# curl|bash: no checkout at all. Get one that carries scripts/ and
		# hand over to its installer, so install.sh and scripts/ can never be
		# different revisions. clone_monkey_project cannot do this job — it
		# lives in the very scripts/ being fetched. INSTALL_DIR is where the
		# framework's clone step would have put the checkout too, so that step
		# only confirms it.

		if ! command -v git >/dev/null 2>&1; then
			echo "git is required to clone $PROJECT — install it first (e.g. sudo apt-get install git), then re-run." >&2
			exit 1
		fi
		if [ -d "$INSTALL_DIR/.git" ]; then
			# An install already lives here: update it, then run that one.
			git -C "$INSTALL_DIR" pull --ff-only || true
		elif [ -d "$INSTALL_DIR" ] && [ -n "$(ls -A "$INSTALL_DIR")" ]; then
			# git clone would refuse too, so say why in our own words.
			echo "$INSTALL_DIR is not empty and is not a git clone." >&2
			echo "  move it aside, delete it, or set INSTALL_DIR elsewhere." >&2
			exit 1
		else
			git clone "$PROJECT_REPO" "$INSTALL_DIR" || exit 1
		fi
		# </dev/null: on the curl|bash path stdin is the script pipe, and the
		# inner installer must not read what is left of the outer one.
		exec bash "$INSTALL_DIR/install.sh" "$@" </dev/null
	fi
fi
# shellcheck source=/dev/null
. "$_monkey_scripts/install.sh"

# ──────────────────────── layout & data ────────────────────────
NVIM_SRC_DIR="${NVIM_SRC_DIR:-$HOME/Documents/neovim}" # kept for future updates
JOBS="${JOBS:-$(nproc 2>/dev/null || echo 4)}"
ACQUIRE_TIOCSTI="${ACQUIRE_TIOCSTI:-monkey-nvim}"
INSTALL_INFO=(
	"neovim source: ${CYAN}${NVIM_SRC_DIR}${NC} (kept for future updates)"
)

# src|dst — init.lua writes project sessions to stdpath('data')/sessions and
# mkdir -p's them on first save; swap/ is created on first nvim launch.
SYMLINKS=(
	"$INSTALL_DIR|$HOME/.config/nvim"
)
ENSURE_DIRS=(
	"$HOME/.local/state/nvim/swap"
	"$HOME/.local/share/nvim/sessions"
)

# PATH exports land in the profile but only apply to shells started later —
# the original installer persists them BEFORE linking (same output block).
PERSIST_PATH=1
PERSIST_POS=before_links
SUMMARY_LINES=(
	"  Config:   ${CYAN}$INSTALL_DIR${NC} → ${CYAN}~/.config/nvim${NC}"
	"  Plugins:  managed by vim.pack (see init.lua)"
	""
	"  Run ${CYAN}nvim${NC} to start."
	"  Update nvim: ${CYAN}cd $NVIM_SRC_DIR && git pull && make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_GENERATOR='\"Unix Makefiles\"' && sudo make install${NC}"
	"  Update monkey-nvim: ${CYAN}cd $INSTALL_DIR && git pull${NC}"
)

# ──────────────────────── project steps ────────────────────────

install_build_deps() {
	# Neovim builds with CMake+make; the parsers tree-sitter compiles at
	# runtime need a C compiler. Everything else (rg/ctags/fzf/node/...) is
	# handled by checkhealth.sh --install (step 5).
	info "Installing Neovim build dependencies..."
	refresh_pkg
	case "$OS" in
	debian | ubuntu)
		sudo_cmd apt-get install -y gettext cmake curl build-essential git
		;;
	arch)
		sudo_cmd pacman -S --needed --noconfirm base-devel git curl cmake gettext
		;;
	opensuse)
		sudo_cmd zypper --non-interactive install -y -t pattern devel_basis
		sudo_cmd zypper --non-interactive install -y git curl cmake gettext
		;;
	centos)
		# Some tools come from EPEL on RHEL rebuilds.
		sudo_cmd dnf install -y epel-release || true
		sudo_cmd dnf install -y gcc gcc-c++ make git curl cmake gettext
		;;
	fedora)
		# No EPEL on Fedora — the same names ship in the base repos.
		sudo_cmd dnf install -y gcc gcc-c++ make git curl cmake gettext
		;;
	macos)
		# Homebrew's neovim formula is current; these are only needed if the
		# source build in build_neovim has to run on macOS. git is required
		# regardless — build_neovim and clone_monkey_nvim both clone.
		if have_native_cmd brew; then
			brew install git cmake gettext
		else
			warn "Homebrew not found — cannot install neovim build deps. Install it first: https://brew.sh"
		fi
		;;
	*)
		warn "Unknown OS ($OS). Attempting to continue with whatever is available."
		;;
	esac
	hash -r # re-scan PATH: fresh binaries must not be shadowed by cached shim paths
	ok "Build dependencies installed."
}

nvim_at_least() {
	have_native_cmd nvim || return 1
	local ver
	ver=$(nvim --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+' || true)
	[[ -z "$ver" ]] && return 1
	local major=${ver%%.*} minor=${ver#*.}
	((major > 0 || (major == 0 && minor >= 12)))
}

build_neovim() {
	if nvim_at_least; then
		local ver
		# `|| true`: head -1 can close the pipe before nvim finishes writing,
		# making nvim die with SIGPIPE (141) and, under pipefail + set -e,
		# silently aborting the whole script.
		ver=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' || true)
		ok "Neovim ${ver} already installed and meets requirement (>= 0.12). Skipping build."
		return 0
	fi
	warn "Neovim 0.12+ not found or below requirement — building from source."

	info "Building Neovim from source (this may take a few minutes)..."
	if [ -d "$NVIM_SRC_DIR/.git" ]; then
		info "Neovim source already exists at $NVIM_SRC_DIR — pulling latest..."
		git -C "$NVIM_SRC_DIR" pull --ff-only || warn "git pull failed — building from existing source."
	else
		git clone https://github.com/neovim/neovim.git "$NVIM_SRC_DIR"
	fi

	pushd "$NVIM_SRC_DIR" >/dev/null

	# Force the Unix Makefiles generator: the Makefile auto-picks Ninja
	# when it finds ninja on PATH, and a hung deps download under Ninja is
	# invisible (no progress, no timeout). BUILD.md's "no -j with ninja"
	# does not apply — make NEEDS -j, and the jobserver propagates it into
	# the deps build. The quotes must be INSIDE the make variable value.
	# The deps downloads have no timeout upstream, so both attempts are
	# wrapped in timeout; a timeout or failure falls back to a serial build.
	build_make() {
		timeout -k 60 1800 make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_GENERATOR='"Unix Makefiles"' "$@"
	}
	info "Compiling Neovim (RelWithDebInfo, parallel)..."
	if build_make -j"$JOBS" 2>&1 | tee /tmp/nvim-build.log; then
		:
	else
		warn "parallel build timed out or failed — retrying serially..."
		if ! build_make 2>&1 | tee /tmp/nvim-build.log; then
			fail "Neovim build failed. Check /tmp/nvim-build.log"
		fi
	fi

	info "Installing Neovim..."
	# The Makefile's .ran-deps-cmake stamp has the .deps DIRECTORY as a
	# prerequisite, so `make install` can re-run the cmake configure — the
	# generator must be forced here too.
	sudo_cmd make install CMAKE_GENERATOR='"Unix Makefiles"' 2>&1 | tee /tmp/nvim-install.log || {
		fail "Neovim install failed. Check /tmp/nvim-install.log"
	}

	popd >/dev/null

	# Update PATH so the newly built nvim is found
	export PATH="/usr/local/bin:$PATH"

	if nvim_at_least; then
		local ver
		ver=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' || true)
		ok "Neovim ${ver} built and installed successfully."
	else
		fail "Neovim build completed but nvim is not found in PATH."
	fi
}

# efm-langserver ships a repo-side config dir: link it once, and never touch
# an existing target (the repo may not even ship the source).
install_efm_config() {
	if [ -d "$INSTALL_DIR/configs/efm-langserver" ]; then
		if [ -e "$HOME/.config/efm-langserver" ] || [ -L "$HOME/.config/efm-langserver" ]; then
			info "efm-langserver config already exists — skipping."
		else
			mkdir -p "$HOME/.config"
			ln -sfn "$INSTALL_DIR/configs/efm-langserver" "$HOME/.config/efm-langserver"
			ok "efm-langserver config → $HOME/.config/efm-langserver"
		fi
	fi
}

# First headless launch: init.lua runs and zpack (vim.pack) clones every
# plugin — no output during the clones, spell out that the wait is normal
# instead of looking like a hang.
install_plugins() {
	info "Installing plugins (vim.pack) — no output below until done, may take a few minutes..."
	nvim --headless "+quit" 2>/dev/null || {
		warn "Headless plugin bootstrap failed. Plugins will be installed on first launch."
	}
	ok "Plugins installed."
}

# A hook prints its own trailing blank line when it produced output.
install_step_prepare() {
	install_build_deps
	echo ""
	install_linuxbrew
	echo ""
}
install_step_tool() {
	build_neovim
	echo ""
}
install_step_symlinks() {
	install_efm_config
}
install_step_after() {
	install_plugins
	echo ""
}

install_main "$@"
