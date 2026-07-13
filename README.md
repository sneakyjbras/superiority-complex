# Superiority Complex — Manjaro/Arch dotfiles

A one-command bootstrap for a fresh **Arch-based** (Manjaro) machine. Clone it,
run one script, and get your packages, Zsh, terminal AI CLIs, Neovim, and Konsole
themes set up. Every step is **idempotent** (safe to re-run) and **resilient** (a
single failing step won't abort the whole install — you get a summary at the end).

## Quick start

```bash
git clone <this-repo> superiority-complex
cd superiority-complex
./install.sh
```

That's it. `./setup.sh` still works too (it just forwards to `install.sh`).

### Running only part of it

```bash
./install.sh --list        # list available modules
./install.sh neovim        # run only the Neovim module
./install.sh 20 30         # run the shell + AI-CLI modules
```

## What it does

| Module | Purpose |
| ------ | ------- |
| `modules/10-packages.sh` | `pacman -Syu`, install official-repo package groups, **auto-bootstrap `yay`** if no AUR helper exists, then install AUR apps. |
| `modules/20-shell.sh` | Manjaro Zsh config/prompt/plugins, `ssh-agent` init, PATH. |
| `modules/30-ai-cli.sh` | Claude Code (native installer) + npm CLIs (Codex, Gemini) + pipx CLIs (Aider); **symlinks** `config/claude/{settings.json,CLAUDE.md}` into `~/.claude`. |
| `modules/40-neovim.sh` | Neovim + tooling, **symlinks** `config/nvim/init.lua`, syncs plugins headlessly (**lazy.nvim** self-bootstraps). |
| `modules/50-konsole.sh` | Installs the shipped Konsole profile/colorscheme. |

## Layout

```
install.sh            # single entry point / orchestrator
setup.sh              # back-compat shim -> install.sh
lib/common.sh         # logging, idempotent helpers, module runner + summary
config/
  packages.sh         # EDIT ME: all package lists (pacman groups, AUR, npm, nvim)
  nvim/init.lua       # EDIT ME: Neovim config (symlinked to ~/.config/nvim)
modules/*.sh          # one self-contained step each (also runnable standalone)
konsole/              # Konsole theme assets
```

## Customizing

- **Packages** — edit `config/packages.sh`. It's data only: `PACMAN_GROUPS`,
  `AUR_PKGS`, `NPM_AI_CLIS`, `NVIM_PKGS`.
- **Neovim** — edit `config/nvim/init.lua` directly. It's symlinked into
  `~/.config/nvim`, so changes apply immediately and stay tracked in git.
- **SSH key** — set `SSH_KEY_PATH` before running to add a non-default key:
  `SSH_KEY_PATH=~/.ssh/id_ed25519 ./install.sh`.

## Neovim highlights

Plugins (via **lazy.nvim**, self-bootstrapping): `tokyonight.nvim`,
`telescope.nvim` (+ `plenary.nvim`), `nvim-treesitter`, `copilot.vim`, plus three
AI assistants:

- **`claudecode.nvim`** (+ `snacks.nvim`) — drives the Claude Code CLI in-editor.
- **`codecompanion.nvim`** — chat/inline AI with Claude, Gemini and Codex
  (OpenAI) adapters.
- **`avante.nvim`** — Cursor-style AI panel (`provider = claude`; switch with
  `:AvanteSwitchProvider gemini|openai`).

API keys are read from the environment: `ANTHROPIC_API_KEY`, `GEMINI_API_KEY`,
`OPENAI_API_KEY`. Leader is `Space`:

| Key | Action |
| --- | ------ |
| `<Space>cc` | Toggle Claude Code |
| `<Space>cf` | Focus Claude Code |
| `<Space>cr` | Resume Claude Code |
| `<Space>cs` | Send visual selection to Claude Code |
| `<Space>cb` | Add current buffer to Claude Code |
| `<Space>ia` | CodeCompanion actions |
| `<Space>ic` | Toggle CodeCompanion chat |
| `<Space>ip` | CodeCompanion inline prompt |
| `<Space>aa` | Avante: ask (and other `<Space>a*` Avante defaults) |
| `<Space>ff` / `<Space>fg` | Telescope find files / live grep |
| `<Space>tn` | Re-apply Tokyonight theme |

## Prerequisites

An Arch-based distro with `pacman` and `sudo`. An AUR helper is **not** required —
`yay` is bootstrapped automatically when needed.

## License

MIT — see `LICENSE`.
