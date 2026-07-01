-- =========================
-- Neovim configuration (Lua)
--
-- This file is symlinked to ~/.config/nvim/init.lua by modules/40-neovim.sh.
-- Edit it here (in the dotfiles repo) and changes apply immediately.
-- =========================

vim.cmd("syntax enable")

-- UI
vim.opt.number = true
vim.opt.ruler = true
vim.opt.cursorline = true
vim.opt.showmatch = true
vim.opt.background = "dark"

-- Tabs / indent
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.cmd("filetype plugin indent on")

-- Persistent undo
vim.opt.undofile = true
local undo_dir = vim.fn.stdpath("state") .. "/undo"
if vim.fn.isdirectory(undo_dir) == 0 then
  vim.fn.mkdir(undo_dir, "p")
end
vim.opt.undodir = undo_dir

-- Search & navigation
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Clipboard / swap / autosave
vim.opt.clipboard = "unnamedplus"
vim.opt.swapfile = false
vim.api.nvim_create_autocmd("FocusLost", {
  pattern = "*",
  command = "silent! wa",
})

-- Leader
vim.g.mapleader = " "

-- Keymaps
local map = vim.keymap.set
map("n", "<Leader>w", ":w<CR>", { silent = true })
map("n", "<C-h>", "<C-w>h", { silent = true })
map("n", "<C-j>", "<C-w>j", { silent = true })
map("n", "<C-k>", "<C-w>k", { silent = true })
map("n", "<C-l>", "<C-w>l", { silent = true })

-- True color
vim.opt.termguicolors = true

-- Tokyonight globals (set before colorscheme)
vim.g.tokyonight_style = "night"      -- storm | night | moon | day
vim.g.tokyonight_transparent = 0
vim.g.tokyonight_terminal_colors = 1

-- =========================
-- Plugins (vim-plug)
-- =========================
vim.cmd([[
  call plug#begin('~/.local/share/nvim/plugged')

  Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'github/copilot.vim'
  Plug 'folke/snacks.nvim'
  Plug 'coder/claudecode.nvim'

  call plug#end()
]])

-- Theme
pcall(vim.cmd, "colorscheme tokyonight")
vim.api.nvim_create_user_command("Tokyo", function()
  vim.cmd("colorscheme tokyonight")
end, {})
map("n", "<Leader>tn", ":Tokyo<CR>", { silent = true })

-- =========================
-- Claude Code (coder/claudecode.nvim)
-- Connects Neovim to the Claude Code CLI (installed by modules/30-ai-cli.sh)
-- =========================
pcall(function()
  require("claudecode").setup()

  -- Keymaps (mirror the plugin's recommended defaults)
  map("n", "<Leader>ac", "<cmd>ClaudeCode<CR>", { silent = true, desc = "Toggle Claude" })
  map("n", "<Leader>af", "<cmd>ClaudeCodeFocus<CR>", { silent = true, desc = "Focus Claude" })
  map("v", "<Leader>as", "<cmd>ClaudeCodeSend<CR>", { silent = true, desc = "Send selection to Claude" })
  map("n", "<Leader>ab", "<cmd>ClaudeCodeAdd %<CR>", { silent = true, desc = "Add current buffer to Claude" })
end)
