#!/bin/zsh

# Exit immediately if a command exits with a non-zero status.
set -e

###############################################################################
# Utility functions
###############################################################################

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

###############################################################################
# Ensure we are running on an Arch-based distribution (pacman must be present)
###############################################################################
if ! command_exists pacman; then
    echo "Unsupported system. This setup script is intended for Arch-based distributions (pacman)."
    exit 1
fi

###############################################################################
# Zsh configuration helpers
###############################################################################

CONFIG_FILE="$HOME/.zshrc"
echo "Using configuration file: $CONFIG_FILE"

# Append content to the config file if it does not already exist
add_to_config() {
    local content="$1"
    local description="$2"
    if ! grep -qF "$content" "$CONFIG_FILE"; then
        echo "$content" | tee -a "$CONFIG_FILE" >/dev/null
        echo "$description added to $CONFIG_FILE."
    else
        echo "$description already exists in $CONFIG_FILE."
    fi
}

# Detect Manjaro
is_manjaro() {
    [[ -f /etc/manjaro-release ]]
}

# Apply Zsh colours, prompt and plugins
apply_zsh_configs_prompt() {
    if is_manjaro; then
        echo "Detected Manjaro system. Applying Manjaro-specific Zsh configurations..."
        add_to_config 'source /usr/share/zsh/manjaro-zsh-config' "Manjaro Zsh configuration"
        add_to_config 'source /usr/share/zsh/manjaro-zsh-prompt' "Manjaro Zsh prompt"
        add_to_config 'source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' "Zsh Syntax Highlighting Plugin"
        add_to_config 'source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' "Zsh Autosuggestions Plugin"
    else
        echo "Adding colour aliases..."
        add_to_config "alias ls='ls --color=auto'" "Colour alias for ls"
        add_to_config "alias grep='grep --color=auto'" "Colour alias for grep"
        add_to_config "alias egrep='egrep --color=auto'" "Colour alias for egrep"
        add_to_config "alias fgrep='fgrep --color=auto'" "Colour alias for fgrep"
        add_to_config "alias diff='diff --color=auto'" "Colour alias for diff"
        add_to_config "alias tail='tail --color=always'" "Colour alias for tail"
        add_to_config "alias dmesg='dmesg --color=always'" "Colour alias for dmesg"

        # Custom prompt
        add_to_config 'export PS1="%F{green}%n@%m %F{blue}%~%f $ "' "Custom PS1 prompt"

        # Rich LS_COLORS
        add_to_config 'export LS_COLORS="di=34:ln=35:so=32:pi=33:ex=31:bd=37;40:cd=37;40:su=37;41:sg=37;46:tw=37;42:ow=37;43"' "LS_COLORS configuration"
    fi
}

###############################################################################
# SSH agent helper
###############################################################################
add_ssh_agent() {
    if ! grep -qF "ssh-agent -s" "$CONFIG_FILE"; then
        printf '\n# Start SSH agent\n' | tee -a "$CONFIG_FILE" >/dev/null
        echo 'eval "$(ssh-agent -s)"' | tee -a "$CONFIG_FILE" >/dev/null
        printf "Enter your SSH key path (default: ~/.ssh/id_rsa): "
        read -r ssh_key
        ssh_key=${ssh_key:-~/.ssh/id_rsa}
        if [ -f "$ssh_key" ]; then
            echo "Adding SSH key to agent..."
            echo "ssh-add $ssh_key" | tee -a "$CONFIG_FILE" >/dev/null
            echo "SSH agent initialisation added to $CONFIG_FILE."
        else
            echo "SSH key not found at $ssh_key. Please generate it with 'ssh-keygen'."
        fi
    else
        echo "SSH agent initialisation already exists in $CONFIG_FILE."
    fi
}

###############################################################################
# Package manager configuration for Arch / Manjaro
###############################################################################
PACKAGE_MANAGER=(pacman "-S" "--noconfirm")
INSTALL_CMD=(sudo pacman -Syu --noconfirm)

# Common package names (pacman / AUR where noted)
VENV_PACKAGE="python-virtualenv"
JDK_PACKAGE="jdk-openjdk"
POSTMAN_PACKAGE="postman-bin"          # AUR
CHROME_PACKAGE="google-chrome"        # AUR
MATTERMOST_PACKAGE="mattermost-desktop"   # AUR
TEAMS_PACKAGE="teams"                 # AUR
SPOTIFY_PACKAGE="spotify"             # AUR
VLC_PACKAGE="vlc"
# No email client
ZOOM_PACKAGE="zoom"                   # AUR
OBSIDIAN_PACKAGE="obsidian"           # AUR
DRACULA_KONSOLE_URL="https://raw.githubusercontent.com/dracula/konsole/master/Dracula.colorscheme"

# Detect an AUR helper
if command_exists yay; then
    AUR_INSTALLER=(yay -S --noconfirm)
elif command_exists paru; then
    AUR_INSTALLER=(paru -S --noconfirm)
else
    echo "No AUR helper found. Please install 'yay' or 'paru' to proceed with AUR packages."
    POSTMAN_PACKAGE=""
    MATTERMOST_PACKAGE=""
    TEAMS_PACKAGE=""
    SPOTIFY_PACKAGE=""
    VLC_PACKAGE=""
    ZOOM_PACKAGE=""
    OBSIDIAN_PACKAGE=""
fi

###############################################################################
# Package groups
###############################################################################
CORE_UTILS=(ssh curl git vim python3 valgrind base-devel)
COMPILERS=(gcc "$JDK_PACKAGE")
DEV_UTILS=(docker "$VENV_PACKAGE")
IDEs=()        # No IDEs wanted
API_TOOLS=(httpie)
[[ -n "$POSTMAN_PACKAGE" ]] && API_TOOLS+=("$POSTMAN_PACKAGE")
ENTERTAINMENT=("$SPOTIFY_PACKAGE" "$VLC_PACKAGE")
EXTRA_APPS=("$MATTERMOST_PACKAGE" "$TEAMS_PACKAGE")
BUILD_TOOLS=(cmake make)
TERMINAL_TOOLS=(tmux htop)
SEARCH_TOOLS=(ripgrep fzf screenfetch)
BROWSERS=()
[[ -n "$CHROME_PACKAGE" ]] && BROWSERS+=("$CHROME_PACKAGE")
EMAIL_CLIENTS=()  # none
VIDEO_CONFERENCING=("$ZOOM_PACKAGE")
NOTES_APPS=("$OBSIDIAN_PACKAGE")

###############################################################################
# Helper to install missing tools
###############################################################################
install_tools() {
    local category="$1"
    shift
    local tools=("$@")

    local missing=()
    local installed_var="INSTALLED_${category}"

    for t in "${tools[@]}"; do
        [[ -z "$t" ]] && continue
        if command_exists "$t"; then
            eval "$installed_var+=(\"$t\")"
        else
            missing+=("$t")
        fi
    done

    if [[ ${#missing[@]} -eq 0 ]]; then
        echo "All $category are already installed."
        return
    fi

    printf "Do you want to install missing $category? (%s): [Y/n] " "${missing[*]}"
    read -r answer
    answer=${answer:-Y}
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        echo "Installing missing $category: ${missing[*]}..."
        if [[ -z "$INSTALL_CMD_RUN" ]]; then
            "${INSTALL_CMD[@]}" || { echo "Failed to update repositories."; return 1; }
            INSTALL_CMD_RUN=true
        fi

        for pkg in "${missing[@]}"; do
            if [[ -n "${AUR_INSTALLER[*]}" && ( "$pkg" == *-bin || "$pkg" == "$CHROME_PACKAGE" || "$pkg" == "$ZOOM_PACKAGE" || "$pkg" == "$SPOTIFY_PACKAGE" || "$pkg" == "$OBSIDIAN_PACKAGE" || "$pkg" == "$POSTMAN_PACKAGE" || "$pkg" == "$VLC_PACKAGE" ) ]]; then
                echo "Installing $pkg from AUR..."
                if ! "${AUR_INSTALLER[@]}" "$pkg"; then
                    echo "Failed to install $pkg from AUR."
                fi
            else
                echo "Installing $pkg..."
                if ! sudo "${PACKAGE_MANAGER[@]}" "$pkg"; then
                    echo "Failed to install $pkg."
                fi
            fi
        done
    else
        echo "Skipping installation of missing $category."
    fi
}

###############################################################################
# Main
###############################################################################
echo "Applying Zsh config and prompt..."
apply_zsh_configs_prompt

echo "Configuring SSH agent..."
add_ssh_agent

# Initialise variable to avoid multiple sudo pacman -Syu
INSTALL_CMD_RUN=""

# Install package groups
install_tools "CORE_UTILS" "${CORE_UTILS[@]}"
install_tools "COMPILERS" "${COMPILERS[@]}"
install_tools "DEV_UTILS" "${DEV_UTILS[@]}"
install_tools "IDEs" "${IDEs[@]}"
install_tools "API_TOOLS" "${API_TOOLS[@]}"
install_tools "BROWSERS" "${BROWSERS[@]}"
install_tools "ENTERTAINMENT" "${ENTERTAINMENT[@]}"
install_tools "EXTRA_APPS" "${EXTRA_APPS[@]}"
install_tools "BUILD_TOOLS" "${BUILD_TOOLS[@]}"
install_tools "TERMINAL_TOOLS" "${TERMINAL_TOOLS[@]}"
install_tools "SEARCH_TOOLS" "${SEARCH_TOOLS[@]}"
install_tools "EMAIL_CLIENTS" "${EMAIL_CLIENTS[@]}"
install_tools "VIDEO_CONFERENCING" "${VIDEO_CONFERENCING[@]}"
install_tools "NOTES_APPS" "${NOTES_APPS[@]}"

echo "Setup complete."

