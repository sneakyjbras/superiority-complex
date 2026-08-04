# Superiority Complex — Manjaro/Arch dotfiles

A one-command bootstrap for a fresh **Arch-based** (Manjaro) machine. Clone it,
run one script, and get your packages, Zsh, terminal AI CLIs, Neovim, Konsole
themes and an **i3** desktop set up. Every step is **idempotent** (safe to
re-run) and **resilient** (a single failing step won't abort the whole install —
you get a summary at the end).

## The stack

The whole point is that there isn't much of it. One window manager, one
terminal, one editor, two AI CLIs:

| Layer | What | Notes |
| ----- | ---- | ----- |
| **Desktop** | **i3** (default) | Tiling, keyboard-driven, X11. `config/i3/config`. |
| | **KDE Plasma** (fallback) | Left installed on purpose — pick it at the SDDM login screen if i3 misbehaves. |
| | SDDM | Login screen; pre-selects i3 via AccountsService. |
| **Terminal** | **Konsole** + **Zsh** | KDE's terminal, kept even under i3. Manjaro zsh config + syntax highlighting + autosuggestions. |
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
| `modules/60-i3.sh` | i3 + launcher/compositor/notifications/lock, **symlinks** `config/i3/config` and `config/i3status/config`, and makes i3 the default SDDM session. |

## Layout

```
install.sh            # single entry point / orchestrator
setup.sh              # back-compat shim -> install.sh
lib/common.sh         # logging, idempotent helpers, module runner + summary
config/
  packages.sh         # EDIT ME: all package lists (pacman groups, AUR, nvim, i3)
  nvim/init.lua       # EDIT ME: Neovim config (symlinked to ~/.config/nvim)
  claude/             # Claude Code settings.json + CLAUDE.md (symlinked to ~/.claude)
  i3/config           # EDIT ME: i3 config (symlinked to ~/.config/i3)
  i3status/config     # i3 status line
modules/*.sh          # one self-contained step each (also runnable standalone)
konsole/              # Konsole theme assets
```

## Customizing

- **Packages** — edit `config/packages.sh`. It's data only: `PACMAN_GROUPS`,
  `AUR_PKGS`, `NVIM_PKGS`, `I3_PKGS`.
- **Neovim** — edit `config/nvim/init.lua` directly. It's symlinked into
  `~/.config/nvim`, so changes apply immediately and stay tracked in git.
- **i3** — edit `config/i3/config`; reload in place with `$mod+Shift+r`.
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

## i3 desktop

`modules/60-i3.sh` installs i3 and makes it the session SDDM pre-selects.
**Plasma stays installed** — pick it at the login screen to fall back. Note that
i3 is X11-only, so this moves the session off Wayland.

Modifier is **Super** (`$mod`). Highlights:

| Key | Action |
| --- | ------ |
| `$mod+Return` | Konsole |
| `$mod+d` / `$mod+Tab` | rofi launcher / window switcher |
| `$mod+q` | Close window |
| `$mod+h/j/k/l` | Focus (add `Shift` to move) |
| `$mod+b` / `$mod+v` | Split horizontal / vertical |
| `$mod+f` | Fullscreen |
| `$mod+1..0` | Workspace (add `Shift` to move window there) |
| `$mod+r` | Resize mode |
| `Print` / `$mod+Print` | Screenshot screen / region → clipboard |
| `$mod+Shift+x` | Lock |
| `$mod+Shift+r` / `$mod+Shift+c` | Restart / reload i3 |
| `$mod+Shift+e` | Exit i3 |

## Prerequisites

An Arch-based distro with `pacman` and `sudo`. An AUR helper is **not** required —
`yay` is bootstrapped automatically when needed.

## License

MIT — see `LICENSE`.
