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
# values, and clones into the very directory clone_project would
# have used — one clone per run, not two.
PROJECT=monkey-nvim
PROJECT_REPO=https://github.com/QMonkey/monkey-nvim.git
INSTALL_DIR="${INSTALL_DIR:-$HOME/Documents/monkey-nvim}"

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
			printf '%s\n' "monkey-scripts missing from $_monkey_dir (no scripts/ subtree)." >&2
			printf '%s\n' "  git -C $_monkey_dir pull    # outdated checkout — or the repo never added the subtree" >&2
			exit 1
		fi
		_monkey_scripts="$_monkey_dir/scripts"
	else
		# curl|bash or a .git-less directory: the only path to a
		# same-revision scripts/ is the INSTALL_DIR checkout.
		# clone_project cannot do this job — it lives in the very
		# scripts/ being fetched. INSTALL_DIR is where the framework's clone
		# step would have put the checkout too, so that step only confirms it.
		if [ -d "$INSTALL_DIR/.git" ]; then
			# An install already lives here: update it, then run that one.
			git -C "$INSTALL_DIR" pull --ff-only || true
		elif [ -d "$INSTALL_DIR" ] && [ -n "$(ls -A "$INSTALL_DIR")" ]; then
			# git clone would refuse too, so say why in our own words.
			printf '%s\n' "$INSTALL_DIR is not empty and is not a git clone." >&2
			printf '%s\n' "  move it aside, delete it, or set INSTALL_DIR elsewhere." >&2
			exit 1
		else
			# Fresh clone — the ONLY sub-branch where git is hard-required:
			# the pull sub-branch above degrades gracefully without it, and
			# a zip/tarball must not fail here just for a missing git.
			if ! command -v git >/dev/null 2>&1; then
				printf '%s\n' "git is required to clone $PROJECT — install it first (e.g. sudo apt-get install git), then re-run." >&2
				exit 1
			fi
			# No retry() available yet — the framework loads only after this
			# clone succeeds — so inline 3 attempts. A failed
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
NVIM_SRC_DIR="${NVIM_SRC_DIR:-$HOME/Documents/neovim}" # the clone build_neovim compiles
ACQUIRE_TIOCSTI="${ACQUIRE_TIOCSTI:-monkey-nvim}"
# nvim's environment file, persisted at install time (see persist_nvim_env
# below). Declared here because SUMMARY_LINES renders it.
# ~/.config/env/ is a directory the family shares: one file per project, named
# after that project, not after any plugin it happens to configure — the
# profiles source it with `set -a`, so everything in it reaches
# nvim and every process nvim starts.
NVIM_ENV_FILE="${NVIM_ENV_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/env/nvim.env}"
# The keys the installer seeds today: exactly the ones lua/ai.lua reads. All
# of them are written; a preset registers only when its own set is non-empty.
# Any other nvim-scoped variable belongs in the same file, added by hand —
# render_fill leaves the lines it was not handed untouched.
NVIM_ENV_KEYS="NVIM_MINUET_PRESET NVIM_MINUET_API_KEY NVIM_MINUET_BASE_URL NVIM_MINUET_MODEL NVIM_MINUET_NAME NVIM_MINUET_LOCAL_BASE_URL NVIM_MINUET_LOCAL_MODEL NVIM_MINUET_LOCAL_NAME"
INSTALL_INFO=(
	"neovim source: ${CYAN}${NVIM_SRC_DIR}${NC} (cloned here; built when the installed nvim is below 0.12)"
)

# src|dst — init.lua writes project sessions to stdpath('data')/sessions and
# mkdir -p's them on first save; nvim's swap dir is stdpath('data')/swap
# (lua/editor.lua), which the ENSURE_DIRS below create at install time. The
# "keep" mode covers the repo-side extra configs (.clang-format, the
# efm-langserver config dir): an existing target is skipped with an info
# line, a missing source is skipped silently.
SYMLINKS=(
	"$INSTALL_DIR|$HOME/.config/nvim"
	"$INSTALL_DIR/configs/.clang-format|$HOME/.clang-format|keep"
	"$INSTALL_DIR/configs/efm-langserver|$HOME/.config/efm-langserver|keep"
)
ENSURE_DIRS=(
	"$HOME/.local/share/nvim/swap"
	"$HOME/.local/share/nvim/sessions"
)

# PATH exports land in the profile but only apply to shells started later —
# this installer persists them BEFORE linking (same output block).
PERSIST_PATH=1
PERSIST_POS=before_links
SUMMARY_LINES=(
	"  Config:   ${CYAN}$INSTALL_DIR${NC} → ${CYAN}~/.config/nvim${NC}"
	"  Env:      ${CYAN}${NVIM_ENV_FILE#"$HOME"/}${NC} (nvim environment; NVIM_MINUET_* always written, empty = unset)"
	"  Plugins:  managed by vim.pack (see init.lua)"
	""
	"  Run ${CYAN}nvim${NC} to start."
	"  Update nvim: ${CYAN}cd $NVIM_SRC_DIR && git pull && make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_GENERATOR='\"Unix Makefiles\"' && sudo make install CMAKE_GENERATOR='\"Unix Makefiles\"'${NC}"
	"  Update monkey-nvim: ${CYAN}cd $INSTALL_DIR && git pull${NC}"
)

# ──────────────────────── project steps ────────────────────────

# Build dependencies come from the shared install_build_deps (distro.sh):
# toolchain covers the compiler/make set per distro (base-devel on arch
# also pulls autoconf/bison/gettext/pkgconf), vcs adds git+curl, cmake and
# gettext complete the CMake build. The parsers tree-sitter compiles at
# runtime need only a C compiler — everything else (rg/ctags/fzf/node/...)
# is handled by checkhealth.sh --install.

nvim_at_least() {
	bin_at_least nvim 0.12
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
	clone_repo https://github.com/neovim/neovim.git "$NVIM_SRC_DIR" ||
		fail "neovim source clone failed."

	pushd "$NVIM_SRC_DIR" >/dev/null

	# Force the Unix Makefiles generator: the Makefile auto-picks Ninja
	# when it finds ninja on PATH, and a hung deps download under Ninja is
	# invisible (no progress, no timeout). BUILD.md's "no -j with ninja"
	# does not apply — make NEEDS -j, and the jobserver propagates it into
	# the deps build. The quotes must be INSIDE the make variable value.
	# The deps downloads have no timeout upstream, so both attempts are
	# wrapped in a timeout; a timeout or failure falls back to a serial
	# build. retry owns that timeout: macOS has no timeout binary (only
	# gtimeout via coreutils), so a raw call is not portable. retry -n 1
	# gives one attempt per call, keeping the caller's parallel→serial
	# fallback intact (TERM+KILL escalation via RETRY_KILL_AFTER).
	build_make() {
		retry -n 1 -t "$RETRY_T_NET" -s "make CMake build" make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_GENERATOR='"Unix Makefiles"' "$@"
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

# First headless launch: init.lua runs and zpack (vim.pack) clones every
# plugin — no output during the clones, spell out that the wait is normal
# instead of looking like a hang.
install_plugins() {
	# Re-preseed PATH: checkhealth --install runs as a SUBPROCESS, and the
	# tools it installs (tree-sitter-cli via npm → ~/.npm-global/bin, go/cargo
	# tools) only export PATH inside that child. Without this, the parser
	# builds below resolve no `tree-sitter` and every parser fails with
	# ENOENT while the CLI sits installed on disk (observed on Arch: every
	# parser dead). export_path is idempotent and skips missing
	# directories.
	export_path
	# An interrupted clone leaves a plugin directory holding .git but no
	# HEAD — vim.pack's lock repair then dies with "fatal: ambiguous
	# argument 'HEAD'" and the E5113 takes the whole headless run (and ALL
	# other plugins) down with it on every retry. A clone interrupted during
	# CHECKOUT is subtler: valid HEAD (the pack landed) but an empty
	# worktree — `module 'x' not found` despite the dir looking installed
	# (observed on Ubuntu: lualine.nvim). Sweep the plugin tree via the
	# shared repair_broken_clone --strict (clone.sh) before every attempt:
	# a dir without a readable HEAD is removed (re-clone from scratch); an
	# incomplete checkout is repaired OFFLINE (reset --hard — the objects
	# are all local). Plugin trees are never user-edited, so strict is safe
	# here; INSTALL_DIR keeps the conservative non-strict check.
	# vim.pack clones into site/pack/core/opt (zpack's pack group is "core").
	local pack_root="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/pack/core"
	local d
	for d in "$pack_root"/opt/* "$pack_root"/start/*; do
		repair_broken_clone --strict "$d"
	done
	info "Installing plugins (vim.pack) — no output below until done, may take a few minutes..."
	# stderr goes to a log, not /dev/null: every plugin download crosses the
	# network, so a GitHub clone error is the normal failure mode here and
	# must stay visible. vim.pack clones whatever is missing on the next
	# launch, so a failure here is recoverable.
	#
	# The success gate lives INSIDE the retried command, on purpose: nvim
	# --headless exits 0 even when init.lua died with a Lua error (E5113 —
	# plugin clone timeout; observed on CentOS: error printed, rc 0).
	# The child shell turns BOTH signals — nvim's own exit code and an
	# error line in the log — into a non-zero exit, so retry treats it as
	# a failed attempt and re-runs. vim.pack is idempotent (clones only
	# what is missing), so a re-attempt continues where the last one died.
	# The log must come up error-free for the success line.
	# The retried child re-runs the SAME sweep silently: attempt 1 itself
	# can leave a fresh .git-only directory (clone timeout), and later
	# attempts must not inherit it. repair_broken_clone crosses into the
	# child via export -f (warn and info come along — the repair reports
	# there too).
	export -f repair_broken_clone warn info
	if retry -t "$RETRY_T_HEAVY" -s "headless plugin bootstrap" bash -c '
		for d in '"$pack_root"'/opt/* '"$pack_root"'/start/*; do
			repair_broken_clone --strict "$d"
		done
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

# ──────────────────────── nvim environment ────────────────────────
# NVIM_ENV_FILE is nvim's own environment file: the profiles source it with
# `set -a`, so whatever it holds reaches nvim and every process nvim starts.
# What the installer seeds today is minuet-ai.nvim's provider configuration —
# lua/ai.lua reads those variables at startup and registers a preset only when
# every variable of that preset is set. There are no code-side defaults, so
# every key is written and an empty one means "unset" — a variable nvim.env
# exports as empty reaches lua/ai.lua as nil.
#
# The seeded names are exactly the ones lua/ai.lua reads, so nothing new is
# invented here — and nothing is shared: this owns no other project's credential
# store, reads no other project's variables, and re-running any other installer
# cannot change nvim's completion.
#
# Shape follows the family's env-file convention (values exported BEFORE the
# install land in a 0600 file under ~/.config/env/, the profiles get one
# marker-guarded line that sources it). The mechanism comes from scripts/
# (render_fill + append_env_block), the data stays nvim's own.
persist_nvim_env() {
	local preset="${NVIM_MINUET_PRESET:-}" k need="" missing=""
	case "$preset" in
	local_fim) need="NVIM_MINUET_LOCAL_NAME NVIM_MINUET_LOCAL_BASE_URL NVIM_MINUET_LOCAL_MODEL" ;;
	openai) need="NVIM_MINUET_API_KEY NVIM_MINUET_BASE_URL NVIM_MINUET_MODEL NVIM_MINUET_NAME" ;;
	"")
		info "NVIM_MINUET_PRESET is unset — minuet stays disabled (lua/ai.lua skips its setup) until one preset's keys are all non-empty. Writing every key empty for you to fill in."
		;;
	*)
		warn "NVIM_MINUET_PRESET=$preset is neither local_fim nor openai — lua/ai.lua registers no such preset, so minuet stays disabled (its keymaps are not bound either). Writing every key anyway."
		;;
	esac
	# A startup preset that is not registered skips the whole setup (keymaps
	# included), so an incomplete set is reported even though the file is
	# written — it is the hand-fill entry point for exactly this case.
	for k in $need; do
		[ -n "${!k:-}" ] || missing="$missing ${k#NVIM_MINUET_}"
	done
	[ -z "$missing" ] ||
		warn "NVIM_MINUET_PRESET=$preset but incomplete (missing$missing) — the preset will not register and minuet is never set up. Export all of them and re-run, or fill the lines in ${NVIM_ENV_FILE#"$HOME"/} by hand."
	# render_fill runs on python3, which checkhealth installs as a required
	# tool earlier in the chain; without it the file cannot be merged, and an
	# unsourced profile block would be worse than no block at all.
	have_native_cmd python3 || {
		warn "python3 not found — cannot write ${NVIM_ENV_FILE##*/} (render_fill needs it). nvim env not persisted; re-run after the dependency pass."
		return 0
	}
	# Every key, not only the exported ones: render_fill keeps an existing
	# non-empty value over this run's environment either way, and the keys with
	# no value land as empty placeholders that lua/ai.lua reads as unset.
	render_fill "$INSTALL_DIR/nvim.env.template" "$NVIM_ENV_FILE" $NVIM_ENV_KEYS || return 0
	append_env_block "nvim env (remove these lines to disable)" "$(env_source_line "$NVIM_ENV_FILE")"
	info "nvim env: NVIM_MINUET_* persisted to ${NVIM_ENV_FILE#"$HOME"/} (0600), empty = unset."
	info "nvim env: a value already in that file wins over this run's export — edit the file to change one."
	printf '\n'
}

# ──────────────────────── hooks ────────────────────────
# A hook prints its own trailing blank line when it produced output.
install_step_prepare() {
	# First: make $XDG_RUNTIME_DIR usable. The headless nvim in
	# install_plugins runs fzf-lua, which calls serverstart() at require
	# time — on a sessionless WSL (root default user) that fails with a
	# misleading Lua load error. See README 'Precautions' → WSL2.
	ensure_xdg_runtime_dir
	install_build_deps toolchain vcs cmake gettext
	printf '\n'
	brew_ensure
	printf '\n'
}
install_step_tool() {
	build_neovim
	printf '\n'
}
install_step_after() {
	install_plugins
	# Last: the profiles already carry the family's PATH and credential blocks,
	# so the nvim env block lands among them, and the dependency pass that
	# brings python3 (render_fill's engine) has already run.
	persist_nvim_env
	printf '\n'
}

install_main "$@"
