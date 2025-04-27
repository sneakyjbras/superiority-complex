" Enable syntax highlighting
if has("syntax")
    syntax enable
endif

" Set line number
set number

" Set background and colorscheme
set background=dark
if exists("g:colors_name") && g:colors_name == "dracula"
    colorscheme dracula
else
    " Fallback colorscheme if Dracula is not available
    set t_Co=256
    colorscheme default
endif

" Converts tab into spaces
set expandtab

" Config tab to equal 2 spaces
set tabstop=2
set softtabstop=2
set shiftwidth=2

" Show number ruler on Vim
set ruler

" Set auto indentation
set autoindent
set smartindent

" Enable file type detection and related plugins
filetype plugin indent on

" Highlight search results
set hlsearch

" Incremental search
set incsearch

" Ignore case when searching, unless a capital letter is used
set ignorecase
set smartcase

" Use system clipboard for copy/paste
set clipboard=unnamedplus

" Disable swap files
set noswapfile

" Enable persistent undo
set undofile
if !isdirectory($HOME . '/.vim/undodir')
    silent !mkdir -p ~/.vim/undodir
endif
set undodir=~/.vim/undodir

" Show a better status line
set laststatus=2
set showcmd
set ruler

" Map <leader> key to space
let mapleader=" "

" Quick saving with <leader>w
nnoremap <leader>w :w<CR>

" Better window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Show line cursor
set cursorline

" Highlight current column
set cursorcolumn

" Display matching parentheses
set showmatch

" Enable mouse support
set mouse=a

" Enhanced command-line completion
set wildmenu
set wildmode=longest:full,full

" Enable code folding based on indentation
set foldmethod=indent
set foldlevel=99  " Start with all folds open

" Add a basic setup for auto-completion
set completeopt=menu,menuone,noselect

" Smoother scrolling
set scrolloff=8   " Keeps 8 lines above/below the cursor
set sidescrolloff=8

" Automatically save files when focus is lost
autocmd FocusLost * silent! wa

" Rsync Remote Settings
let g:rsync#remote = {
    \ 'host': 'user@yourserver.com',
    \ 'port': 22,
    \ 'path': '/path/to/remote/directory',
    \ }

" Plugin Manager Configuration (e.g., vim-plug)
" Ensure you have vim-plug installed: https://github.com/junegunn/vim-plug
call plug#begin('~/.vim/plugged')
Plug 'preservim/nerdtree'        " File explorer
Plug 'tpope/vim-fugitive'        " Git integration
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }  " Fuzzy finder
Plug 'dracula/vim', { 'as': 'dracula' }  " Dracula colorscheme
Plug 'dense-analysis/ale'        " Linting and code fixes
Plug 'tpope/vim-commentary'      " Code commenting
call plug#end()

