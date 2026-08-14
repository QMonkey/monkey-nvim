# monkey-nvim

其他语言版本：[English](README.md)

## 简介

monkey-nvim项目，旨在基于 Neovim 打造一个强大、快速的纯终端原生 IDE。

**定位：** monkey-nvim 面向纯终端环境。适用环境：

| 环境 | 说明 |
|---|---|
| Linux 终端 | xterm, kitty, alacritty, wezterm, gnome-terminal 等 |
| macOS 终端 | Terminal.app, iTerm2, kitty 等 |
| WSL | Windows Subsystem for Linux（推荐 WSL2） |
| 服务器 TTY | 原生 Linux 控制台（tty1–tty63），256 色降级 |

窗口/分屏管理交给 tmux 或终端模拟器的原生标签页。

## 截图

![neovim](pictures/neovim.png "neovim")

## 要求

- Neovim 0.12+

## 安装步骤

### 1. clone到本地

```bash
git clone https://github.com/QMonkey/monkey-nvim.git
```

### 2. 安装依赖

#### 2.1 通用工具

| 工具 | 用途 | 是否必须 |
|---|---|---|
| git | 通过 `vim.pack` 管理插件 | 是 |
| [ripgrep (rg)](https://github.com/BurntSushi/ripgrep) | fzf-lua live grep 后端 | 是 |
| [fzf](https://github.com/junegunn/fzf) | fzf-lua 模糊查找后端 | 是 |
| universal-ctags | gutentags 标签生成 | 是 |
| [GNU Global](https://www.gnu.org/software/global/) (`global`) | gutentags gtags（GTAGS）生成与导航 | 推荐 |
| [Pygments](https://pygments.org/) | 非 C/C++ 语言的 gtags 解析器 | 推荐 |
| C 编译器 (gcc/clang) | 编译 tree-sitter parser 原生模块 | 是（仅编译时） |
| [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter) | 编译 tree-sitter parser 模块 | 是（仅编译时） |
| [Homebrew](https://brew.sh/) | 系统仓库缺失时的后备包管理器（lua-language-server、marksman、fzf 等） | 必须 |

```bash
# 安装 Homebrew（所有 Linux 发行版 — 用于安装系统仓库中缺失的工具）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Ubuntu/Debian
sudo apt-get install git ripgrep fzf universal-ctags global python3-pygments gcc nodejs npm
# tree-sitter-cli 通过 npm 安装：
npm install -g tree-sitter-cli
brew install fzf

# OpenSUSE
sudo zypper install git ripgrep fzf universal-ctags global python3-Pygments gcc nodejs npm
# tree-sitter-cli 通过 npm 安装：
npm install -g tree-sitter-cli

# CentOS（需先启用 EPEL 仓库以获取 ripgrep/fzf/universal-ctags）
sudo dnf install epel-release
sudo dnf install git ripgrep fzf universal-ctags global global-ctags python3-pygments gcc nodejs npm
# tree-sitter-cli 通过 npm 安装：
npm install -g tree-sitter-cli

# Arch Linux
sudo pacman -S git ripgrep fzf ctags global python-pygments gcc nodejs npm
# tree-sitter-cli 通过 npm 安装：
npm install -g tree-sitter-cli

# macOS
brew install git ripgrep fzf universal-ctags global pygments gcc node
# tree-sitter-cli 通过 npm 安装：
npm install -g tree-sitter-cli
```

#### 2.2 LSP 服务器

monkey-nvim 使用 Neovim 内建的 LSP 客户端（`vim.lsp.config`）。请根据需要安装对应语言的服务器：

| 语言 | LSP 服务器 | 安装方式 |
|---|---|---|
| C/C++ | clangd | `sudo apt-get install clangd`、`sudo zypper install clang`、`sudo dnf install clang-tools-extra`、`sudo pacman -S clang` 或 `brew install llvm` |
| Go | gopls | `go install golang.org/x/tools/gopls@latest` |
| Python | python-lsp-server | `pip3 install python-lsp-server` |
| Rust | rust-analyzer | `rustup component add rust-analyzer` |
| Lua | lua-language-server | `brew install lua-language-server` 或 `sudo pacman -S lua-language-server` |
| Shell | bash-language-server | `npm install -g bash-language-server` |
| Vim | vim-language-server | `npm install -g vim-language-server` |
| JavaScript | typescript-language-server | `npm install -g typescript-language-server typescript` |
| TypeScript | typescript-language-server | `npm install -g typescript-language-server typescript` |
| JSON | vscode-json-language-server | `npm install -g vscode-langservers-extracted` |
| YAML | yaml-language-server | `npm install -g yaml-language-server` |
| Markdown | marksman | `brew install marksman` 或 `sudo pacman -S marksman` |

部分 LSP 服务器会把格式化/检查交给**外部工具**，需单独安装。缺失时功能会静默降级（回退到内置诊断或跳过该工具）：

| 语言 | 工具 | 作用 | 安装方式 |
|---|---|---|---|
| C/C++ | clang-tidy | linter（经 `clangd --clang-tidy`） | `sudo apt-get install clang-tidy`、`sudo zypper install clang`、`sudo dnf install clang-tools-extra`、`sudo pacman -S clang` 或 `brew install llvm` |
| Go | staticcheck | linter（经 `gopls` 的 `staticcheck`） | `go install honnef.co/go/tools/cmd/staticcheck@latest` |
| Shell | shfmt | formatter（经 `bash-language-server`） | `go install mvdan.cc/sh/v3/cmd/shfmt@latest` |
| Python | black | formatter（经 `pylsp` 的 black 插件） | `pip3 install black` |

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
# 请安装最新版本的 go，然后：
go install golang.org/x/tools/gopls@latest
# 可选：staticcheck 检查器（gopls 使用）
go install honnef.co/go/tools/cmd/staticcheck@latest
```

#### 2.5 Python

```bash
# 需要 Python 3（如未安装请先通过系统包管理器安装）
pip3 install python-lsp-server
# 可选：代码格式化与检查工具（black 由 pylsp 的 black 插件使用）
pip3 install black autopep8 flake8 pylint
```

#### 2.6 JavaScript / TypeScript

```bash
npm install -g typescript-language-server typescript
```

#### 2.7 Rust

```bash
# 安装 rustup（包含 rustc 和 cargo），然后：
rustup component add rust-analyzer
```

#### 2.8 YAML

```bash
npm install -g yaml-language-server
```

#### 2.9 Shell

```bash
# 安装 LSP 服务器，以及它依赖的 shfmt 格式化工具
npm install -g bash-language-server
go install mvdan.cc/sh/v3/cmd/shfmt@latest
```

#### 2.10 Markdown

终端下预览 Markdown：

```bash
# glow（终端 Markdown 渲染器）
# https://github.com/charmbracelet/glow
brew install glow       # macOS / Linuxbrew
sudo pacman -S glow     # Arch Linux
sudo apt-get install glow  # Debian 13+
go install github.com/charmbracelet/glow@latest  # Ubuntu / OpenSUSE / CentOS，或其他已安装 Go 的平台
```

#### 2.11 字体（可选）

Neovim 使用的 Unicode 字符（⎇, │, ▸, ·, ¬）无需额外字体即可正常显示。如需 Powerline 风格外观，可选择性安装 [Nerd Font](https://github.com/ryanoasis/nerd-fonts)。

### 3. 健康检查

验证所有必需依赖和可选 LSP server 是否就绪：

```bash
./checkhealth.sh
```

加 `--install` 可自动安装缺失的依赖（必需工具 + 可选 LSP 服务器）。支持 apt/zypper/dnf/pacman/brew、npm、pip、go install 和 rustup：

```bash
./checkhealth.sh --install
```

也可运行 Neovim 内建的健康检查查看插件相关问题：

```bash
nvim --headless -c 'checkhealth' -c 'qa'
```

### 4. 安装

- Linux、macOS、WSL

```bash
cd monkey-nvim
ln -sf $(pwd) ~/.config/nvim
ln -sf $(pwd)/configs/.clang-format ~/.clang-format   # 全局 clang-format 风格（可选）
nvim --headless -c 'PackUpdate' -c 'qa'   # 安装所有插件
nvim
```

### 5. 更新

```bash
cd monkey-nvim
git pull
```

然后在 Neovim 中：

```vim
:PackUpdate
```

### 6. kmscon 安装与使用（可选）

kmscon 是基于 Linux KMS/DRM 的系统级终端，替代传统的 Linux tty，提供完整的 Unicode 支持和真彩色渲染。

#### 6.1 安装 kmscon

```bash
# Ubuntu/Debian
sudo apt-get install kmscon

# OpenSUSE（Tumbleweed / Leap 15.x）
sudo zypper install kmscon

# Arch Linux
sudo pacman -S kmscon

# CentOS 官方仓库与 EPEL 均无 kmscon 包，请使用下面的源码编译方式。

# 从源码编译（需要 meson、ninja）
git clone https://github.com/kmscon/kmscon.git
cd kmscon
meson setup builddir/
meson install -C builddir/
```

#### 6.2 真彩色支持

Neovim 通过 `termguicolors` 自动检测真彩色支持。如果在传统 Linux tty 上运行，monkey-nvim 将自动降级到 256 色模式。

## 插件列表

| 插件 | 用途 |
|---|---|
| [sainnhe/sonokai](https://github.com/sainnhe/sonokai) | 配色方案 |
| [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | 状态栏 |
| [echasnovski/mini.indentscope](https://github.com/echasnovski/mini.indentscope) | 缩进参考线 |
| [echasnovski/mini.ai](https://github.com/echasnovski/mini.ai) | 文本对象 |
| [echasnovski/mini.surround](https://github.com/echasnovski/mini.surround) | 围绕字符编辑 |
| [numToStr/Comment.nvim](https://github.com/numToStr/Comment.nvim) | 注释切换 |
| [andymass/vim-matchup](https://github.com/andymass/vim-matchup) | 扩展 % 跳转配对 |
| [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) | 自动配对括号 |
| [gbprod/substitute.nvim](https://github.com/gbprod/substitute.nvim) | 使用剪贴板替换 |
| [chentoast/marks.nvim](https://github.com/chentoast/marks.nvim) | 可视化书签 |
| [ibhagwan/fzf-lua](https://github.com/ibhagwan/fzf-lua) | 模糊文件/缓冲/tag 查找 |
| [folke/flash.nvim](https://github.com/folke/flash.nvim) | 快速跳转 |
| [kevinhwang91/nvim-ufo](https://github.com/kevinhwang91/nvim-ufo) | 折叠 |
| [kevinhwang91/promise-async](https://github.com/kevinhwang91/promise-async) | 异步库（ufo 依赖） |
| [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | 语法高亮与解析 |
| [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | 补全引擎 |
| [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) | LSP 补全源 |
| [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer) | 缓冲区补全源 |
| [hrsh7th/cmp-path](https://github.com/hrsh7th/cmp-path) | 路径补全源 |
| [hrsh7th/cmp-cmdline](https://github.com/hrsh7th/cmp-cmdline) | 命令行补全 |
| [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip) | Luasnip 补全源 |
| [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip) | 代码片段引擎 |
| [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets) | 常用代码片段集合 |
| [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git 差异标记 |
| [NeogitOrg/neogit](https://github.com/NeogitOrg/neogit) | Git 集成 |
| [esmuellert/codediff.nvim](https://github.com/esmuellert/codediff.nvim) | 并排差异对比 |
| [rmagatti/auto-session](https://github.com/rmagatti/auto-session) | Session 管理 |
| [stevearc/oil.nvim](https://github.com/stevearc/oil.nvim) | 文件管理器（替代 netrw） |
| [ludovicchabant/vim-gutentags](https://github.com/ludovicchabant/vim-gutentags) | 自动生成 ctags |
| [dhananjaylatkar/cscope_maps.nvim](https://github.com/dhananjaylatkar/cscope_maps.nvim) | Cscope 集成 |
| [folke/trouble.nvim](https://github.com/folke/trouble.nvim) | 诊断/quickfix 列表 |
| [jake-stewart/multicursor.nvim](https://github.com/jake-stewart/multicursor.nvim) | 多光标编辑 |
| [akinsho/toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | 终端切换 |

## 快捷键

```
以下所有"Leader"键，都代表","键
```

### 1. 正常模式

#### 1.1 按键修改

```
s       用剪贴板的内容替换文本对象选中的字符串（详见§1.6）
S       用剪贴板的内容替换当前光标到行尾的文本（详见§1.6）
Y       复制到行尾，相当于"y$"命令
H       跳到当前行第一个非空字符,相当于"^"命令
L       跳到当前行最后一个字符,相当于"$"命令
U       Redo，相当于"Ctrl-r"
;       进入命令行模式，相当于":"键
q       退出窗口（含 diff/git/quickfix 特殊处理）
Shift+q  退出vim，相当于命令":qa"
t       记录操作，相当于原来的q（普通模式和可视化模式）

j       移至下一显示行（gj），在折行中正常移动
k       移至上一显示行（gk），在折行中正常移动
f       搜索 1 个字符跳转（flash.nvim 带提示）
F       搜索字符并聚焦到匹配末尾（flash.nvim）
```

以下按键在插入模式和命令行模式下均适用：

```
Ctrl+p  上移        (Up)
Ctrl+n  下移        (Down)
Ctrl+b  左移        (Left)
Ctrl+f  右移        (Right)
Ctrl+a  跳到行首    (Home)
Ctrl+e  跳到行尾    (End)
Ctrl+h  退格        (BackSpace)
Ctrl+d  向前删除    (Del)
```

#### 1.2 F1 ~ F4

```
F1      打开 fzf-lua live grep
F2      切换 fzf-lua 恢复/关闭
F3      在终端中运行一次性命令
F4      切换终端窗口（打开/隐藏）
```

使用 `<Ctrl-\><Ctrl-n>` 从终端模式切换到普通模式。普通模式下 `<ScrollWheelUp>` 和 `<ScrollWheelDown>` 可滚动终端缓冲区。

#### 1.3 缓冲

```
Leader+o    输入打开文件的路径，并在当前窗口打开一个缓冲
[+b         切换到上一个缓冲
]+b         切换到下一个缓冲
```

#### 1.4 分屏

```
Leader+Leader+s    输入打开文件的路径，并创建一个水平分屏的窗口
Leader+Leader+v    输入打开文件的路径，并创建一个垂直分屏的窗口

Ctrl+h      跳转到左窗口
Ctrl+j      跳转到下窗口
Ctrl+k      跳转到上窗口
Ctrl+l      跳转到右窗口
Leader+z    窗口放大/恢复
```

#### 1.5 Tab

```
Leader+Leader+t      输入打开的文件路径，并创建一个新tab窗口

[+t         切换到上一个tab窗口
]+t         切换到下一个tab窗口
Leader+1~9  切换到第1~9个tab窗口
Leader+[    切换到第一个tab窗口
Leader+]    切换到最后一个tab窗口
```

#### 1.6 替换（substitute.nvim）

```
s{文本对象}  用剪贴板内容替换一个文本对象（如 siw 替换当前词）
ss          用剪贴板内容替换当前整行
S           用剪贴板内容替换从光标到行尾
```

#### 1.7 LSP（Language Server Protocol）

```
K (gh)             查看光标所在符号的文档说明

gd                 跳转到定义
gc                 跳转到声明
gt                 跳转到类型定义
gi                 跳转到实现（结果在 trouble 中）
gr                 查看引用（结果在 trouble 中）

Leader+rn          重命名符号
[d                 上一个诊断
]d                 下一个诊断
[D                 第一个诊断
]D                 最后一个诊断
Leader+d           切换诊断列表（trouble）
```

文件在保存时自动通过 LSP 格式化。自动补全默认开启 — LSP 建议会自动弹出。

#### 1.8 文件/缓冲/Tag 导航（fzf-lua）

```
Ctrl+p      搜索文件

Leader+b    搜索缓冲
Leader+t    搜索当前文件Tag
Leader+p    搜索项目Tag
Leader+f    搜索当前文件函数
Leader+e    搜索当前文件行
Leader+a    当前目录搜索光标所在的词
```

#### 1.9 折叠（nvim-ufo）

```
za      当光标下的折叠打开时，关闭它。当折叠关闭时，打开它
zc      关闭光标下的折叠
zo      打开光标下的折叠
zR      打开所有折叠
zM      关闭所有折叠
```

#### 1.10 Marks（marks.nvim）

```
m[a-zA-Z]   添加/删除标记
m,          添加下一个可用的标记
m.          如果当前行没有标记，添加下一个可用标记。否则，删除第一个标记

dm[a-zA-Z]  删除标记[a-zA-Z]
m-          删除当前行的所有标记
m<Space>    删除当前buffer的所有标记

'[a-zA-Z]   跳转到标记[a-zA-Z]
]`          跳转到下一个标记
[`          跳转到上一个标记
`]          根据字母序列跳转到下一个标记
`[          根据字母序列跳转到上一个标记
m/          在Location List里，查看当前buffer的所有标记
```

#### 1.11 Oil（文件管理器，替代netrw）

```
-           在当前窗口打开文件所在的文件夹
~           在当前窗口打开项目根路径或用户主目录

<CR>        进入目录或打开文件
-           返回上一级目录
```

#### 1.12 终端

```
F3      在终端中运行一次性命令
F4      切换终端窗口（打开/隐藏）
```

使用 `<Ctrl-\><Ctrl-n>` 从终端模式切换到普通模式。普通模式下 `<ScrollWheelUp>` 和 `<ScrollWheelDown>` 可滚动终端缓冲区。

#### 1.13 围绕字符编辑（mini.surround）

```
ys+textobj+surroundA        在textobj指定的范围增A围绕字符
yss+surroundA               在当前行增加A围绕字符
ds+surroundA                删除A围绕字符
cs+surroundA+surroundB      将A围绕字符改成B围绕字符
```

#### 1.14 其他

```
Leader+ws       保存session
Leader+rs       删除session

'.              最后一次变更的地方
''              跳回来的地方（最近两个位置跳转）
Ctrl+o          跳回，可用于多种类型跳转
Ctrl+i          继续上次跳转（与Ctrl+o操作相反）
cod             切换diff模式
cop             切换paste模式
col             切换list模式
con             清除搜索高亮
Leader+cr       切换到当前文件所在项目根路径
Leader+space        去除行尾空白字符
Leader+Leader+space  去除行尾空白字符 + \r（DOS 换行符）
Leader+q            打开/关闭quickfix（trouble）
Leader+l            打开/关闭location list（trouble）
Leader+gg           打开 Neogit
Leader+gl           打开 Neogit log（当前文件）
Leader+gL           打开 Neogit log（所有引用）
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

可视模式：
Leader+gl           对选中行打开 Neogit log

SudoWrite           使用 root 权限保存文件
```

在 quickfix/location 窗口中：
- `o`/`Enter` — 打开条目（文件+行号）
- `q` — 关闭窗口

`gdefault` 已设置，`:s` 默认执行全局替换。`jumpoptions+=stack` 使跳转列表行为类似标签栈。

#### 1.15 自动插入文件头

新建 `.sh` 和 `.py` 文件会自动插入 shebang 行：
- `.sh` → `#!/usr/bin/env bash`
- `.py` → `#!/usr/bin/env python3`

### 2. 插入模式

#### 2.1 代码片段（LuaSnip）

```
Ctrl+l      展开/确认补全
Tab         跳转到下一个占位符
Shift+Tab   跳转到上一个占位符
```

补全快捷键：

```
Ctrl+l      确认补全或展开/跳转代码片段
Ctrl+j      选择下一个补全项
Ctrl+k      选择上一个补全项
CR          确认补全（选择当前选中项）
```

### 3. 可视化模式

#### 3.1 按键修改

```
s       用剪贴板的内容替换选中文本
;       进入命令行模式，相当于":"键
<       减少缩进，保持选中
>       增加缩进，保持选中
```

#### 3.2 查找

```
Leader+a        当前目录搜索选中字符串（fzf-lua）
```

#### 3.3 替换

```
s{文本对象}  用剪贴板内容替换文本对象（如 siw）
ss          用剪贴板内容替换当前整行
S           用剪贴板内容替换光标到行尾
```

#### 3.4 快速跳转（flash.nvim）

```
f           搜索1个字符并跳转（flash.nvim）
F           基于 treesitter 的跳转
```

#### 3.5 围绕字符编辑（mini.surround）

```
S+surroundA     选中字符串增加A围绕字符
```

### 4. 命令行模式

```
Ctrl+p  上一条命令
Ctrl+n  下一条命令
Ctrl+a  跳到命令行最前
Ctrl+e  跳到命令行最后
```

## 常用命令

### 1. SudoWrite

```vim
" 使用 root 权限保存文件
:SudoWrite
```

### 2. fzf-lua

```vim
" 搜索文件
:FzfLua files

" 搜索缓冲区
:FzfLua buffers

" 实时搜索
:FzfLua live_grep

" 搜索 help 标签
:FzfLua help_tags

" 恢复上次搜索
:FzfLua resume
```

### 3. Neogit

```vim
" 打开 Neogit 状态
:Neogit

" 打开当前文件日志
:Neogit log_current

" 打开项目日志
:Neogit log
```

### 4. Gutentags

```vim
" 为当前文件生成tag
:GutentagsUpdate

" 为整个工程生成tag
:GutentagsUpdate!
```

如果安装了 GNU Global（`gtags`/`global`）和 Pygments（`pygmentize`），gutentags 会在 ctags 之外同时生成 `GTAGS`/`GRTAGS`/`GPATH` 数据库。首次 BufEnter 时自动构建 GTAGS，保存时增量更新。

Cscope 快捷键（通过 cscope_maps.nvim）：

```
gs      查找光标下的符号（Cscope find s）
gD      跳转到定义（Cstag）
gR      查找调用者（Cscope find c）
```

## 在 Neovim 中使用 git

### 1. git for Neovim: [Neogit](https://github.com/NeogitOrg/neogit)

```vim
:Neogit
:Neogit log_current
:Neogit log
:Neogit pull
:Neogit push
:Neogit commit
:Neogit branch
```

### 2. Git 差异标记：[gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)

```vim
]h / [h  跳转到下一个/上一个修改块

:Gitsigns preview_hunk
:Gitsigns stage_hunk
:Gitsigns reset_hunk

:Gitsigns setqflist
:Gitsigns setloclist
```

### 3. 并排差异对比：[codediff.nvim](https://github.com/esmuellert/codediff.nvim)

```vim
:CodeDiff
```

## 注意事项

- **缩进规则** — monkey-nvim 按文件类型应用缩进设置：

| 文件类型 | 风格 | 宽度 |
|---|---|---|
| `c`, `cpp`, `go`, `sh`, `vim`, `sql` | 硬制表符 (`noexpandtab`) | 4 |
| `rust`, `python`, `markdown` | 空格 (`expandtab`) | 4 |
| `javascript`, `typescript`, `lua`, `yaml`, `json` | 空格 (`expandtab`) | 2 |

全局默认使用 4 宽度硬制表符。

- Neovim 剪贴板集成

monkey-nvim 在检测到显示服务器时设置 `clipboard=unnamed,unnamedplus`，复制/删除操作会自动同步到系统剪贴板。

如需独立的剪贴板管理工具（可选）：

| 工具 | 平台 | 用途 |
|---|---|---|
| [parcellite](https://parcellite.sourceforge.net/) | X11 | 轻量级剪贴板管理器，支持持久化历史 |
| [cliphist](https://github.com/sentriz/cliphist) | Wayland | wlroots 剪贴板历史管理 |
| 系统自带 | macOS/WSL | 系统剪贴板默认持久化，无需额外工具 |

> 可选 CLI 工具：`wl-clipboard`（Wayland，提供 `wl-copy`/`wl-paste`）、`xclip` 或 `xsel`（X11）。Neovim 内建剪贴板支持，这些工具仅在 Neovim 外部需要命令行剪贴板访问时使用。

## 额外设置

- 在 bashrc 中加入以下 Shell 代码，在 Neovim 中查看 man 文档：

```bash
export MANPAGER="nvim -R +MANPAGER -"
```

## 从源码编译 Neovim

获取最新版本或系统仓库中不包含的功能：

```bash
git clone https://github.com/neovim/neovim.git
cd neovim
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
```
