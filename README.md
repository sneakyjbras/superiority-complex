
# Environment Setup Script

![License](https://img.shields.io/badge/License-MIT-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Linux-blue.svg)
![Shell](https://img.shields.io/badge/Shell-Bash-blue.svg)

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Supported Distributions](#supported-distributions)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Included Tools and Applications](#included-tools-and-applications)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Introduction

This repository contains a comprehensive Bash script designed to automate the setup of a development environment on Linux systems. The script is tailored to work seamlessly with both Arch-based and Debian-based distributions. It installs essential development tools, configures system settings, and enhances the user experience for developers.

## Features

- **Essential Tools Installation**: Installs development tools such as `git`, `vim`, `curl`, `gcc`, and more.
- **IDE and Editor Support**: Installs popular IDEs including Visual Studio Code, IntelliJ IDEA, and PyCharm.
- **Vim Configuration**: Sets up `vim-plug` and configures Vim with a modern, customizable layout.
- **Terminal Enhancements**: Adds useful aliases, custom prompts, and applies the Dracula theme to the Konsole terminal.
- **API and Networking Tools**: Installs HTTPie and Postman (if an AUR helper is available).
- **Customization Options**: Users can select which tools to install and skip optional configurations.

## Supported Distributions

- **Arch-based distributions**: Manjaro, Arch Linux, etc.

## Prerequisites

- **Superuser Privileges**: Ensure you have `sudo` access to install packages.
- **AUR Helper**: For Arch-based systems, it's recommended to have `yay` or `paru` for AUR package installations.

## Installation

1. **Clone the Repository**:

    ```bash
    git clone https://github.com/yourusername/environment-setup-script.git
    cd environment-setup-script
    ```

2. **Run the Script**:

    ```bash
    chmod +x setup.sh
    ./setup.sh
    ```

## Usage

- The script will prompt for confirmation before installing missing tools and configuring optional components.
- Git configuration, Vim setup, and SSH agent configuration will be interactively set up during the script's execution.

## Configuration

The script configures the following:

- **Vim**: Sets up `vim-plug` and installs specified plugins.
- **Bash**: Adds aliases and sets a custom PS1 prompt in `.bashrc`.
- **SSH Agent**: Adds SSH key management to `.bashrc` if desired.

## Included Tools and Applications

### Core Utilities
- `ssh`, `curl`, `git`, `vim`, `python3`, `valgrind`

### Compilers
- `gcc`, `default-jdk` (Debian), `jdk-openjdk` (Arch)

### Development Tools
- `docker`, `virtualenv`, Visual Studio Code, IntelliJ IDEA, PyCharm

### Terminal Tools
- `tmux`, `htop`

### Search and Fuzzy Find Tools
- `ripgrep`, `fzf`, `screenfetch`

### Entertainment
- `spotify`

### Browsers and Conferencing Tools
- Google Chrome, Zoom

## Customization

You can customize the script by editing the list of tools and applications defined in the script's arrays:

```bash
CORE_UTILS=(ssh curl git vim python3 valgrind)
DEV_UTILS=(docker python3-venv code)
```
Comment out or remove any tools you don't want to install.

## Troubleshooting

- Ensure your system's package manager is up-to-date before running the script.
- If an AUR helper is not found, certain packages will be skipped. Install `yay` or `paru` to enable AUR support.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request if you have suggestions or improvements.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
