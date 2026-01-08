#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Neovim bootstrap for Manjaro/Arch (vim-plug + init.lua)
# Requirements:
# - Neovim
# - Node.js + npm (Copilot)
# - Plugins installed via vim-plug:
#   - tokyonight.nvim
#   - github/copilot.vim
#   - ChatGPT.nvim (+ plenary + nui)
# - No "dual boot": remove ~/.config/nvim/init.vim
# - User-level symlinks: vim/vi -> nvim
# ------------------------------------------------------------

# 1) (Optional) remove Vim packages if present
if pacman -Qq vim &>/dev/null; then
  sudo pacman -Rns --noconfirm vim || true
fi
if pacman -Qq gvim &>/dev/null; then
  sudo pacman -Rns --noconfirm gvim || true
fi

# 2) Base packages (no full upgrade here; your main setup script can do -Syu)
sudo pacman -S --needed --noconfirm \
  neovim git curl ripgrep fd \
  wl-clipboard xclip

# 3) Ensure Node.js + npm for Copilot (avoid Manjaro nodejs vs nodejs-lts conflicts)
if pacman -Qq nodejs-lts-iron &>/dev/null; then
  sudo pacman -S --needed --noconfirm npm
elif pacman -Qq nodejs &>/dev/null; then
  sudo pacman -S --needed --noconfirm npm
else
  if sudo pacman -S --needed --noconfirm nodejs-lts-iron npm; then
    :
  else
    sudo pacman -S --needed --noconfirm nodejs npm
  fi
fi

# 4) Install vim-plug for Neovim
curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# 5) Neovim config dir + remove old init.vim (no dual boot)
mkdir -p "$HOME/.config/nvim"
rm -f "$HOME/.config/nvim/init.vim"

# 6) Write init.lua
cat > "$HOME/.config/nvim/init.lua" <<'EOF'
-- =========================
-- Neovim configuration (Lua)
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

-- Persistent undo (Neovim XDG state dir)
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
local plugged = vim.fn.stdpath("data") .. "/plugged"
vim.fn["plug#begin"](plugged)

vim.cmd([[Plug 'folke/tokyonight.nvim', { 'branch': 'main' }]])
vim.cmd([[Plug 'github/copilot.vim']])

-- ChatGPT.nvim + deps
vim.cmd([[Plug 'nvim-lua/plenary.nvim']])
vim.cmd([[Plug 'MunifTanjim/nui.nvim']])
vim.cmd([[Plug 'jackMort/ChatGPT.nvim']])

vim.fn["plug#end"]()

-- Theme
pcall(vim.cmd, "colorscheme tokyonight")
vim.api.nvim_create_user_command("Tokyo", function()
  vim.cmd("colorscheme tokyonight")
end, {})
map("n", "<Leader>tn", ":Tokyo<CR>", { silent = true })

-- ChatGPT.nvim (requires OPENAI_API_KEY in your environment)
pcall(function()
  require("chatgpt").setup({})
end)

-- Convenience mappings for ChatGPT.nvim
map("n", "<Leader>cg", ":ChatGPT<CR>", { silent = true })
map("v", "<Leader>ce", ":ChatGPTExplain<CR>", { silent = true })
map("v", "<Leader>cr", ":ChatGPTRefactor<CR>", { silent = true })
EOF

# 7) User-level symlinks (vim/vi -> nvim)
mkdir -p "$HOME/.local/bin"
ln -sf /usr/bin/nvim "$HOME/.local/bin/vim"
ln -sf /usr/bin/nvim "$HOME/.local/bin/vi"

# 8) Ensure ~/.local/bin is on PATH (zsh + bash), idempotent
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
  [[ -f "$rc" ]] || continue
  grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' "$rc" || \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
done

# 9) Install plugins headlessly
nvim --headless +PlugInstall +qall

