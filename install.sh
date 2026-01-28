#!/bin/bash

# SSH Plus Manager Installation Script
# This script installs and configures the SSH Plus Manager system

# GitHub repository URL
# This is the base URL for downloading files from the repository
_REPO_URL="https://raw.githubusercontent.com/namnamir/SSH-Plus-Manager/main"

# Version shown in installer (try local file, else fetch from repo)
_SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
INSTALL_VERSION=""
[[ -f "$_SCRIPT_DIR/version" ]] && INSTALL_VERSION=$(head -1 "$_SCRIPT_DIR/version" 2>/dev/null | tr -d '\r\n')
[[ -z "$INSTALL_VERSION" ]] && INSTALL_VERSION=$(wget -qO- --timeout=3 "$_REPO_URL/version" 2>/dev/null | head -1 | tr -d '\r\n')
[[ -z "$INSTALL_VERSION" ]] && INSTALL_VERSION="?"

# Load color utility functions
# Try to source from local file first (if running from repo)
# Otherwise download from repo and source it
if [[ -f "$(dirname "$0")/Modules/colors" ]]; then
    source "$(dirname "$0")/Modules/colors"
elif [[ -f "/etc/SSHPlus/colors" ]]; then
    source /etc/SSHPlus/colors
elif [[ -f "/bin/colors" ]]; then
    source /bin/colors
else
    # Download colors file from repo and source it
    # This handles the case when install.sh is run via: bash <(curl ...)
    _tmp_colors="/tmp/sshplus_colors_$$"
    if wget -q "$_REPO_URL/Modules/colors" -O "$_tmp_colors" 2>/dev/null; then
        source "$_tmp_colors"
        rm -f "$_tmp_colors" 2>/dev/null
    else
        # If download fails, define minimal fallback (new API names)
        color_echo() { echo -e "\033[1;37m$1\033[0m"; }
        color_echo_n() { echo -ne "\033[1;37m$1\033[0m"; }
        msg_err()  { echo -e "\033[1;31m✖ $1\033[0m"; }
        msg_ok()   { echo -e "\033[1;32m✔ $1\033[0m"; }
        msg_warn() { echo -e "\033[1;33m⚠ $1\033[0m"; }
        msg_info() { echo -e "\033[1;36mℹ $1\033[0m"; }
        menu_option() { echo -e "\033[1;31m[\033[1;36m$1\033[1;31m] \033[1;33m$2\033[0m"; }
        get_color_code() {
            case "$1" in
                red) echo -n "\033[1;31m" ;;
                green) echo -n "\033[1;32m" ;;
                yellow) echo -n "\033[1;33m" ;;
                blue) echo -n "\033[1;34m" ;;
                cyan) echo -n "\033[1;36m" ;;
                white) echo -n "\033[1;37m" ;;
                *) echo -n "\033[1;37m" ;;
            esac
        }
        get_reset_code() { echo -n "\033[0m"; }
        banner_info()   { echo -e "\033[44;1;37m $1 \033[0m"; }
        banner_danger() { echo -e "\033[41;1;37m $1 \033[0m"; }
    fi
fi

# Check if script is running as root user
# Root privileges are required to install system packages and modify system files
if [[ "$(whoami)" != "root" ]]; then
    msg_err "This script must be run as root."
    rm "$HOME/Plus" > /dev/null 2>&1
    exit 1
fi

# Set up directory paths for installation files
# These paths are used to store downloaded files and scripts
_lnk=$(echo 'z1:y#x.5s0ul&p4hs$s.0a72d*n-e!v89e032:3r' | sed -e 's/[^a-z.]//ig' | rev)
_Ink=$(echo '/3×u3#s87r/l32o4×c1a×l1/83×l24×i0b×' | sed -e 's/[^a-z/]//ig')
_1nk=$(echo '/3×u3#s×87r/83×l2×4×i0b×' | sed -e 's/[^a-z/]//ig')

# Change to user's home directory
cd "$HOME" || exit 1

# Function to show a progress bar while commands are running
# This makes the installation look more professional with visual feedback
fun_bar() {
    # Store the two commands to run in an array
    command[0]="$1"
    command[1]="$2"

    # Run the commands in the background
    (
        # Remove any existing finish marker file
        [[ -e "$HOME/fim" ]] && rm "$HOME/fim"

        # Execute the first command (usually a function)
        ${command[0]} -y > /dev/null 2>&1

        # Execute the second command (usually a sleep or another function)
        ${command[1]} -y > /dev/null 2>&1

        # Create a marker file to signal completion
        touch "$HOME/fim"
    ) > /dev/null 2>&1 &

    # Hide the cursor for cleaner display
    tput civis

    # Use color functions for progress bar
    yellow_code=$(get_color_code "yellow")
    red_code=$(get_color_code "red")
    white_code=$(get_color_code "white")
    green_code=$(get_color_code "green")
    reset_code=$(get_reset_code)

    # Show the progress bar label
    echo -ne "  ${yellow_code}Please wait ${white_code}- ${yellow_code}["

    # Keep showing progress until the command finishes
    while true; do
        # Draw 18 hash symbols to show progress
        for ((i=0; i<18; i++)); do
            echo -ne "${red_code}#"
            sleep 0.1s
        done

        # Check if the command finished by looking for the marker file
        if [[ -e "$HOME/fim" ]]; then
            rm "$HOME/fim"
            break
        fi

        # Move cursor up one line and delete it, then redraw the progress bar
        echo -e "${yellow_code}]"
        sleep 1s
        tput cuu1
        tput dl1
        echo -ne "  ${yellow_code}Please wait ${white_code}- ${yellow_code}["
    done

    # Show completion message and restore cursor
    echo -e "${yellow_code}]${white_code} -${green_code} Done.${white_code}${reset_code}"
    tput cnorm
}

# Function to verify that the downloaded key file exists
# This checks if the installation key was successfully downloaded
function verif_key() {
    # Make the list file executable if it exists
    chmod +x "$_Ink/list" > /dev/null 2>&1

    # Check if the key file exists
    if [[ ! -e "$_Ink/list" ]]; then
        echo ""
        msg_err "Invalid or missing installation key."
        rm -rf "$HOME/Plus" > /dev/null 2>&1
        sleep 2
        clear
        exit 1
    fi
}
# Display logo and welcome banner
cyan_code=$(get_color_code "cyan")
blue_code=$(get_color_code "blue")
green_code=$(get_color_code "green")
yellow_code=$(get_color_code "yellow")
red_code=$(get_color_code "red")
reset_code=$(get_reset_code)

# Display ASCII logo
echo ""
echo -e "${cyan_code}                                                                       ${reset_code}"
echo -e "${cyan_code} _____ _____ _____    _____ _            _____                         ${reset_code}"
echo -e "${cyan_code}|   __|   __|  |  |  |  _  | |_ _ ___   |     |___ ___ ___ ___ ___ ___ ${reset_code}"
echo -e "${cyan_code}|__   |__   |     |  |   __| | | |_ -|  | | | | .'|   | .'| . | -_|  _|${reset_code}"
echo -e "${cyan_code}|_____|_____|__|__|  |__|  |_|___|___|  |_|_|_|__,|_|_|__,|_  |___|_|  ${reset_code}"
echo -e "${cyan_code}                                                          |___|        ${reset_code}"
echo ""

red_code=$(get_color_code "red")
reset_code=$(get_reset_code)
echo -e "${red_code}═══════════════════════════════════════════════════════════════════════${reset_code}"
banner_info "                SSH Plus Manager v${INSTALL_VERSION}                   "
echo -e "${red_code}═══════════════════════════════════════════════════════════════════════${reset_code}"
color_echo "  SSH Plus Manager provides network, system and user management tools." "yellow"
color_echo "  For best display, use a terminal with dark theme." "cyan"
echo ""

# Fix SSH port configuration if it was changed
# Change port 22222 back to standard port 22
sed -i 's/Port 22222/Port 22/g' /etc/ssh/sshd_config > /dev/null 2>&1

# Restart SSH service to apply changes
# Use systemctl if available, otherwise fall back to service command
if command -v systemctl > /dev/null 2>&1; then
    systemctl restart ssh > /dev/null 2>&1 || systemctl restart sshd > /dev/null 2>&1
else
    service ssh restart > /dev/null 2>&1
fi

# Download and verify the installation key file
mkdir -p "$_Ink" > /dev/null 2>&1
rm "$_Ink/list" > /dev/null 2>&1

if ! wget -P "$_Ink" "$_REPO_URL/Install/list" > /dev/null 2>&1; then
    if ! curl -sL "$_REPO_URL/Install/list" -o "$_Ink/list" > /dev/null 2>&1; then
        msg_err "Failed to download installation key."
        msg_warn "Check your internet connection and try again."
        exit 1
    fi
fi

if [[ ! -s "$_Ink/list" ]]; then
    msg_err "Downloaded key file is empty or invalid."
    exit 1
fi

verif_key

# Create a shortcut command 'h' that runs the menu
echo "/bin/menu" > /bin/h
chmod +x /bin/h > /dev/null 2>&1

# Download the version file and persist it for update checks
_ver_tmp="/tmp/sshplus_version_$$"
_ver_value=""
if wget -qO- --timeout=5 "$_REPO_URL/version" 2>/dev/null | head -1 | tr -d '\r\n' > "$_ver_tmp"; then
	[[ -s "$_ver_tmp" ]] && _ver_value=$(cat "$_ver_tmp")
fi
[[ -z "$_ver_value" ]] && curl -sfL --max-time 5 "$_REPO_URL/version" 2>/dev/null | head -1 | tr -d '\r\n' > "$_ver_tmp"
[[ -s "$_ver_tmp" ]] && _ver_value=$(cat "$_ver_tmp")
rm -f "$_ver_tmp" 2>/dev/null
if [[ -n "$_ver_value" ]]; then
	mkdir -p /etc/SSHPlus
	echo "$_ver_value" > /etc/SSHPlus/version 2>/dev/null
	echo "$_ver_value" > /bin/version 2>/dev/null
else
	msg_warn "Could not fetch version file; update checks may be limited."
fi

_ip_val=""
_ip_val=$(wget -qO- --timeout=5 ipv4.icanhazip.com 2>/dev/null)
[[ -z "$_ip_val" ]] && _ip_val=$(curl -sfL --max-time 5 ipv4.icanhazip.com 2>/dev/null)
[[ -n "$_ip_val" ]] && echo "$_ip_val" > /etc/IP 2>/dev/null

msg_ok "Key verified."

# Check if user database already exists
if [[ -f "$HOME/users.db" ]]; then
    blue_code=$(get_color_code "blue")
    reset_code=$(get_reset_code)
    echo ""
    echo -e "${blue_code}═══════════════════════════════════════════════════════════════════════${reset_code}"
    color_echo "An existing user database (users.db) was found." "yellow"
    color_echo "Keep it and preserve connection limits, or create a new one?" "yellow"
    menu_option "1" "Keep current database" "red" "yellow"
    menu_option "2" "Create new database" "red" "yellow"
    echo -e "${blue_code}═══════════════════════════════════════════════════════════════════════${reset_code}"
    color_echo_n "Choice [1-2]: " "green"
    read -r -e -i 1 optiondb
else
    # No existing database, create a new one
    # Extract all users with UID >= 500 (regular users) from /etc/passwd
    # Format: username connection_limit (default is 1)
    awk -F : '$3 >= 500 { print $1 " 1" }' /etc/passwd | grep -v '^nobody' > "$HOME/users.db"
fi

# If user chose option 2, create a new database
if [[ "$optiondb" = '2' ]]; then
    awk -F : '$3 >= 500 { print $1 " 1" }' /etc/passwd | grep -v '^nobody' > "$HOME/users.db"
fi
# Start system update process
banner_info " Installing "
color_echo "Updating system packages..." "green"
echo ""

# Function to update system package lists
fun_attlist() {
    # Update package list from repositories
    apt-get update -y

    # Create installation directory if it doesn't exist
    if [[ ! -d /usr/share/.plus ]]; then
        mkdir -p /usr/share/.plus
    fi

    # Save installation timestamp
    echo "crz: $(date)" > /usr/share/.plus/.plus
}

fun_bar 'fun_attlist'
echo ""
color_echo "Installing dependencies..." "green"

# ------------------------------------------------------------------------------
# DEPENDENCIES – all tools required by SSH Plus Manager (install + menu + modules)
# ------------------------------------------------------------------------------
#  wget          – download files, version, IP; used by install.sh, Install/list, menu
#  curl          – fallback download; IP/version fetch; used by install, menu, speedtest
#  bc            – calculator in scripts (e.g. traffic/stats)
#  screen        – run proxy.py, open.py, autostart; used by connections, Install/list
#  nano          – edit hosts, openvpn config; used by createuser, connections
#  unzip         – extract archives; used by Install/list and other modules
#  zip           – create OVPN zip bundles; used by createuser
#  lsof          – list open files / connections; used by monitoring
#  net-tools     – provides netstat; used by sshmonitor, connections, Install/list
#  dos2unix      – fix line endings in scripts
#  nload         – [11] VPS TRAFFIC in menu
#  jq            – JSON; used by Install/list and any JSON config
#  figlet        – ASCII art / banners
#  python3       – run open.py, proxy.py, speedtest-cli
#  python3-pip   – install speedtest-cli (pip package)
#  speedtest-cli – [09] SPEEDTEST in menu; apt if available, else pip
# ------------------------------------------------------------------------------

inst_pct() {
    local _pkg _missing=() _m
    local _packages=(
        wget
        curl
        bc
        screen
        nano
        unzip
        zip
        lsof
        net-tools
        dos2unix
        nload
        jq
        figlet
        python3
        python3-pip
        speedtest-cli
    )

    for _pkg in "${_packages[@]}"; do
        if ! apt install -y "$_pkg" >/dev/null 2>&1; then
            _missing+=("$_pkg")
        fi
    done

    # speedtest-cli: if apt failed, try pip (many distros only have it via pip)
    if ! command -v speedtest-cli >/dev/null 2>&1; then
        python3 -m pip install speedtest-cli >/dev/null 2>&1 || pip3 install speedtest-cli >/dev/null 2>&1 || true
        if command -v speedtest-cli >/dev/null 2>&1; then
            # remove from _missing so we don't report it as failed
            _m=()
            for _pkg in "${_missing[@]}"; do
                [[ "$_pkg" != "speedtest-cli" ]] && _m+=("$_pkg")
            done
            _missing=("${_m[@]}")
        fi
    fi

    if [[ ${#_missing[@]} -gt 0 ]]; then
        echo "" >&2
        msg_warn "Could not install: ${_missing[*]}"
        msg_warn "Install manually: apt install -y ${_missing[*]}"
        echo "" >&2
    fi

    if ! command -v speedtest-cli >/dev/null 2>&1; then
        msg_warn "speedtest-cli is missing. Install later with: pip3 install speedtest-cli"
    fi
}

fun_bar 'inst_pct'

if [[ -f "/usr/sbin/ufw" ]]; then
    ufw allow 443/tcp > /dev/null 2>&1
    ufw allow 80/tcp > /dev/null 2>&1
    ufw allow 3128/tcp > /dev/null 2>&1
    ufw allow 8799/tcp > /dev/null 2>&1
    ufw allow 8080/tcp > /dev/null 2>&1
fi
echo ""
color_echo "Finalizing installation..." "green"

fun_bar "$_Ink/list $_lnk $_Ink $_1nk $key"

[[ -d /etc/SSHPlus ]] || mkdir -p /etc/SSHPlus
if [[ -s /bin/version ]]; then
	cp /bin/version /etc/SSHPlus/version 2>/dev/null
elif [[ -s /etc/SSHPlus/version ]]; then
	cp /etc/SSHPlus/version /bin/version 2>/dev/null
fi

cd "$HOME" || exit 1

echo ""
msg_ok "Installation completed successfully."
if [[ -f "/bin/menu" ]] && [[ -x "/bin/menu" ]]; then
    color_echo "  Run: menu" "yellow"
else
    msg_err "Menu was not installed correctly. Try: /bin/menu"
fi

# Clean up: remove installation script and clear bash history
# This is done for security to remove traces of the installation
rm "$HOME/Plus" > /dev/null 2>&1
cat /dev/null > ~/.bash_history
history -c
