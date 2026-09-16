#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────────────────────
# monkey-nvim one-shot installer
# Usage: curl -fsSL https://raw.githubusercontent.com/QMonkey/monkey-nvim/master/install.sh | bash
# ──────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

INSTALL_DIR="${INSTALL_DIR:-$HOME/Documents/monkey-nvim}"
NVIM_SRC_DIR="${NVIM_SRC_DIR:-$HOME/Documents/neovim}"
JOBS="${JOBS:-$(nproc 2>/dev/null || echo 4)}"
SUDOERS_D_DIR="${SUDOERS_D_DIR:-/etc/sudoers.d}"
SUDO_NOPASSWD=0
NOPASSWD_DROPIN="$SUDOERS_D_DIR/zz-monkey-nvim-nopasswd"

# Never let a missing HOME fail later under `set -u`.
[ -n "${HOME:-}" ] || {
	echo "[FAIL] \$HOME is not set — cannot determine install locations." >&2
	exit 1
}

info() { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok() { echo -e "${GREEN}[  OK]${NC}  $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC}  $*"; }
fail() {
	echo -e "${RED}[FAIL]${NC}  $*"
	exit 1
}

# ────────────────── OS / WSL detection ──────────────────

os_detect() {
	case "$(uname -s)" in
	Linux)
		if [ -f /etc/os-release ]; then
			# shellcheck disable=SC1091
			. /etc/os-release
			case "${ID:-}" in
			ubuntu | debian | linuxmint | pop | elementary | zorin) echo "debian" ;;
			arch | manjaro | endeavouros) echo "arch" ;;
			opensuse* | suse | sles) echo "opensuse" ;;
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

# WSL interop appends the WINDOWS PATH to ours, so tools installed on the
# Windows side (node, python, sudo.exe, ...) appear as /mnt/c/... shims.
# They are not Linux binaries and root's secure_path cannot see them —
# treat /mnt/* resolutions as "not installed" so the real Linux packages
# get installed instead.
have_native_cmd() {
	command -v "$1" &>/dev/null || return 1
	case "$(command -v "$1")" in
	/mnt/*) return 1 ;; # WSL Windows-interop shim
	esac
	return 0
}

# Absolute path to a LINUX sudo, or non-zero.
native_sudo() {
	local p
	have_native_cmd sudo || return 1
	p=$(command -v sudo)
	printf '%s' "$p"
}

OS=$(os_detect)

sudo_cmd() {
	# Lazy re-auth: Homebrew resets the sudo timestamp on EVERY invocation
	# (brew.sh runs `sudo --reset-timestamp` at startup), so a ticket that
	# was valid a minute ago can be dead here. Re-authenticate proactively
	# with an explanatory prompt instead of letting the command fail or
	# spring a context-free password prompt. `-n true` never prompts; the
	# interactive `-v` only runs when the ticket is actually gone.
	local sudo_bin
	sudo_bin=$(native_sudo) || {
		"$@"
		return
	}
	if ! "$sudo_bin" -n true 2>/dev/null; then
		"$sudo_bin" -v -p "[monkey-nvim] sudo credentials needed to continue — enter your password: " || return 1
	fi
	"$sudo_bin" "$@"
}

# Print the shell startup files for the detected shell. Two cases:
#   - zsh: profile ONLY (~/.zprofile). rc files like ~/.zshrc are often
#     repo-managed dotfiles — appending to them dirties the repo; non-login
#     zsh shells get the profile via a `source ~/.zprofile` guard in the rc file instead.
#   - bash: profile AND rc (~/.profile + ~/.bashrc). Non-login interactive
#     bash (WSL's wsl.exe, desktop terminal emulators, VS Code terminal)
#     only reads ~/.bashrc — .profile does not get pulled in there — so both files are needed.
shell_env_files() {
	local shell="${SHELL:-bash}"
	shell="${shell##*/}"
	case "$shell" in
	zsh)
		printf '%s\n' "$HOME/.zprofile"
		;;
	bash)
		if [ -f "$HOME/.bash_profile" ]; then
			printf '%s\n' "$HOME/.bash_profile"
		else
			printf '%s\n' "$HOME/.profile"
		fi
		printf '%s\n' "$HOME/.bashrc"
		;;
	*)
		printf '%s\n' "$HOME/.profile"
		;;
	esac
}

append_env_block() {
	# Usage: append_env_block <marker> <block>
	# Appends <block> guarded by <marker> to every shell env file, once.
	local marker="$1"
	local block="$2"
	local f
	while IFS= read -r f; do
		[ -n "$f" ] || continue
		[ -f "$f" ] || touch "$f"
		if ! grep -qF -- "$marker" "$f" 2>/dev/null; then
			printf '\n# %s\n%b\n' "$marker" "$block" >>"$f"
			ok "Added '$marker' to $f"
		fi
	done < <(shell_env_files)
}

refresh_path() {
	# In-session PATH refresh so newly installed tools are found by this script.
	if have_native_cmd go; then
		local gopath
		gopath=$(go env GOPATH 2>/dev/null || echo "$HOME/go")
		export PATH="$gopath/bin:$PATH"
	fi
	# Not `[ ... ] && . ...`: when the file is missing the function returns
	# non-zero and, under set -e, silently aborts the whole script.
	if [ -f "$HOME/.cargo/env" ]; then . "$HOME/.cargo/env"; fi
}

# ────────────────── sudo setup (auth + drop-ins + keepalive) ──────────────────

SUDO_KEEPALIVE_PID=""

cleanup_sudo() {
	# Kill the keepalive (if running) and remove the temporary NOPASSWD
	# drop-in. `sudo -n rm` works while NOPASSWD is still in place — the
	# file grants it, so removal never needs a password.
	if [ -n "$SUDO_KEEPALIVE_PID" ]; then
		kill "$SUDO_KEEPALIVE_PID" 2>/dev/null
		wait "$SUDO_KEEPALIVE_PID" 2>/dev/null
	fi
	if [ "$SUDO_NOPASSWD" -eq 1 ] && [ -n "$SUDO_BIN" ]; then
		"$SUDO_BIN" -n rm -f "$NOPASSWD_DROPIN" 2>/dev/null ||
			warn "could not remove the NOPASSWD drop-in — remove it manually: sudo rm $NOPASSWD_DROPIN"
	fi
}

setup_sudo() {
	# Keep sudo credentials alive for the whole run: the gap between the first
	# sudo (build deps) and later ones (make install) can exceed the default
	# 15-min timestamp_timeout on slow downloads/compiles. A re-auth prompt
	# then aborts unattended runs (no TTY to answer it).
	# Skip when running as root or when no native sudo is available.
	SUDO_BIN=$(native_sudo) || return 0
	if [ "$(id -u)" -eq 0 ]; then
		return 0
	fi
	# Pre-authenticate so the password is entered at the very start instead
	# of mid-run after a long download/compile, then grant NOPASSWD for the
	# rest of the run:
	#
	# Probe first (`-n true`, a command): when credentials are already
	# valid — this run's own drop-in from a previous stage, or an outer
	# installer's grant — skip the authenticate step entirely; chained
	# stages never re-prompt. Failure means no valid grant exists and
	# `sudo -v` prompts for the one password of the run.
	#
	# Why the drop-in is NOPASSWD: authentication is granted by the rule
	# itself and the timestamp is never consulted, so brew's
	# --reset-timestamp, clock jumps and plain expiry are all harmless.
	# GNU sudo resolves conflicting rules last-match-wins, so this drop-in
	# (parsed after the distro's password-required rule) always wins.
	# sudo-rs would defeat this tag for VALIDATE (max_by_key picks the
	# password-required rule) — but every sudo in this script is a command
	# or the probe, where NOPASSWD wins on both implementations.
	if ! "$SUDO_BIN" -n true 2>/dev/null; then
		"$SUDO_BIN" -v || fail "sudo authorization failed — run this script in an interactive terminal."
	fi
	# Scoped to the invoking user and REMOVED on exit (incl. Ctrl-C);
	# if the script is SIGKILLed the file survives — remove manually with
	# `sudo rm $NOPASSWD_DROPIN`. If you prefer a permanent passwordless
	# sudo, add the same line to your own sudoers drop-in instead.
	if printf '%s ALL=(ALL) NOPASSWD: ALL\n' "$(id -un)" |
		"$SUDO_BIN" -n sh -c 'umask 077; cat >"$1" && chmod 0440 "$1" && visudo -c -f "$1" >/dev/null 2>&1 || { rm -f "$1"; exit 1; }' sh "$NOPASSWD_DROPIN" >/dev/null 2>&1; then
		SUDO_NOPASSWD=1
		ok "Temporary NOPASSWD drop-in installed for this run (auto-removed on exit)."
	else
		warn "could not install the temporary NOPASSWD drop-in — falling back to keepalive + lazy re-auth."
	fi
	if [ "$SUDO_NOPASSWD" -eq 0 ]; then
		# Fallback when NOPASSWD could not be installed: refresh the ticket
		# in the background so plain expiry does not prompt mid-run. It
		# cannot fully protect the run — brew resets the ticket by design
		# and WSL clock steps disable it — so when this stops, sudo_cmd()
		# re-authenticates lazily (one explanatory prompt) at the next
		# privileged call.
		(
			# 60s refresh against the 15-min default timeout leaves a 15x
			# margin; override via SUDO_KEEPALIVE_INTERVAL if needed.
			interval="${SUDO_KEEPALIVE_INTERVAL:-60}"
			# Kill the in-flight `sleep` child when TERMed, and wait() to
			# reap — WSL's init does not reap adopted zombies.
			trap 'kill $(jobs -p) 2>/dev/null; wait 2>/dev/null; exit 0' TERM
			while true; do
				sleep "$interval" &
				wait "$!" 2>/dev/null || exit 0
				if ! "$SUDO_BIN" -n true 2>/dev/null; then
					warn "sudo keepalive stopped — expected after a brew run; the next privileged command re-authenticates."
					exit 0
				fi
			done
		) &
		SUDO_KEEPALIVE_PID=$!
	fi
	# Recycle the background loop and drop the NOPASSWD grant on any exit
	# path (success, fail, Ctrl-C).
	trap cleanup_sudo EXIT
	trap 'exit 130' INT
	trap 'exit 143' TERM
}

# ────────────────── Step 1: Install build deps for Neovim ──────────────────

install_build_deps() {
	# Neovim builds with CMake+Ninja; the parsers tree-sitter compiles at
	# runtime need a C compiler. Everything else (rg/ctags/fzf/node/...) is
	# handled by checkhealth.sh --install (step 5).
	info "Installing Neovim build dependencies..."
	case "$OS" in
	debian)
		sudo_cmd apt-get update -q
		sudo_cmd apt-get install -y ninja-build gettext cmake curl build-essential git
		;;
	arch)
		sudo_cmd pacman -S --needed --noconfirm base-devel git curl cmake ninja gettext
		;;
	opensuse)
		sudo_cmd zypper --non-interactive install -y -t pattern devel_basis
		sudo_cmd zypper --non-interactive install -y git curl cmake ninja gettext
		;;
	centos)
		sudo_cmd dnf install -y epel-release || true
		sudo_cmd dnf install -y gcc gcc-c++ make git curl cmake ninja-build gettext
		;;
	macos)
		# Homebrew's neovim formula is current; these are only needed if the
		# source build in build_neovim has to run on macOS.
		if have_native_cmd brew; then
			brew install ninja cmake gettext
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

# ────────────────── Step 2: Install Homebrew / Linuxbrew ──────────────────

install_linuxbrew() {
	local brew_prefix=""
	if have_native_cmd brew; then
		brew_prefix="$(dirname "$(dirname "$(command -v brew)")")"
		ok "Homebrew already installed at $brew_prefix."
	else
		info "Installing Homebrew/Linuxbrew..."
		# NOTE: the installer's exit trap runs `sudo -k` (and the `brew`
		# commands it spawns reset the timestamp too) — that used to require
		# sed-patching the installer, but the temporary NOPASSWD drop-in
		# makes the timestamp irrelevant, so the official installer runs
		# unmodified. If the NOPASSWD drop-in failed to install, the next
		# privileged command simply re-authenticates once (sudo_cmd).
		# Download fully before executing: `curl | bash` would run a
		# truncated script if the connection drops mid-stream.
		local installer="/tmp/homebrew_install.$$.sh"
		local fetched=0 attempt
		# `curl -fsSL -o` is silent: on a slow network the download (and its
		# retries) would look like a hang without this line.
		info "Downloading the Homebrew installer..."
		for attempt in 1 2 3; do
			if curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$installer"; then
				fetched=1
				break
			fi
			sleep 2
		done
		if [ "$fetched" != 1 ]; then
			warn "Homebrew installer download failed — continuing without Homebrew."
			return 0
		fi
		NONINTERACTIVE=1 /bin/bash "$installer" ||
			warn "Homebrew installer failed — continuing without Homebrew."
		rm -f "$installer"

		local cand
		for cand in /home/linuxbrew/.linuxbrew /opt/homebrew /usr/local; do
			if [ -x "$cand/bin/brew" ]; then
				brew_prefix="$cand"
				break
			fi
		done
	fi

	if [ -n "$brew_prefix" ]; then
		eval "$("$brew_prefix/bin/brew" shellenv)"
		ok "Homebrew/Linuxbrew ready at $brew_prefix."
		# Persist shellenv for future shells (login + interactive rc).
		# Runs even when brew pre-dates this run: without it, brew-installed
		# tools (node/npm/...) vanish from PATH in new shells. Idempotent —
		# append_env_block skips if the marker is already present.
		# The case guard makes re-sourcing (e.g. a login .profile sourcing
		# .bashrc, both carrying this block) a no-op instead of prepending
		# brew's bin/sbin to PATH twice.
		local line
		line="case \":\$PATH:\" in *\":${brew_prefix}/bin:\"*) ;; *) eval \"\$(${brew_prefix}/bin/brew shellenv)\" ;; esac"
		append_env_block "Homebrew shellenv" "$line"
	else
		warn "brew not found — continuing without Homebrew."
	fi
}

# ────────────────── Step 3: Build Neovim from source ──────────────────

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
		# silently abort the whole script.
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

	info "Compiling Neovim (RelWithDebInfo)..."
	# BUILD.md: "Do not add a -j flag if ninja is installed!" — ninja
	# parallelizes on its own; without it, parallelize make manually.
	if have_native_cmd ninja; then
		make CMAKE_BUILD_TYPE=RelWithDebInfo 2>&1 | tee /tmp/nvim-build.log || {
			fail "Neovim build failed. Check /tmp/nvim-build.log"
		}
	else
		make CMAKE_BUILD_TYPE=RelWithDebInfo -j"$JOBS" 2>&1 | tee /tmp/nvim-build.log || {
			fail "Neovim build failed. Check /tmp/nvim-build.log"
		}
	fi

	info "Installing Neovim..."
	sudo_cmd make install 2>&1 | tee /tmp/nvim-install.log || {
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

# ────────────────── Step 4: Clone monkey-nvim ──────────────────

clone_monkey_nvim() {
	if [ -d "$INSTALL_DIR/.git" ]; then
		info "monkey-nvim already exists at $INSTALL_DIR — pulling latest..."
		git -C "$INSTALL_DIR" pull --ff-only || warn "git pull failed — keeping existing version."
	else
		info "Cloning monkey-nvim to $INSTALL_DIR..."
		git clone https://github.com/QMonkey/monkey-nvim.git "$INSTALL_DIR"
	fi
	ok "monkey-nvim ready at $INSTALL_DIR."
}

# ────────────────── Step 5: Run checkhealth.sh --install ──────────────────

run_checkhealth() {
	info "Running checkhealth.sh --install to install dependencies..."
	bash "$INSTALL_DIR/checkhealth.sh" --install || {
		warn "Some dependencies could not be installed automatically."
		warn "Run 'cd $INSTALL_DIR && ./checkhealth.sh' to review remaining items."
	}
	ok "Dependency check complete."
}

# ────────────────── Step 6: Persist PATH (go/bin, cargo/bin) ──────────────────

persist_path() {
	# go install drops binaries in $(go env GOPATH)/bin (default ~/go/bin);
	# rustup installs cargo & rust-analyzer to ~/.cargo/bin; built nvim lives
	# in /usr/local/bin. None is guaranteed to be on PATH, so persist exports
	# for the detected shell (zsh→.zprofile, bash→.profile/.bash_profile).
	local block='case ":$PATH:" in *":/usr/local/bin:"*) ;; *) export PATH="/usr/local/bin:$PATH" ;; esac
case ":$PATH:" in *":$HOME/go/bin:"*) ;; *) export PATH="$HOME/go/bin:$PATH" ;; esac
case ":$PATH:" in *":$HOME/.cargo/bin:"*) ;; *) export PATH="$HOME/.cargo/bin:$PATH" ;; esac'
	append_env_block "monkey PATH" "$block"
	ok "PATH persistence added for /usr/local/bin, go/bin and cargo/bin."
}

# ────────────────── Step 7: Set up symlinks & runtime dirs ──────────────────

setup_symlinks() {
	info "Setting up configuration symlinks..."
	ln -sf "$INSTALL_DIR" "$HOME/.config/nvim"
	ok ".config/nvim → $INSTALL_DIR"

	mkdir -p "$HOME/.local/state/nvim/swap"
	ok "created $HOME/.local/state/nvim/swap"

	# Same dir init.lua writes project sessions to (stdpath('data')/sessions,
	# also mkdir -p'd on first save — creating it here just pre-seeds it).
	mkdir -p "$HOME/.local/share/nvim/sessions"
	ok "created $HOME/.local/share/nvim/sessions"

	if [ -d "$INSTALL_DIR/configs/efm-langserver" ]; then
		if [ -e "$HOME/.config/efm-langserver" ] || [ -L "$HOME/.config/efm-langserver" ]; then
			info "efm-langserver config already exists — skipping."
		else
			mkdir -p "$HOME/.config"
			ln -sf "$INSTALL_DIR/configs/efm-langserver" "$HOME/.config/efm-langserver"
			ok "efm-langserver config → $HOME/.config/efm-langserver"
		fi
	fi
}

# ────────────────── Step 8: Bootstrap plugins via vim.pack ──────────────────

install_plugins() {
	# First headless launch: init.lua runs and zpack (vim.pack) clones every
	# plugin — no output during the clones, spell out that the wait is
	# normal instead of looking like a hang.
	info "Installing plugins (vim.pack) — no output below until done, may take a few minutes..."
	nvim --headless "+quit" 2>/dev/null || {
		warn "Headless plugin bootstrap failed. Plugins will be installed on first launch."
	}
	ok "Plugins installed."
}

# ────────────────── Main ──────────────────

main() {
	echo ""
	echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
	echo -e "${BOLD}║       monkey-nvim installer              ║${NC}"
	echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}"
	echo ""

	info "Detected OS: ${CYAN}${OS}${NC}"
	info "monkey-nvim: ${CYAN}${INSTALL_DIR}${NC}"
	info "neovim source: ${CYAN}${NVIM_SRC_DIR}${NC} (kept for future updates)"
	echo ""

	setup_sudo

	install_build_deps
	echo ""

	install_linuxbrew
	echo ""

	build_neovim
	echo ""

	clone_monkey_nvim
	echo ""

	run_checkhealth
	echo ""

	refresh_path

	persist_path
	echo ""

	setup_symlinks
	echo ""

	install_plugins
	echo ""

	echo -e "${GREEN}${BOLD}monkey-nvim installation complete!${NC}"
	echo ""
	echo -e "  Config:   ${CYAN}$INSTALL_DIR${NC} → ${CYAN}~/.config/nvim${NC}"
	echo -e "  Plugins:  managed by vim.pack (see init.lua)"
	echo ""
	echo -e "  Run ${CYAN}nvim${NC} to start."
	echo -e "  Update nvim: ${CYAN}cd $NVIM_SRC_DIR && git pull && make CMAKE_BUILD_TYPE=RelWithDebInfo && sudo make install${NC}"
	echo -e "  Update monkey-nvim: ${CYAN}cd $INSTALL_DIR && git pull${NC}"
	echo ""
	# PATH exports were written to shell rc files, but they only apply to
	# shells started AFTER this point. A child process can never change the
	# parent shell's environment, so spell out how to pick it up now.
	local env_file
	env_file="$(shell_env_files | head -1)"
	echo -e "  ${YELLOW}New PATH takes effect in NEW shells. To use it in this terminal now:${NC}"
	echo -e "    ${CYAN}source ${env_file}${NC}    ${YELLOW}# or simply: ${CYAN}exec \$SHELL${NC}"
	echo ""
}

main "$@"
