#!/bin/bash

# SSH Plus Manager Installation Script
# This script installs and configures the SSH Plus Manager system

# GitHub repository URL
# This is the base URL for downloading files from the repository
_REPO_URL="https://raw.githubusercontent.com/namnamir/SSH-Plus-Manager/main"

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
        # If download fails, define minimal fallback functions
        color_echo() { echo -e "\033[1;37m$1\033[0m"; }
        color_echo_n() { echo -ne "\033[1;37m$1\033[0m"; }
        error_msg() { echo -e "\033[1;31m$1\033[0m"; }
        success_msg() { echo -e "\033[1;32m$1\033[0m"; }
        warning_msg() { echo -e "\033[1;33m$1\033[0m"; }
        info_msg() { echo -e "\033[1;36m$1\033[0m"; }
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
        print_header() {
            tput setab 4 2>/dev/null
            tput bold 2>/dev/null
            echo -e "\033[44;1;37m$1\033[0m"
            tput sgr0 2>/dev/null
        }
        print_header_red() {
            tput setab 1 2>/dev/null
            tput bold 2>/dev/null
            echo -e "\033[41;1;37m$1\033[0m"
            tput sgr0 2>/dev/null
        }
    fi
fi

# Clear the screen for a clean start
clear

# Check if script is running as root user
# Root privileges are required to install system packages and modify system files
if [[ "$(whoami)" != "root" ]]; then
    color_echo_n "[" "yellow"
    color_echo_n "Error" "red"
    color_echo_n "] " "yellow"
    color_echo_n "- " "white"
    color_echo "you need to run as root" "yellow"
    rm "$HOME/Plus" > /dev/null 2>&1
    exit 0
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
    echo -ne "  ${yellow_code}WAIT ${white_code}- ${yellow_code}["

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
        echo -ne "  ${yellow_code}WAIT ${white_code}- ${yellow_code}["
    done

    # Show completion message and restore cursor
    echo -e "${yellow_code}]${white_code} -${green_code} OK !${white_code}${reset_code}"
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
        error_msg "INVALID KEY!"
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
echo -e "${red_code}════════════════════════════════════════════════════${reset_code}"
print_header "               WELCOME TO SSHPLUS MANAGER"
echo -e "${red_code}════════════════════════════════════════════════════${reset_code}"
echo ""
color_echo_n "• " "red"
color_echo "THIS SCRIPT IS SET AS TOOLS FOR" "yellow"
color_echo "  NETWORK, SYSTEM AND USER MANAGEMENT" "yellow"
echo ""
color_echo_n "• " "green"
color_echo "UTILIZE THE DARK THEME IN YOUR TERMINAL" "yellow"
color_echo "  TO A BETTER EXPERIENCE AND VISUALIZATION!" "yellow"
echo ""
color_echo_n "≠×≠×≠×[" "red"
color_echo_n " • " "yellow"
color_echo_n "   a new version of SSH PLUS MANAGER   " "green"
color_echo_n " •" "yellow"
color_echo "]≠×≠×≠×" "red"
echo ""

# Ask user if they want to generate/verify the installation key
color_echo_n "GENERATE KEY [Y/N]: " "cyan"
read -r x

# Exit if user chooses not to proceed
if [[ "$x" = @(n|N) ]]; then
    exit 0
fi

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
echo ""
color_echo_n "CHECKING... " "cyan"
color_echo " 16983:16085" "white"

# Ensure the directory exists
mkdir -p "$_Ink" > /dev/null 2>&1

# Remove old file if it exists
rm "$_Ink/list" > /dev/null 2>&1

# Download the key file from GitHub repository
# Try downloading with wget
if ! wget -P "$_Ink" "$_REPO_URL/Install/list" > /dev/null 2>&1; then
    # Try with curl as fallback
    if ! curl -sL "$_REPO_URL/Install/list" -o "$_Ink/list" > /dev/null 2>&1; then
        echo ""
        error_msg "ERROR: Failed to download key file!"
        warning_msg "Please check your internet connection and try again."
        warning_msg "URL: $_REPO_URL/Install/list"
        exit 1
    fi
fi

# Verify the file was downloaded and is not empty
if [[ ! -s "$_Ink/list" ]]; then
    echo ""
    error_msg "ERROR: Downloaded file is empty or invalid!"
    exit 1
fi

# Verify the file was downloaded and is not empty
if [[ ! -s "$_Ink/list" ]]; then
    echo ""
    error_msg "ERROR: Downloaded file is empty or invalid!"
    exit 1
fi

# Verify the downloaded key file
verif_key

# Wait a moment for file operations to complete
sleep 3s

# Create a shortcut command 'h' that runs the menu
echo "/bin/menu" > /bin/h
chmod +x /bin/h > /dev/null 2>&1

# Download the version file to check for updates
rm version* > /dev/null 2>&1
if ! wget "$_REPO_URL/version" > /dev/null 2>&1; then
    echo ""
    warning_msg "WARNING: Could not download version file"
fi
# Key verification successful
echo ""
success_msg "KEY OK!"
sleep 1s
echo ""

# Check if user database already exists
# If it exists, ask user if they want to keep it or create a new one
if [[ -f "$HOME/users.db" ]]; then
    clear
    blue_code=$(get_color_code "blue")
    reset_code=$(get_reset_code)
    echo ""
    echo -e "${blue_code}═════════════════════════════════════════════════${reset_code}"
    echo ""
    color_echo_n "                 • " "yellow"
    color_echo_n "ATTENTION " "red"
    color_echo " •" "yellow"
    echo ""
    color_echo_n "A User Database " "yellow"
    color_echo_n "(users.db) " "green"
    color_echo "Was" "yellow"
    color_echo "Found! Do you want to keep it preserving the limit" "yellow"
    color_echo "of users' Simultaneous Connections? Or Do You Want to" "yellow"
    color_echo "create a new database ?" "yellow"
    echo ""
    menu_option "1" "Keep Current Database" "red" "yellow"
    menu_option "2" "Create a New Database" "red" "yellow"
    echo ""
    echo -e "${blue_code}═════════════════════════════════════════════════${reset_code}"
    echo ""
    color_echo_n "Option ?: " "green"
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
clear
print_header " WAITING FOR INSTALLATION"
echo ""
echo ""
color_echo_n "          [" "yellow"
color_echo_n "!" "red"
color_echo_n "] " "yellow"
color_echo_n "UPDATING SYSTEM " "green"
color_echo_n "[" "yellow"
color_echo_n "!" "red"
color_echo "] " "yellow"
echo ""
color_echo "        UPDATES TAKE A LITTLE TIME!" "yellow"
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

# Run system update with progress bar
fun_bar 'fun_attlist'

clear
echo ""
color_echo_n "          [" "yellow"
color_echo_n "!" "red"
color_echo_n "] " "yellow"
color_echo_n "INSTALLING PACKAGES " "green"
color_echo_n "[" "yellow"
color_echo_n "!" "red"
color_echo "] " "yellow"
echo ""
color_echo "  SOME PACKAGES ARE NECESSARY TO INSTALL !" "yellow"
echo ""

# Function to install required packages
inst_pct() {
    # List of required packages for the SSH Plus Manager
    # bc: calculator for scripts
    # screen: terminal multiplexer for background processes
    # nano: text editor
    # unzip: extract zip files
    # lsof: list open files (for monitoring connections)
    # netstat: network statistics (deprecated but still used)
    # net-tools: network utilities (includes netstat)
    # dos2unix: convert Windows line endings to Unix
    # nload: network traffic monitor
    # jq: JSON processor
    # curl: download files from internet
    # figlet: ASCII art text generator
    # python3: Python programming language
    # python3-pip: Python package installer (fixed from python-pip)
    _packages=("bc" "screen" "nano" "unzip" "lsof" "netstat" "net-tools" "dos2unix" "nload" "jq" "curl" "figlet" "python3" "python3-pip")

    # Install each package in the list
    # BUG FIX: Changed _pacotes to _packages (was causing silent failure)
    for _prog in "${_packages[@]}"; do
        apt install "$_prog" -y > /dev/null 2>&1
    done

    # Install speedtest-cli using pip for network speed testing
    # Use pip3 explicitly for Python 3
    pip3 install speedtest-cli > /dev/null 2>&1 || python3 -m pip install speedtest-cli > /dev/null 2>&1
}

# Run package installation with progress bar
fun_bar 'inst_pct'

# Configure firewall rules if UFW (Uncomplicated Firewall) is installed
# Allow common ports for SSH, HTTP, HTTPS, and proxy services
if [[ -f "/usr/sbin/ufw" ]]; then
    ufw allow 443/tcp > /dev/null 2>&1  # HTTPS
    ufw allow 80/tcp > /dev/null 2>&1   # HTTP
    ufw allow 3128/tcp > /dev/null 2>&1 # Squid proxy
    ufw allow 8799/tcp > /dev/null 2>&1 # Custom port
    ufw allow 8080/tcp > /dev/null 2>&1 # Alternative HTTP port
fi

clear
echo ""
color_echo_n "              [" "yellow"
color_echo_n "!" "red"
color_echo_n "] " "yellow"
color_echo_n "FINALIZING " "green"
color_echo_n "[" "yellow"
color_echo_n "!" "red"
color_echo "] " "yellow"
echo ""
color_echo "    COMPLETING FUNCTIONS AND DEFINITIONS! " "yellow"
echo ""

# Run the main installation script that sets up all modules
# This script downloads and installs all the manager modules
fun_bar "$_Ink/list $_lnk $_Ink $_1nk $key"

clear
echo ""
cd "$HOME" || exit 1

# Installation complete message
color_echo_n "        • " "yellow"
color_echo_n "INSTALLATION COMPLETED" "green"
color_echo " •" "yellow"
echo ""
color_echo_n " MAIN COMMAND: " "red"
color_echo "menu" "green"

# Clean up: remove installation script and clear bash history
# This is done for security to remove traces of the installation
rm "$HOME/Plus" > /dev/null 2>&1
cat /dev/null > ~/.bash_history
history -c
