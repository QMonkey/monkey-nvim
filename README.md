# monkey-nvim

Read this in other languages: [简体中文](README.zh-CN.md)

## Introduction

The project monkey-nvim, aims to make a powerful and fast terminal-native IDE, built on Neovim.

**Positioning:** monkey-nvim targets pure terminal environments. Use it in:

| Environment    | Description                                                                                      |
| -------------- | ------------------------------------------------------------------------------------------------ |
| Linux Terminal | xterm, kitty, alacritty, wezterm, gnome-terminal, etc.                                           |
| macOS Terminal | Terminal.app, iTerm2, kitty, etc.                                                                |
| WSL            | Windows Subsystem for Linux (WSL2 recommended)                                                   |
| Server TTY     | Bare Linux console (tty1–tty63), built-in unokai 8/16-color fallback (sonokai needs ≥256 colors) |
| kmscon         | Kernel Mode Setting console — modern TTY replacement with true color and Unicode support         |

Window/split management is delegated to tmux or your terminal emulator's native tabs.

## Screenshot

![neovim](pictures/neovim.png "neovim")

## Requirements

- Neovim 0.12+

## Installation

### 1. Git clone

```bash
git clone https://github.com/QMonkey/monkey-nvim.git
```

### 2. Install dependencies

#### 2.1 Common tools

| Tool                                                          | Purpose                                                                                     | Required                |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------------------- | ----------------------- |
| git                                                           | Plugin management via `vim.pack`                                                            | Yes                     |
| [ripgrep (rg)](https://github.com/BurntSushi/ripgrep)         | fzf-lua live grep backend                                                                   | Yes                     |
| [fzf](https://github.com/junegunn/fzf)                        | fzf-lua fuzzy finder backend                                                                | Yes                     |
| universal-ctags                                               | gutentags tag generation                                                                    | Yes                     |
| [GNU Global](https://www.gnu.org/software/global/) (`global`) | gutentags gtags (GTAGS) generation & navigation                                             | Recommended             |
| [Pygments](https://pygments.org/)                             | gtags parser for non-C/C++ languages                                                        | Recommended             |
| C compiler (gcc/clang)                                        | Build tree-sitter parser native modules                                                     | Yes (compile-time only) |
| [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter) | Build tree-sitter parser modules                                                            | Yes (compile-time only) |
| [Homebrew](https://brew.sh/)                                  | Fallback package manager for tools not in system repos (lua-language-server, marksman, fzf) | Required                |

```bash
# Install Homebrew (all Linux distros — required for tools not in system repos)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Ubuntu/Debian
sudo apt-get install git ripgrep fzf universal-ctags global python3-pygments gcc nodejs npm
# tree-sitter-cli is installed via npm:
npm install -g tree-sitter-cli
brew install fzf

# OpenSUSE
sudo zypper install git ripgrep fzf universal-ctags global python3-Pygments gcc nodejs npm
# tree-sitter-cli is installed via npm:
npm install -g tree-sitter-cli

# CentOS (enable EPEL for ripgrep/fzf/universal-ctags)
sudo dnf install epel-release
sudo dnf install git ripgrep fzf universal-ctags global global-ctags python3-pygments gcc nodejs npm
# tree-sitter-cli is installed via npm:
npm install -g tree-sitter-cli

# Arch Linux
sudo pacman -S git ripgrep fzf ctags global python-pygments gcc nodejs npm
# tree-sitter-cli is installed via npm:
npm install -g tree-sitter-cli

# macOS
brew install git ripgrep fzf universal-ctags global pygments gcc node
# tree-sitter-cli is installed via npm:
npm install -g tree-sitter-cli
```

#### 2.2 LSP servers

monkey-nvim uses Neovim's built-in LSP client with `vim.lsp.config`. Install the servers for languages you use:

| Language   | LSP Server                  | Install                                                                                                                                          |
| ---------- | --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| C/C++      | clangd                      | `sudo apt-get install clangd`, `sudo zypper install clang`, `sudo dnf install clang-tools-extra`, `sudo pacman -S clang`, or `brew install llvm` |
| Go         | gopls                       | `go install golang.org/x/tools/gopls@latest`                                                                                                     |
| Python     | python-lsp-server           | `pip3 install python-lsp-server`                                                                                                                 |
| Zig        | zls                         | `brew install zls` (recommended, keeps zig/zls matched) or download from <https://zigtools.org/zls/install/>                                     |
| Rust       | rust-analyzer               | `rustup component add rust-analyzer`                                                                                                             |
| Lua        | lua-language-server         | `brew install lua-language-server` or `sudo pacman -S lua-language-server`                                                                       |
| Shell      | bash-language-server        | `npm install -g bash-language-server`                                                                                                            |
| Vim        | vim-language-server         | `npm install -g vim-language-server`                                                                                                             |
| JavaScript | typescript-language-server  | `npm install -g typescript-language-server typescript`                                                                                           |
| TypeScript | typescript-language-server  | `npm install -g typescript-language-server typescript`                                                                                           |
| JSON       | vscode-json-language-server | `npm install -g vscode-langservers-extracted`                                                                                                    |
| YAML       | yaml-language-server        | `npm install -g yaml-language-server`                                                                                                            |
| Markdown   | marksman                    | `brew install marksman` or `sudo pacman -S marksman`                                                                                             |
| Markdown   | efm-langserver              | `go install github.com/mattn/efm-langserver@latest`                                                                                              |

Some LSP servers offload formatting/linting to **external tools** that must be installed separately. Without them the feature silently degrades (falls back to built-in diagnostics or skips the tool):

| Language | Tool              | Role                                   | Install                                                                                                                                              |
| -------- | ----------------- | -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| C/C++    | clang-tidy        | linter (via `clangd --clang-tidy`)     | `sudo apt-get install clang-tidy`, `sudo zypper install clang`, `sudo dnf install clang-tools-extra`, `sudo pacman -S clang`, or `brew install llvm` |
| Go       | staticcheck       | linter (via `gopls` `staticcheck`)     | `go install honnef.co/go/tools/cmd/staticcheck@latest`                                                                                               |
| Shell    | shfmt             | formatter (via `bash-language-server`) | `go install mvdan.cc/sh/v3/cmd/shfmt@latest`                                                                                                         |
| Python   | black             | formatter (via `pylsp` black plugin)   | `pip3 install black`                                                                                                                                 |
| Markdown | prettier          | formatter (via `efm-langserver`)       | `npm install -g prettier`                                                                                                                            |
| Markdown | markdownlint-cli2 | linter (via `efm-langserver`)          | `npm install -g markdownlint-cli2`                                                                                                                   |

#### 2.3 C/C++

```bash
# Ubuntu/Debian
sudo apt-get install gcc g++ clangd clang-tidy

# OpenSUSE
sudo zypper install gcc gcc-c++ clang

# CentOS
sudo dnf install gcc gcc-c++ clang clang-tools-extra

# Arch Linux
sudo pacman -S gcc clang

# macOS
brew install gcc llvm
```

#### 2.4 Go

```bash
# Install the latest version of Go, then:
go install golang.org/x/tools/gopls@latest
# Optional: staticcheck linter (used by gopls)
go install honnef.co/go/tools/cmd/staticcheck@latest
```

#### 2.5 Python

```bash
# Python 3 is required (install via system package manager if not present)
pip3 install python-lsp-server
# Optional: formatters/linters (black is used by the pylsp black plugin)
pip3 install black autopep8 flake8 pylint
```

#### 2.6 JavaScript / TypeScript

```bash
npm install -g typescript-language-server typescript
```

#### 2.7 Zig

Zig syntax highlighting, indentation, and filetype detection are built into Neovim via nvim-treesitter — no plugin needed. Install Zig and the ZLS language server:

```bash
# Recommended: Homebrew keeps zig and zls versions in sync
brew install zig zls          # macOS / Linuxbrew

# Or download matched prebuilt binaries:
#   zig: https://ziglang.org/download/
#   zls: https://zigtools.org/zls/install/
```

> **Important:** zls is tied to a specific Zig version and refuses to start on a mismatch. Install `zig` and `zls` from the same source (Homebrew or the official download tool) so they stay in sync. Distro packages often lag: Ubuntu/Debian stable ship no `zig`, and Arch's `zls` trails Arch's `zig`, so they usually mismatch.

Format-on-save uses ZLS (matches `zig fmt`); no separate formatter is needed. Build-on-save diagnostics (`enable_build_on_save`) can be enabled in a `zls.json` next to `build.zig`.

#### 2.8 Rust

```bash
# Install rustup (includes rustc & cargo), then:
rustup component add rust-analyzer
```

#### 2.9 YAML

```bash
npm install -g yaml-language-server
```

#### 2.10 Shell

```bash
# Install LSP server, then the shfmt formatter it depends on
npm install -g bash-language-server
go install mvdan.cc/sh/v3/cmd/shfmt@latest
```

#### 2.11 Markdown

Preview Markdown in terminal via glow:

```bash
# Option 1: glow (terminal Markdown renderer)
# https://github.com/charmbracelet/glow
brew install glow       # macOS / Linuxbrew
sudo pacman -S glow     # Arch Linux
sudo apt-get install glow  # Debian 13+
go install github.com/charmbracelet/glow@latest  # Ubuntu / OpenSUSE / CentOS, or any platform with Go
```

Format & lint are provided by [efm-langserver](https://github.com/mattn/efm-langserver) (formatter: prettier, linter: markdownlint-cli2):

```bash
go install github.com/mattn/efm-langserver@latest
npm install -g prettier markdownlint-cli2
# Link the efm config (config.yaml + .markdownlint.jsonc) to efm's default path
ln -sfn $(pwd)/configs/efm-langserver ~/.config/efm-langserver
```

#### 2.12 Fonts (optional)

Neovim uses common Unicode characters (⎇, │, ▸, ·, ¬) and works without extra fonts. A [Nerd Font](https://github.com/ryanoasis/nerd-fonts) is optional if you prefer the Powerline-style look.

### 3. Health check

Verify that all required dependencies and optional LSP servers are available:

```bash
./checkhealth.sh
```

Pass `--install` to automatically install missing dependencies (required tools + optional LSP servers). Supports apt/zypper/dnf/pacman/brew, npm, pip, go install, and rustup:

```bash
./checkhealth.sh --install
```

You can also run Neovim's built-in health check for plugin-related diagnostics:

```bash
nvim --headless -c 'checkhealth' -c 'qa'
```

### 4. Install monkey-nvim

- Linux, macOS, WSL

```bash
cd monkey-nvim
ln -sf $(pwd) ~/.config/nvim
ln -sf $(pwd)/configs/.clang-format ~/.clang-format   # global clang-format style (optional)
ln -sfn $(pwd)/configs/efm-langserver ~/.config/efm-langserver   # efm: markdown format/lint (optional)
nvim --headless -c 'ZPack sync' -c 'qa'   # Install all plugins
nvim
```

### 5. Update project

```bash
cd monkey-nvim
git pull
```

Then in Neovim:

```vim
:ZPack update
```

### 6. kmscon setup (optional)

[kmscon](https://github.com/kmscon/kmscon) is a Linux KMS/DRM-based system console that replaces the legacy tty with full Unicode support, multi-seat capability, and true color rendering. It is an excellent companion for monkey-nvim on headless servers.

#### 6.1 Install kmscon

```bash
# Ubuntu/Debian (older versions without terminfo)
sudo apt-get install kmscon

# OpenSUSE (Tumbleweed / Leap 15.x)
sudo zypper install kmscon

# Arch Linux
sudo pacman -S kmscon

# CentOS — not in official/EPEL repos, build from source below instead
# Build from source (requires meson, ninja, and ncurses for tic)
git clone https://github.com/kmscon/kmscon.git
cd kmscon
meson setup builddir/
meson install -C builddir/
```

Building from source automatically compiles and installs the kmscon terminfo entry via `tic`, so nvim can detect terminal capabilities correctly without any `TERM` workaround. The default prefix is `/usr/local`; append `--prefix=/usr` to the meson setup command to install system-wide.

On older systems, dependencies like `libtsm` may be too old to satisfy the build requirements. In that case, use the package manager version and apply the `TERM` workaround in section 6.3.

#### 6.2 Replace tty with kmscon (permanent)

To make kmscon the default system console instead of the legacy tty/getty, replace agetty with kmscon on the desired tty:

```bash
# Stop the existing getty on tty1
sudo systemctl stop getty@tty1.service
sudo systemctl disable getty@tty1.service

# Create a kmscon service for tty1
sudo mkdir -p /etc/systemd/system/getty.target.wants
sudo ln -s /usr/lib/systemd/system/kmsconvt@.service \
    /etc/systemd/system/getty.target.wants/kmsconvt@tty1.service

# Override ExecStart to use kmscon's own terminal type
sudo systemctl edit kmsconvt@tty1.service
```

Add the following override:

```ini
[Service]
ExecStart=
ExecStart=/usr/bin/kmscon "--vt=%I" --seats=seat0 --no-switchvt --login -- /sbin/agetty -o '-p -- \\u' - kmscon
```

The last argument `kmscon` is agetty's `<termtype>` positional argument and sets `TERM=kmscon`, which matches the terminfo entry installed during build.

The terminal type differs by kmscon version, because the `kmscon` terminfo entry is only shipped since **10.0.0**:

```ini
# kmscon 10.0.0+ (ships scripts/terminfo/kmscon.ti, default TERM=kmscon)
ExecStart=/usr/bin/kmscon "--vt=%I" --seats=seat0 --no-switchvt --login -- /sbin/agetty -o '-p -- \\u' - kmscon

# kmscon 9.x (no kmscon terminfo entry; use xterm-256color)
ExecStart=/usr/bin/kmscon "--vt=%I" --seats=seat0 --no-switchvt --login -- /sbin/agetty -o '-p -- \\u' - xterm-256color
```

If your `agetty` build supports the `--noclear` flag, you may insert it before the `-` to keep the kmscon splash on the login prompt; it is purely cosmetic.

```bash
# Start kmscon on tty1
sudo systemctl start kmsconvt@tty1.service
```

After reboot, press `Ctrl+Alt+F1` to switch to the kmscon-enhanced tty1. You can repeat this for tty2–tty6 as needed.

##### `start` vs `enable` — a common pitfall

`systemctl start` runs a unit once and ignores the `[Install]` section entirely, so it never touches `autovt@.service`. `systemctl enable` reads `[Install]` and creates symlinks, including the `Alias=autovt@.service`.

tty2–tty6 are **not** started from `getty.target.wants`; systemd-logind spawns each newly-activated VT as `autovt@ttyN.service`, which resolves through the `autovt@.service` alias. That alias ships in Debian/Ubuntu's `kmsconvt@.service`:

```ini
[Install]
WantedBy=getty.target
DefaultInstance=tty1
Alias=autovt@.service
```

So:

- `systemctl enable kmsconvt@tty1.service` → only tty1 (instance alias `autovt@tty1.service`).
- `systemctl enable kmsconvt@.service` (template, no ttyN) → **every VT**, because it creates `/etc/systemd/system/autovt@.service -> kmsconvt@.service`.

The `ln -s ... kmsconvt@tty1.service` + `start` flow above therefore affects only tty1. If tty2–tty6 unexpectedly become kmscon, check for a leftover alias (see 6.5 to revert).

#### 6.3 True color support

kmscon supports true color (24-bit). monkey-nvim detects this automatically via `has('termguicolors')` and renders GUI colors directly.

If kmscon was installed via package manager (older versions without terminfo) or the terminfo entry is missing, nvim may fail with `E558: Terminal entry not found in terminfo`. In that case, add the following to your shell profile:

```bash
# Add to your shell profile (~/.bashrc, ~/.zshrc, etc.)
export TERM=xterm-256color
export COLORTERM=truecolor
```

The `COLORTERM=truecolor` is required so nvim still detects true color support when `TERM` is set to `xterm-256color`. Note that using `xterm-256color` instead of kmscon's native terminfo may cause minor display artifacts in nvim due to terminal capability mismatches. For the best experience, build from source (10.0.0+) to get the native terminfo entry.

If you run tmux inside kmscon, tmux overrides `$TERM` with `tmux` / `tmux-256color`. This is expected and correct — do **not** change it back. tmux derives its internal `TERM` from the outer terminal and exposes its own accurate capabilities, so nvim and other ncurses programs work correctly. Only the **outer** `$TERM` (before entering tmux) matters: keep it as `kmscon` on 10.0.0+ or `xterm-256color` on 9.x.

The Linux framebuffer console (tty1–tty63, `TERM=linux`) only exposes 8/16 colors (`&t_Co < 256`), which triggers sonokai's guard (`&t_Co < 256 -> finish`) and leaves Neovim's built-in 8/16-color highlighting, so code stays readable. sonokai itself does not require true color — it renders fine with the `cterm` palette on any 256-color terminal — but it does refuse to load when fewer than 256 colors are available. monkey-nvim therefore falls back to the built-in `unokai` theme on a bare tty. For the full sonokai scheme on a physical console, replace tty with kmscon (section 6.2) or use any 256-color/true-color terminal.

If you run tmux on a bare tty (not kmscon), tmux defaults to `default-terminal=tmux-256color`, which advertises 256 colors and xterm-style key sequences to every program inside it — even though the underlying console only has 8/16 colors. monkey-nvim already detects this (it walks the process tree to see the real tty behind the tmux client) and falls back to the built-in highlighting, so nvim itself stays correct regardless. Other programs, however, do not get that protection and may render 256-color escapes the console cannot show. To keep them correct, set tmux's terminal type to match the 8-color console:

```bash
# In ~/.tmux.conf — only for tmux running on a bare Linux tty
set -g default-terminal "tmux"
set -g terminal-overrides ",linux:colors=16"
```

The first line makes tmux advertise a plain 8-color terminal to programs; the second tells tmux the underlying `linux` console has 16 colors (8 base + 8 bright) so it can downconvert sensibly. Do **not** add these lines when tmux runs under kmscon or a normal terminal emulator — there `tmux-256color` is correct.

#### 6.4 Fonts (optional)

kmscon uses the system's built-in font renderer. If you prefer Powerline-style icons, install a system monospace font of your choice.

#### 6.5 Revert to the legacy tty/getty

To hand the virtual consoles back to agetty:

```bash
# Stop the kmscon instance
sudo systemctl stop kmsconvt@tty1.service

# Remove the tty1 wants link created in section 6.2
sudo rm -f /etc/systemd/system/getty.target.wants/kmsconvt@tty1.service

# Restore getty on tty1
sudo systemctl enable getty@tty1.service
sudo systemctl start getty@tty1.service
```

If you previously ran `systemctl enable kmsconvt@.service` (the template), the `autovt@.service` alias now points at kmscon and keeps replacing every VT. Revert it explicitly:

```bash
# Point autovt@.service back at getty (drop the kmscon alias)
sudo systemctl disable kmsconvt@.service
sudo rm -f /etc/systemd/system/autovt@.service

# Re-enable getty (also restores getty@tty1.service)
sudo systemctl enable getty@.service

# Reload so logind picks up the change for newly-activated VTs
sudo systemctl daemon-reload
```

Verify the alias points at getty again:

```bash
readlink -f /etc/systemd/system/autovt@.service /usr/lib/systemd/system/autovt@.service
```

It should resolve to `getty@.service`.

## Plugin list

| Plugin                                                                                  | Purpose                                                   |
| --------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| [zuqini/zpack.nvim](https://github.com/zuqini/zpack.nvim)                               | Lazy-loading plugin manager on top of built-in `vim.pack` |
| [sainnhe/sonokai](https://github.com/sainnhe/sonokai)                                   | Colorscheme                                               |
| [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)               | Status line                                               |
| [echasnovski/mini.indentscope](https://github.com/echasnovski/mini.indentscope)         | Indent guide                                              |
| [echasnovski/mini.ai](https://github.com/echasnovski/mini.ai)                           | Text objects                                              |
| [echasnovski/mini.surround](https://github.com/echasnovski/mini.surround)               | Surround text with parens/quotes/etc                      |
| [numToStr/Comment.nvim](https://github.com/numToStr/Comment.nvim)                       | Comment toggling                                          |
| [andymass/vim-matchup](https://github.com/andymass/vim-matchup)                         | Extended % matching                                       |
| [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs)                       | Auto-close brackets/parens                                |
| [gbprod/substitute.nvim](https://github.com/gbprod/substitute.nvim)                     | Substitute with clipboard                                 |
| [chentoast/marks.nvim](https://github.com/chentoast/marks.nvim)                         | Visual marks                                              |
| [ibhagwan/fzf-lua](https://github.com/ibhagwan/fzf-lua)                                 | Fuzzy file/buffer/tag finder                              |
| [folke/flash.nvim](https://github.com/folke/flash.nvim)                                 | Easy motion                                               |
| [kevinhwang91/nvim-ufo](https://github.com/kevinhwang91/nvim-ufo)                       | Folding                                                   |
| [kevinhwang91/promise-async](https://github.com/kevinhwang91/promise-async)             | Async library (ufo dependency)                            |
| [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)   | Syntax highlighting & parsing                             |
| [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp)                                 | Completion engine                                         |
| [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)                         | LSP completion source                                     |
| [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer)                             | Buffer word completion source                             |
| [hrsh7th/cmp-path](https://github.com/hrsh7th/cmp-path)                                 | Path completion source                                    |
| [hrsh7th/cmp-cmdline](https://github.com/hrsh7th/cmp-cmdline)                           | Cmdline completion                                        |
| [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip)                 | Luasnip completion source                                 |
| [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip)                                 | Snippet engine                                            |
| [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets)         | Snippet collection                                        |
| [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)                   | Git diff in sign column                                   |
| [NeogitOrg/neogit](https://github.com/NeogitOrg/neogit)                                 | Git wrapper                                               |
| [esmuellert/codediff.nvim](https://github.com/esmuellert/codediff.nvim)                 | Side-by-side diff                                         |
| [rmagatti/auto-session](https://github.com/rmagatti/auto-session)                       | Session management                                        |
| [stevearc/oil.nvim](https://github.com/stevearc/oil.nvim)                               | File explorer (replaces netrw)                            |
| [ludovicchabant/vim-gutentags](https://github.com/ludovicchabant/vim-gutentags)         | Automatic ctags generation                                |
| [dhananjaylatkar/cscope_maps.nvim](https://github.com/dhananjaylatkar/cscope_maps.nvim) | Cscope integration                                        |
| [folke/trouble.nvim](https://github.com/folke/trouble.nvim)                             | Diagnostics/quickfix list                                 |
| [jake-stewart/multicursor.nvim](https://github.com/jake-stewart/multicursor.nvim)       | Multiple cursors                                          |
| [akinsho/toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)                   | Terminal toggling                                         |

## Keyboard shortcut

```text
The "Leader" key below means comma key.
```

### 1. Normal mode

#### 1.1 Remap

```text
s       Replace a motion/text object with clipboard content (see §1.7)
S       Replace from cursor to end of line with clipboard content (see §1.7)
Y       Copy from the cursor position to the end of the line, same as y$
H       To the first non-blank character of the line, same as ^
L       To the last character of the line, same as $
U       Redo, same as Ctrl-r
;       Enter command line mode, same as :
q       Quit current window (with special handling for diff/git/quickfix)
Shift+q  Quit vim, same as :qa
t       Recording, same as the original q (normal and visual mode)

j       Move down one display line (gj), works on wrapped lines
k       Move up one display line (gk), works on wrapped lines
f       Search 1 char to jump with hints (flash.nvim)
F       Search char with hint positioned at end of match (flash.nvim)
```

The following remaps work in both Insert mode and Command-line mode:

```text
Ctrl+p  Move up        (Up)
Ctrl+n  Move down      (Down)
Ctrl+b  Move left      (Left)
Ctrl+f  Move right     (Right)
Ctrl+a  Jump to start  (Home)
Ctrl+e  Jump to end    (End)
Ctrl+h  Backspace      (BackSpace)
Ctrl+d  Delete forward (Del)
```

#### 1.2 F1 ~ F4

```text
F1      Open fzf-lua live grep
F2      Toggle fzf-lua resume/close
F3      Run a one-off command in terminal
F4      Toggle terminal buffer (open/hide)
```

#### 1.3 Buffer

```text
Leader+o    Open a new buffer with given file path in current window
[+b         Jump to previous buffer
]+b         Jump to next buffer
```

#### 1.4 Split

```text
Leader+Leader+s    Open a horizontal split with given file path in current window
Leader+Leader+v    Open a vertical split with given file path in current window

Ctrl+h      Jump to the left split
Ctrl+j      Jump to the below split
Ctrl+k      Jump to the above split
Ctrl+l      Jump to the right split
Leader+z    Toggle zoom
```

#### 1.5 Tab

```text
Leader+Leader+t  Open a tab with given file path in current window

[+t         Jump to previous tab
]+t         Jump to next tab
Leader+1~9  Jump to the 1~9 tab
Leader+[    Jump to first tab
Leader+]    Jump to last tab
```

#### 1.6 Replace (substitute.nvim)

```text
s{textobj}  Replace a text object with clipboard content (e.g. siw to replace current word)
ss          Replace entire current line with clipboard content
S           Replace from cursor to end of line with clipboard content
```

#### 1.7 LSP (Language Server Protocol)

```text
K (gh)              Hover documentation for symbol under cursor (LSP filetypes)
K                   `:Man` for other filetypes, `:help` in Vim/help files

gd                  Go to definition (falls back to tag jump when no LSP)
gc                  Go to declaration
gt                  Go to type definition
gi                  Go to implementation (results in trouble)
gr                  Show references (results in trouble)

Leader+rn           Rename symbol
[d                  Previous diagnostic
]d                  Next diagnostic
[D                  First diagnostic
]D                  Last diagnostic
Leader+d            Toggle diagnostics (trouble)
```

Files are auto-formatted on save via LSP. Completion is enabled by default — LSP-powered suggestions appear automatically as you type.

#### 1.8 File/Buffer/Tag navigation (fzf-lua)

```text
Ctrl+p      Search files

Leader+b    Search buffers
Leader+t    Search buffer tags
Leader+p    Search project tags
Leader+f    Search function in buffer
Leader+e    Search line in buffer
Leader+a    Search current word in current directory
```

#### 1.9 Fold (nvim-ufo)

```text
za      When on a closed fold, open it. When on an open fold, close it and set 'foldenable'
zc      Close one fold under the cursor
zo      Open one fold under the cursor
zR      Open all folds
zM      Close all folds
```

#### 1.10 Marks (marks.nvim)

```text
m[a-zA-Z]   Toggle mark
m,          Place the next available mark
m.          If no mark on line, place the next available mark. Otherwise, remove (first) existing mark

dm[a-zA-Z]  Delete mark[a-zA-Z]
m-          Delete all marks in current line
m<Space>    Delete all marks in current buffer

'[a-zA-Z]   Jump to the mark
]` / [`     Jump to next / previous mark
`] / `[     Jump by alphabetical order to next / previous mark
m/          View all marks in Location List
```

`:SignatureToggle` Show/hide marks without deleting them
`:SignatureRefresh` Re-sync marks and signs if they go out of sync

#### 1.11 Oil (File explorer, replaces netrw)

```text
-           Open file directory in current window
~           Open project root or home directory in current window

<CR>        Enter directory or open file
-           Go up one directory
```

#### 1.12 Terminal

```text
F3      Open a terminal with one-off command
F4      Toggle terminal buffer (open/hide)
```

Use `<Ctrl-\><Ctrl-n>` to switch from terminal mode to normal mode. In normal mode, `<ScrollWheelUp>` and `<ScrollWheelDown>` scroll the terminal buffer.

#### 1.13 Surround (mini.surround)

```text
ys+textobj+surroundA        Add surround A for the region of textobj
yss+surroundA               Add surround A for current line
ds+surroundA                Delete surround A
cs+surroundA+surroundB      Change surround A to B
```

#### 1.14 Others

```text
Leader+ws       Save session
Leader+rs       Remove session

'.              Jump to last changes
''              To the position before the latest jump
Ctrl+o          Go to [Count] older cursor position in jump list
Ctrl+i          Go to [Count] newer cursor position in jump list
cod             Toggle diff
cop             Toggle paste (auto-disabled on leaving insert mode)
col             Toggle list
con             Clear search highlight
Leader+cr       Change project root
Leader+space        Strip trailing whitespace
Leader+Leader+space  Strip trailing whitespace + \r (DOS newlines)
Leader+q            Toggle quickfix (trouble)
Leader+l            Toggle location list (trouble)
Leader+gg           Open Neogit
Leader+gl           Open Neogit log (current file)
Leader+gL           Open Neogit log (all refs)
Leader+gd           Gitsigns diff this
Leader+gD           CodeDiff
Leader+gb           Gitsigns blame line
Leader+gB           Gitsigns blame
Leader+hs           Gitsigns stage hunk
Leader+hS           Gitsigns stage buffer
Leader+hr           Gitsigns reset hunk
Leader+hR           Gitsigns reset buffer
Leader+hp           Gitsigns preview hunk inline
Leader+hP           Gitsigns preview hunk
Leader+hq           Gitsigns set quickfix
Leader+hQ           Gitsigns set quickfix all
Leader+hl           Gitsigns set loclist

Visual mode:
Leader+gl           Neogit log for selected lines

SudoWrite           Save file with sudo
```

In quickfix/location windows:

- `o`/`Enter` — Open entry (file + line)
- `q` — Close window

`gdefault` is set, so `:s` performs global substitution (all matches per line) by default. `jumpoptions+=stack` makes the jumplist behave like the tagstack.

#### 1.15 Auto-insert file headers

New `.sh` and `.py` files get a shebang line automatically inserted:

- `.sh` → `#!/usr/bin/env bash`
- `.py` → `#!/usr/bin/env python3`

### 2. Insert mode

#### 2.1 Snippets (LuaSnip)

```text
Ctrl+l      Expand snippet / confirm completion
Tab         Jump to next placeholder
Shift+Tab   Jump to previous placeholder
```

Completion keymaps:

```text
Ctrl+l      Confirm completion (when menu visible) or expand/jump snippet
Ctrl+j      Select next completion item
Ctrl+k      Select previous completion item
CR          Confirm completion (select selected item)
```

### 3. Visual mode

#### 3.1 Remap

```text
s       Replace selected text with clipboard content
;       Enter command line mode, same as :
<       Decrease indent, keep selection
>       Increase indent, keep selection
```

#### 3.2 Search

```text
Leader+a        Search selected text in current directory (fzf-lua)
```

#### 3.3 Replace

```text
s{textobj}  Replace a text object with clipboard content (e.g. siw)
ss          Replace entire current line with clipboard content
S           Replace from cursor to end of line with clipboard content
```

#### 3.4 Easy motion (flash.nvim)

```text
f       Search 1 character to jump with hints (flash.nvim)
F       Treesitter-based jump
```

#### 3.5 Surround (mini.surround)

```text
S+surroundA     Add surround A for selected text (mini.surround)
```

### 4. Command line mode

```text
Ctrl+p  Previous command
Ctrl+n  Next command
Ctrl+a  Jump to the begin of the command line
Ctrl+e  Jump to the end of the command line
```

## Useful command

### 1. SudoWrite

```vim
" Save file with root permission
:SudoWrite
```

### 2. fzf-lua

```vim
" Search files
:FzfLua files

" Search buffers
:FzfLua buffers

" Live grep
:FzfLua live_grep

" Search help tags
:FzfLua help_tags

" Resume last picker
:FzfLua resume
```

### 3. Neogit

```vim
" Open Neogit status
:Neogit

" Open Neogit log for current file
:Neogit log_current

" Open Neogit log
:Neogit log
```

### 4. Gutentags

```vim
" Generate tags for current file
:GutentagsUpdate

" Generate tags for current project
:GutentagsUpdate!
```

If GNU Global (`gtags`/`global`) and Pygments (`pygmentize`) are installed, gutentags also generates the `GTAGS`/`GRTAGS`/`GPATH` databases alongside ctags. GTAGS are auto-built on first BufEnter and incrementally updated on save.

Cscope keybindings (via cscope_maps.nvim):

```text
gs      Find symbol under cursor (Cscope find s)
gD      Jump to definition (Cstag)
gR      Find callers (Cscope find c)
g]      Jump to tag and open quickfix
```

## Use git in Neovim

### 1. git for Neovim: [Neogit](https://github.com/NeogitOrg/neogit)

```vim
" Open Neogit status
:Neogit
:Neogit log_current
:Neogit log
:Neogit pull
:Neogit push
:Neogit commit
:Neogit branch
```

### 2. Git diff gutter: [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)

```vim
" Jump to next/previous hunk
]h / [h

" Preview / stage / undo current hunk
:Gitsigns preview_hunk
:Gitsigns stage_hunk
:Gitsigns reset_hunk

" Load hunks into quickfix/loclist
:Gitsigns setqflist
:Gitsigns setloclist
```

### 3. Side-by-side diff: [codediff.nvim](https://github.com/esmuellert/codediff.nvim)

```vim
:CodeDiff
```

## Precautions

- **Indentation convention** — monkey-nvim applies indent settings per filetype:

| Filetype                                          | Style                    | Width |
| ------------------------------------------------- | ------------------------ | ----- |
| `c`, `cpp`, `go`, `sh`, `vim`, `sql`              | Hard tab (`noexpandtab`) | 4     |
| `zig`, `rust`, `python`, `markdown`               | Spaces (`expandtab`)     | 4     |
| `javascript`, `typescript`, `lua`, `yaml`, `json` | Spaces (`expandtab`)     | 2     |

The global default is 4-width hard tabs.

- Neovim clipboard integration

monkey-nvim sets `clipboard=unnamed,unnamedplus` when a display server is detected, so yank/delete automatically syncs to the system clipboard.

If you use a standalone clipboard manager (optional):

| Tool                                              | Platform  | Purpose                                                     |
| ------------------------------------------------- | --------- | ----------------------------------------------------------- |
| [parcellite](https://parcellite.sourceforge.net/) | X11       | Lightweight clipboard manager with persistent history       |
| [cliphist](https://github.com/sentriz/cliphist)   | Wayland   | Clipboard history for wlroots-based compositors             |
| Built-in                                          | macOS/WSL | System clipboard persists by default — no extra tool needed |

> Optional CLI tools: `wl-clipboard` (Wayland, provides `wl-copy`/`wl-paste`), `xclip` or `xsel` (X11). Neovim has built-in clipboard support, so these are only needed for command-line clipboard access outside Neovim.

## Extra setup

- Use Neovim to view man pages:

```bash
export MANPAGER="nvim -R +MANPAGER -"
```

## Build Neovim from source

For the latest version or features not in system packages:

```bash
git clone https://github.com/neovim/neovim.git
cd neovim
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
```
