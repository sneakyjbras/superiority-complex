#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Neovim bootstrap for Manjaro/Arch (vim-plug based)
# - Installs Neovim + useful deps
# - Ensures Node.js + npm for Copilot (prefers Manjaro LTS if neither is installed)
# - Installs vim-plug for Neovim
# - Writes ~/.config/nvim/init.vim (Tokyonight + Copilot)
# - Creates user-level symlinks so `vim`/`vi` -> `nvim`
# ------------------------------------------------------------

echo "Installing base packages (neovim + tools)..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm \
  neovim git curl ripgrep fd \
  wl-clipboard xclip

echo "Ensuring Node.js + npm (required for Copilot)..."
# Manjaro has mutually exclusive node packages: nodejs (current) vs nodejs-lts-iron (LTS).
# Prefer what's already installed; otherwise install LTS.
if pacman -Qq nodejs-lts-iron &>/dev/null; then
  echo "Found nodejs-lts-iron (LTS)"
  sudo pacman -S --needed --noconfirm npm
elif pacman -Qq nodejs &>/dev/null; then
  echo "Found nodejs (current)"
  sudo pacman -S --needed --noconfirm npm
else
  echo "Installing nodejs-lts-iron (LTS) + npm"
  sudo pacman -S --needed --noconfirm nodejs-lts-iron npm
fi

echo "Setting up Neovim config..."
mkdir -p "$HOME/.config/nvim"

echo "Installing vim-plug for Neovim..."
curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "Writing init.vim (Tokyonight + Copilot)..."
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

" Persistent undo (Neovim XDG state dir)
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

" Plugins (vim-plug)
call plug#begin(stdpath('data') . '/plugged')
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
Plug 'github/copilot.vim'
call plug#end()

" Theme
try
  colorscheme tokyonight
catch /^Vim\%((\a\+)\)\=:E185/
  echohl WarningMsg
  echom "Tokyonight not installed – run :PlugInstall"
  echohl None
endtry

command! Tokyo colorscheme tokyonight
nnoremap <silent> <Leader>tn :Tokyo<CR>

" Copilot:
" One-time auth: :Copilot setup
" Accept suggestions with <Tab> (default behavior when a suggestion is visible).
EOF

echo "Creating user-level symlinks (vim/vi -> nvim)..."
mkdir -p "$HOME/.local/bin"
ln -sf /usr/bin/nvim "$HOME/.local/bin/vim"
ln -sf /usr/bin/nvim "$HOME/.local/bin/vi"

echo "Ensuring ~/.local/bin is on PATH (zsh + bash)..."
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
  [[ -f "$rc" ]] || continue
  grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' "$rc" || \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
done

echo "Installing plugins via vim-plug (headless)..."
nvim --headless +PlugInstall +qall

echo "Done."
echo "Neovim config: $HOME/.config/nvim/init.vim"
echo "Symlinks: $HOME/.local/bin/vim and $HOME/.local/bin/vi -> /usr/bin/nvim"
echo "Next (one-time): open nvim and run :Copilot setup"

