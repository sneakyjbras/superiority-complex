-- =========================
-- Neovim configuration (Lua) — managed by lazy.nvim
--
-- This file is symlinked to ~/.config/nvim/init.lua by modules/40-neovim.sh.
-- Edit it here (in the dotfiles repo) and changes apply on next launch.
--
-- Plugin manager: lazy.nvim (self-bootstrapping — no vim-plug).
-- =========================

-- Leader keys MUST be set before lazy.setup so plugin keymaps register correctly.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- =========================
-- Options
-- =========================
vim.cmd("syntax enable")

-- UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ruler = true
vim.opt.cursorline = true
vim.opt.showmatch = true
vim.opt.background = "dark"
vim.opt.termguicolors = true

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

-- =========================
-- Keymaps (non-plugin)
-- =========================
local map = vim.keymap.set
map("n", "<Leader>w", ":w<CR>", { silent = true, desc = "Save" })
map("n", "<C-h>", "<C-w>h", { silent = true, desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { silent = true, desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { silent = true, desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { silent = true, desc = "Window right" })

-- =========================
-- Bootstrap lazy.nvim
-- =========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =========================
-- Plugins
-- =========================
require("lazy").setup({
  -- Theme -------------------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({ style = "night" })
      vim.cmd.colorscheme("tokyonight")
      vim.api.nvim_create_user_command("Tokyo", function()
        vim.cmd.colorscheme("tokyonight")
      end, {})
      map("n", "<Leader>tn", "<cmd>Tokyo<CR>", { silent = true, desc = "Tokyonight" })
    end,
  },

  -- Fuzzy finder ------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<Leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<Leader>fg", "<cmd>Telescope live_grep<CR>",  desc = "Live grep" },
      { "<Leader>fb", "<cmd>Telescope buffers<CR>",    desc = "Buffers" },
    },
  },

  -- Treesitter (required by codecompanion + avante) -------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc", "bash", "python",
          "c", "cpp", "markdown", "markdown_inline",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- GitHub Copilot ----------------------------------------------------------
  { "github/copilot.vim" },

  -- snacks.nvim (terminal/UI provider for claudecode) -----------------------
  { "folke/snacks.nvim", priority = 1000, lazy = false, opts = {} },

  -- Claude Code CLI bridge (coder/claudecode.nvim) --------------------------
  -- Drives the Claude Code CLI (installed by modules/30-ai-cli.sh). Prefix: <leader>c
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    keys = {
      { "<leader>c",  nil,                          desc = "Claude Code" },
      { "<leader>cc", "<cmd>ClaudeCode<cr>",        desc = "Toggle Claude" },
      { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>",   desc = "Focus Claude" },
      { "<leader>cr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>cs", "<cmd>ClaudeCodeSend<cr>",    mode = "v", desc = "Send selection to Claude" },
      { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>",   desc = "Add current buffer to Claude" },
    },
  },

  -- CodeCompanion (in-editor chat/inline AI) --------------------------------
  -- Adapters for Claude (anthropic), Gemini and Codex (openai). API keys are
  -- read from the environment: ANTHROPIC_API_KEY / GEMINI_API_KEY / OPENAI_API_KEY.
  -- Prefix: <leader>i  ("AI")
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    keys = {
      { "<leader>i",  nil,                                mode = { "n", "v" }, desc = "CodeCompanion (AI)" },
      { "<leader>ia", "<cmd>CodeCompanionActions<cr>",    mode = { "n", "v" }, desc = "AI actions" },
      { "<leader>ic", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "Toggle AI chat" },
      { "<leader>ip", "<cmd>CodeCompanion<cr>",           mode = { "n", "v" }, desc = "AI inline prompt" },
    },
    opts = {
      adapters = {
        http = {
          anthropic = function()
            return require("codecompanion.adapters").extend("anthropic", {
              env = { api_key = "ANTHROPIC_API_KEY" },
            })
          end,
          gemini = function()
            return require("codecompanion.adapters").extend("gemini", {
              env = { api_key = "GEMINI_API_KEY" },
            })
          end,
          openai = function()
            return require("codecompanion.adapters").extend("openai", {
              env = { api_key = "OPENAI_API_KEY" },
            })
          end,
        },
      },
      strategies = {
        chat   = { adapter = "anthropic" },
        inline = { adapter = "anthropic" },
        cmd    = { adapter = "anthropic" },
      },
    },
  },

  -- Avante (Cursor-style AI panel) ------------------------------------------
  -- provider = "claude"; switch at runtime with :AvanteSwitchProvider gemini|openai.
  -- Keys: <leader>a* (avante defaults). Reads ANTHROPIC/GEMINI/OPENAI API keys from env.
  {
    "yetone/avante.nvim",
    build = "make",
    event = "VeryLazy",
    version = false,
    opts = {
      provider = "claude",
      providers = {
        claude = { endpoint = "https://api.anthropic.com" },
        gemini = { endpoint = "https://generativelanguage.googleapis.com/v1beta/openai/" },
        openai = { endpoint = "https://api.openai.com/v1" },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = { file_types = { "markdown", "Avante" } },
        ft = { "markdown", "Avante" },
      },
    },
  },
})
