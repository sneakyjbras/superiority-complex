## Arch/Manjaro Zsh Setup Script

This repository contains a **Zsh** setup script tailored for **Arch-based** distributions (including Manjaro). It automates:

* Zsh configuration (aliases, prompt, syntax highlighting, autosuggestions)
* SSH agent initialization
* Installation of common packages via `pacman` and AUR helpers (`yay`/`paru`)

### Prerequisites

* An **Arch-based** Linux distribution
* `zsh` installed
* AUR helper (`yay` or `paru`) for AUR packages (optional)

### Usage

1. Clone or download this repository.
2. Make the script executable:

   ```bash
   chmod +x run.sh
   ```
3. Run the script:

   ```bash
   ./run.sh
   ```
4. Follow any prompts (e.g., package installation confirmation, SSH key path).

### Customization

* Edit `run.sh` to add or remove packages in the **package groups** section.
* Modify `apply_zsh_configs_prompt()` to adjust aliases, prompt style, or plugins.

### License

This script is provided under the MIT License. Feel free to adapt and redistribute!

