#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Neovim bootstrap for Manjaro/Arch
# - Installs neovim + dependencies
# - Installs vim-plug for Neovim
# - Writes ~/.config/nvim/init.vim (Tokyonight + your settings)
# - Creates user-level symlinks so `vim`/`vi` -> `nvim`
# ------------------------------------------------------------

# Packages you likely want (clipboard + curl for plug)
sudo pacman -Syu --needed --noconfirm neovim git curl ripgrep fd wl-clipboard xclip

# Neovim config dir
mkdir -p "$HOME/.config/nvim"

# Install vim-plug for Neovim
curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Write init.vim (Tokyonight + your settings)
cat > "$HOME/.config/nvim/init.vim" <<'EOF'
" =========================
" Begin Neovim configuration
" =========================

" Enable syntax highlighting
syntax enable

" Set basic UI
set number
set ruler
set cursorline
set showmatch
set background=dark

" =========================
" Tabs, Indentation & Undo
" =========================

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

" =========================
" Search & Navigation
" =========================

set hlsearch
set incsearch
set ignorecase
set smartcase
set scrolloff=8
set sidescrolloff=8

" =========================
" Clipboard, Swap & Auto-save
" =========================

set clipboard=unnamedplus
set noswapfile
autocmd FocusLost * silent! wa

" =========================
" Mappings & Leader Key
" =========================

let mapleader=" "

nnoremap <silent> <Leader>w :w<CR>

nnoremap <silent> <C-h> <C-w>h
nnoremap <silent> <C-j> <C-w>j
nnoremap <silent> <C-k> <C-w>k
nnoremap <silent> <C-l> <C-w>l

" =========================
" True-Color & Tokyonight
" =========================

if has('termguicolors')
  set termguicolors
endif

" Tokyonight options: storm | night | moon | day
let g:tokyonight_style = "night"
let g:tokyonight_transparent = 0
let g:tokyonight_terminal_colors = 1

" =========================
" Plugins (vim-plug)
" =========================

call plug#begin(stdpath('data') . '/plugged')
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
call plug#end()

try
  colorscheme tokyonight
catch /^Vim\%((\a\+)\)\=:E185/
  echohl WarningMsg
  echom "Tokyonight theme not installed – run :PlugInstall"
  echohl None
endtry

command! Tokyo colorscheme tokyonight
nnoremap <silent> <Leader>tn :Tokyo<CR>
EOF

# User-level symlinks (safe: no touching /usr/bin)
mkdir -p "$HOME/.local/bin"
ln -sf /usr/bin/nvim "$HOME/.local/bin/vim"
ln -sf /usr/bin/nvim "$HOME/.local/bin/vi"

# Ensure ~/.local/bin is on PATH for common shells
# (won't duplicate lines)
if [ -n "${BASH_VERSION-}" ]; then
  PROFILE="$HOME/.bashrc"
elif [ -n "${ZSH_VERSION-}" ]; then
  PROFILE="$HOME/.zshrc"
else
  PROFILE=""
fi

if [ -n "$PROFILE" ]; then
  if ! grep -qs 'export PATH="$HOME/.local/bin:$PATH"' "$PROFILE"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$PROFILE"
  fi
fi

# Install plugins headlessly
nvim --headless +PlugInstall +qall

echo "Done."
echo "Neovim config: $HOME/.config/nvim/init.vim"
echo "vim/vi now point to nvim via: $HOME/.local/bin"
echo "Restart your shell (or: source ~/.bashrc / ~/.zshrc) to pick up PATH changes."


