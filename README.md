# Superiority Complex — Manjaro/Arch dotfiles

A one-command bootstrap for a fresh **Arch-based** (Manjaro) machine. Clone it,
run one script, and get your packages, Zsh, terminal AI CLIs, Neovim, Konsole
themes set up on top of the stock KDE Plasma desktop. Every step is
**idempotent** (safe to
re-run) and **resilient** (a single failing step won't abort the whole install —
you get a summary at the end).

## The stack

The whole point is that there isn't much of it. The desktop is whatever KDE
ships; one terminal, one editor, two AI CLIs:

| Layer | What | Notes |
| ----- | ---- | ----- |
| **Desktop** | **KDE Plasma** (stock) | Manjaro's own Plasma/KWin. Nothing here configures or replaces it — see below. |
| | SDDM | Login screen, as shipped. |
| **Terminal** | **Konsole** + **Zsh** | KDE's terminal. Manjaro zsh config + syntax highlighting + autosuggestions. |
| **Editor / IDE** | **Neovim** | The *only* editor. No VS Code, no Cursor — see below. |
| **AI** | **Claude Code** (`claude`) | Terminal agent; config tracked in `config/claude/`. |
| | **Antigravity** (`agy`) | Google's terminal agent; self-updates. |
| | **`copilot.vim`** | Inline completion inside Neovim. |

### No IDE, on purpose

**VS Code and Cursor are deliberately not installed.** Neovim plus the AI CLIs
covers the same ground without a 3 GB Electron app per editor, and the config
here is a single ~160-line `init.lua` that lives in git rather than a settings
blob that drifts per machine. Nothing in this repo installs either one, and
neither should be re-added without a reason.

Copilot is kept **in Neovim only** (`copilot.vim`), authenticated through
`~/.config/github-copilot`.

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
| `modules/30-ai-cli.sh` | Claude Code (native installer) + Antigravity (`agy`, self-updating); **symlinks** `config/claude/{settings.json,CLAUDE.md}` into `~/.claude`. |
| `modules/40-neovim.sh` | Neovim + tooling, **symlinks** `config/nvim/init.lua`, syncs plugins headlessly (**lazy.nvim** self-bootstraps). |
| `modules/50-konsole.sh` | Installs the shipped Konsole profile/colorscheme. |

Nothing touches the desktop session — there is no window-manager module.

## Layout

```
install.sh            # single entry point / orchestrator
setup.sh              # back-compat shim -> install.sh
lib/common.sh         # logging, idempotent helpers, module runner + summary
config/
  packages.sh         # EDIT ME: all package lists (pacman groups, AUR, nvim)
  nvim/init.lua       # EDIT ME: Neovim config (symlinked to ~/.config/nvim)
  claude/             # Claude Code settings.json + CLAUDE.md (symlinked to ~/.claude)
modules/*.sh          # one self-contained step each (also runnable standalone)
konsole/              # Konsole theme assets
```

## Customizing

- **Packages** — edit `config/packages.sh`. It's data only: `PACMAN_GROUPS`,
  `AUR_PKGS`, `NVIM_PKGS`.
- **Neovim** — edit `config/nvim/init.lua` directly. It's symlinked into
  `~/.config/nvim`, so changes apply immediately and stay tracked in git.
- **Desktop** — use KDE's own System Settings; it isn't managed from here.
- **SSH key** — set `SSH_KEY_PATH` before running to add a non-default key:
  `SSH_KEY_PATH=~/.ssh/id_ed25519 ./install.sh`.

## AI CLIs

Deliberately just two, both self-updating standalone binaries in `~/.local/bin`:

- **Claude Code** (`claude`) — installed via its native installer.
- **Antigravity** (`agy`) — Google's CLI; kept current with `agy update`.

Codex, `@google/gemini-cli`, Aider and opencode were removed on purpose; don't
re-add them without a reason.

## Neovim highlights

Plugins (via **lazy.nvim**, self-bootstrapping): `tokyonight.nvim`,
`telescope.nvim` (+ `plenary.nvim`), `nvim-treesitter`, `copilot.vim`, and
**`claudecode.nvim`** (+ `snacks.nvim`) which drives the Claude Code CLI
in-editor. Leader is `Space`:

| Key | Action |
| --- | ------ |
| `<Space>cc` | Toggle Claude Code |
| `<Space>cf` | Focus Claude Code |
| `<Space>cr` | Resume Claude Code |
| `<Space>cs` | Send visual selection to Claude Code |
| `<Space>cb` | Add current buffer to Claude Code |
| `<Space>ff` / `<Space>fg` / `<Space>fb` | Telescope find files / live grep / buffers |
| `<Space>tn` | Re-apply Tokyonight theme |
| `<Space>w` | Save |

`nvim-treesitter` is pinned to its **`main`** branch and needs the
`tree-sitter-cli` package to build parsers — the old
`require("nvim-treesitter.configs")` API no longer exists.

## Desktop: stock KDE, on purpose

Window management is KWin's job. Plasma already ships the launcher, compositor,
notifications, screen locker, tray and screenshots, so there is nothing here to
bolt on — no module installs a window manager or changes the SDDM session.
Tiling, shortcuts and panels are configured in KDE System Settings (Plasma has
its own tiling via `Meta+T` and custom KWin shortcuts).

## Prerequisites

An Arch-based distro with `pacman` and `sudo`. An AUR helper is **not** required —
`yay` is bootstrapped automatically when needed.

## License

MIT — see `LICENSE`.
