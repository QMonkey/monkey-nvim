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
# No scripts/ next to this file: either a checkout predating the subtree
# commit (pull it in and carry on), a .git-less directory (zip/tarball),
# or `curl | bash`, which has no checkout at all. The latter two bootstrap
# through INSTALL_DIR and run the install.sh from that checkout, so
# installer and scripts/ always come from the same revision.
_monkey_scripts="$(dirname "${BASH_SOURCE[0]:-$0}")/scripts"
if [ ! -f "$_monkey_scripts/install.sh" ]; then
	_monkey_self="${BASH_SOURCE[0]:-$0}"
	_monkey_dir="$(dirname "$_monkey_self")"
	if [ -f "$_monkey_self" ] && [ -d "$_monkey_dir/.git" ]; then
		# Outdated checkout: update it in place and keep running from it.
		git -C "$_monkey_dir" pull --ff-only || true
		if [ ! -f "$_monkey_dir/scripts/install.sh" ]; then
			echo "monkey-scripts missing from $_monkey_dir (no scripts/ subtree)." >&2
			echo "  git -C $_monkey_dir pull    # outdated checkout — or the repo never added the subtree" >&2
			exit 1
		fi
		_monkey_scripts="$_monkey_dir/scripts"
	else
		# curl|bash or a .git-less directory: the only path to a
		# same-revision scripts/ is the INSTALL_DIR checkout.
		# clone_monkey_project cannot do this job — it lives in the very
		# scripts/ being fetched. INSTALL_DIR is where the framework's clone
		# step would have put the checkout too, so that step only confirms it.
		if [ -d "$INSTALL_DIR/.git" ]; then
			# An install already lives here: update it, then run that one.
			git -C "$INSTALL_DIR" pull --ff-only || true
		elif [ -d "$INSTALL_DIR" ] && [ -n "$(ls -A "$INSTALL_DIR")" ]; then
			# git clone would refuse too, so say why in our own words.
			echo "$INSTALL_DIR is not empty and is not a git clone." >&2
			echo "  move it aside, delete it, or set INSTALL_DIR elsewhere." >&2
			exit 1
		else
			# Fresh clone — the ONLY sub-branch where git is hard-required:
			# the pull sub-branch above degrades gracefully without it, and
			# a zip/tarball must not fail here just for a missing git.
			if ! command -v git >/dev/null 2>&1; then
				echo "git is required to clone $PROJECT — install it first (e.g. sudo apt-get install git), then re-run." >&2
				exit 1
			fi
			# No retry() available yet — the framework loads only after this
			# clone succeeds — so inline the standard 3 attempts. A failed
			# clone leaves a partial directory behind; remove it so the next
			# attempt cannot trip over "already exists". This branch only
			# runs on a fresh install (INSTALL_DIR did not exist or was
			# empty), so the rm can never delete pre-existing data.
			_monkey_rc=1
			for _monkey_attempt in 1 2 3; do
				if git clone "$PROJECT_REPO" "$INSTALL_DIR"; then
					_monkey_rc=0
					break
				fi
				rm -rf "$INSTALL_DIR"
				if [ "$_monkey_attempt" -lt 3 ]; then
					sleep 2
				fi
			done
			[ "$_monkey_rc" -eq 0 ] || exit 1
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

# Build dependencies come from the shared install_build_deps (pkg.sh):
# toolchain covers the compiler/make set per distro (base-devel on arch
# also pulls autoconf/bison/gettext/pkgconf), vcs adds git+curl, cmake and
# gettext complete the CMake build. The old per-distro case lived here;
# the parsers tree-sitter compiles at runtime need only a C compiler —
# everything else (rg/ctags/fzf/node/...) is handled by checkhealth.sh
# --install (step 5).

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
		retry -s "git pull" git -C "$NVIM_SRC_DIR" pull --ff-only ||
			warn "git pull failed — building from existing source."
	else
		# A failed clone leaves a partial directory behind, which would make
		# every later attempt (and re-run) fail with "already exists" — clean
		# it up before giving up, but only when git created it (.git inside)
		# or it is empty, never when it holds pre-existing user data.
		if ! retry -t 1800 -s "git clone neovim" git clone https://github.com/neovim/neovim.git "$NVIM_SRC_DIR"; then
			if [ -d "$NVIM_SRC_DIR" ] && { [ -z "$(ls -A "$NVIM_SRC_DIR")" ] || [ -d "$NVIM_SRC_DIR/.git" ]; }; then
				rm -rf "$NVIM_SRC_DIR"
			fi
			fail "neovim source clone failed after 3 attempts."
		fi
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
	# Re-preseed PATH: checkhealth --install runs as a SUBPROCESS, and the
	# tools it installs (tree-sitter-cli via npm → ~/.npm-global/bin, go/cargo
	# tools) only export PATH inside that child. Without this, the parser
	# builds below resolve no `tree-sitter` and every parser fails with
	# ENOENT while the CLI sits installed on disk (observed on Arch: all 17
	# parsers dead). preseed_path is idempotent and skips missing
	# directories.
	preseed_path
	info "Installing plugins (vim.pack) — no output below until done, may take a few minutes..."
	# stderr goes to a log, not /dev/null: a hidden failure (e.g. a GitHub
	# clone error — every plugin download crosses the network) used to fall
	# through to the success line below and the plugins were simply missing.
	# vim.pack clones whatever is missing on the next launch, so a failure
	# here is recoverable, but it must be visible.
	#
	# The success gate lives INSIDE the retried command, on purpose: nvim
	# --headless exits 0 even when init.lua died with a Lua error (E5113 —
	# plugin clone timeout; observed on CentOS: error printed,
	# rc 0, retry never fired, "[ OK ] Plugins installed." printed anyway).
	# The child shell turns BOTH signals — nvim's own exit code and an
	# error line in the log — into a non-zero exit, so retry treats it as
	# a failed attempt and re-runs. vim.pack is idempotent (clones only
	# what is missing), so a re-attempt continues where the last one died.
	# The log must come up error-free for the success line.
	if retry -t 3600 -s "headless plugin bootstrap" bash -c '
		nvim --headless "+quit" 2>&1 | tee /tmp/nvim-plugins.log
		rc=${PIPESTATUS[0]}
		if [ "$rc" -ne 0 ] || grep -q "Error in" /tmp/nvim-plugins.log; then
			exit 1
		fi
	'; then
		ok "Plugins installed."
	else
		warn "Headless plugin bootstrap failed — see /tmp/nvim-plugins.log."
		warn "Plugins retry automatically on the next nvim launch, or run: nvim --headless \"+quit\""
	fi
}

# A hook prints its own trailing blank line when it produced output.
install_step_prepare() {
	# First: make $XDG_RUNTIME_DIR usable. The headless nvim in
	# install_plugins runs fzf-lua, which calls serverstart() at require
	# time — on a sessionless WSL (root default user) that fails with a
	# misleading Lua load error. See README 'Precautions' → WSL2.
	ensure_xdg_runtime_dir
	install_build_deps toolchain vcs cmake gettext
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
