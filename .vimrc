" =========================
" Begin Vim configuration
" =========================

" Enable syntax highlighting
if has("syntax")
  syntax enable
endif

" Set basic UI
set number                   " Show line numbers
set ruler                    " Show line/column in status
set cursorline               " Highlight current line
set showmatch                " Highlight matching brackets
set background=dark          " Dark background

" =========================
" Tabs, Indentation & Undo
" =========================

set expandtab                " Convert tabs to spaces
set tabstop=2                " 2 spaces per Tab
set softtabstop=2
set shiftwidth=2
set autoindent               " Copy indent from previous line
set smartindent              " C-like auto indent
filetype plugin indent on    " Filetype‑specific indenting

" Persistent undo
set undofile
if !isdirectory($HOME . '/.vim/undodir')
  silent !mkdir -p ~/.vim/undodir
endif
set undodir=~/.vim/undodir

" =========================
" Search & Navigation
" =========================

set hlsearch                 " Highlight search matches
set incsearch                " Show matches as you type
set ignorecase               " Case‑insensitive...
set smartcase                " ...unless you use a capital letter
set scrolloff=8              " Keep 8 lines above/below cursor
set sidescrolloff=8

" =========================
" Clipboard, Swap & Auto‑save
" =========================

set clipboard=unnamedplus    " Use system clipboard
set noswapfile               " Disable swapfiles
autocmd FocusLost * silent! wa  " Auto‑save when focus lost

" =========================
" Mappings & Leader Key
" =========================

let mapleader=" "            " Leader = Space

" Quick save with <Leader>w
nnoremap <silent> <Leader>w :w<CR>

" Better split navigation
nnoremap <silent> <C-h> <C-w>h
nnoremap <silent> <C-j> <C-w>j
nnoremap <silent> <C-k> <C-w>k
nnoremap <silent> <C-l> <C-w>l

" =========================
" True‑Color & Night Owl
" =========================

" 1) Enable 24‑bit (true) color support
if has('termguicolors')
  set termguicolors
endif

" 2) Plugin manager (vim‑plug) — only Night Owl
call plug#begin('~/.vim/plugged')
Plug 'haishanh/night-owl.vim'
call plug#end()

" 3) Load Night Owl by default
colorscheme night-owl

" 4) Custom command & shortcut to reload Night Owl
command! NightOwl colorscheme night-owl
nnoremap <silent> <Leader>no :NightOwl<CR>

