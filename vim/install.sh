#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Neovim bootstrap for Manjaro/Arch
# - (Optional) removes Vim if installed
# - Installs Neovim + Node.js + npm (required for Copilot)
# - Installs plugins via native pack/* (git clone):
#     - github/copilot.vim
#     - folke/tokyonight.nvim
# - Writes ~/.config/nvim/init.vim
# - Creates user-level symlinks so `vim`/`vi` -> `nvim`
# ------------------------------------------------------------

# 0) Optional: remove Vim if installed (comment these out if you want to keep Vim)
if pacman -Qq vim &>/dev/null; then
  sudo pacman -Rns --noconfirm vim || true
fi
if pacman -Qq gvim &>/dev/null; then
  sudo pacman -Rns --noconfirm gvim || true
fi

# 1) Install requirements (Copilot needs node + npm)
sudo pacman -S --needed --noconfirm \
  neovim git curl ripgrep fd \
  nodejs npm \
  wl-clipboard xclip

# 2) Neovim config dir
mkdir -p "$HOME/.config/nvim"

# 3) Install Copilot (native pack install, per GitHub instructions)
COPILOT_DIR="$HOME/.config/nvim/pack/github/start/copilot.vim"
if [[ -d "$COPILOT_DIR/.git" ]]; then
  git -C "$COPILOT_DIR" pull --ff-only
else
  rm -rf "$COPILOT_DIR"
  git clone --depth=1 https://github.com/github/copilot.vim.git "$COPILOT_DIR"
fi

# 4) Install Tokyonight (native pack install)
TOKYO_DIR="$HOME/.config/nvim/pack/themes/start/tokyonight.nvim"
if [[ -d "$TOKYO_DIR/.git" ]]; then
  git -C "$TOKYO_DIR" pull --ff-only
else
  rm -rf "$TOKYO_DIR"
  git clone --depth=1 https://github.com/folke/tokyonight.nvim.git "$TOKYO_DIR"
fi

# 5) Write init.vim (Tokyonight + your settings; Copilot loads automatically)
cat > "$HOME/.config/nvim/init.vim" <<'EOF'
" =========================
" Neovim configuration
" =========================

syntax enable

set number
set ruler
set cursorline
set showmatch
set background=dark

set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set autoindent
set smartindent
filetype plugin indent on

set undofile
let s:undo_dir = stdpath('state') . '/undo'
if !isdirectory(s:undo_dir)
  call mkdir(s:undo_dir, 'p')
endif
let &undodir = s:undo_dir

set hlsearch
set incsearch
set ignorecase
set smartcase
set scrolloff=8
set sidescrolloff=8

set clipboard=unnamedplus
set noswapfile
autocmd FocusLost * silent! wa

let mapleader=" "
nnoremap <silent> <Leader>w :w<CR>

nnoremap <silent> <C-h> <C-w>h
nnoremap <silent> <C-j> <C-w>j
nnoremap <silent> <C-k> <C-w>k
nnoremap <silent> <C-l> <C-w>l

if has('termguicolors')
  set termguicolors
endif

" Tokyonight options: storm | night | moon | day
let g:tokyonight_style = "night"
let g:tokyonight_transparent = 0
let g:tokyonight_terminal_colors = 1

try
  colorscheme tokyonight
catch /^Vim\%((\a\+)\)\=:E185/
  echohl WarningMsg
  echom "Tokyonight not installed (pack plugin missing?)"
  echohl None
endtry

command! Tokyo colorscheme tokyonight
nnoremap <silent> <Leader>tn :Tokyo<CR>

" Copilot:
" - plugin is installed in pack/... so it loads automatically
" - first-time setup is manual: :Copilot setup
" - default accept key is <Tab> (Copilot’s default)
EOF

# 6) User-level symlinks (safe: no touching /usr/bin)
mkdir -p "$HOME/.local/bin"
ln -sf /usr/bin/nvim "$HOME/.local/bin/vim"
ln -sf /usr/bin/nvim "$HOME/.local/bin/vi"

# 7) Ensure ~/.local/bin is on PATH (zsh + bash)
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
  [[ -f "$rc" ]] || continue
  grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' "$rc" || \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
done

echo "Done."
echo "Neovim config: $HOME/.config/nvim/init.vim"
echo "Copilot installed at: $COPILOT_DIR"
echo "Tokyonight installed at: $TOKYO_DIR"
echo "Next (one-time): open nvim and run :Copilot setup"

