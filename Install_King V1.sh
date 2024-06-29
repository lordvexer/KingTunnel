#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install dependencies
install_dependencies() {
    echo "Checking and installing necessary dependencies..."

    # List of dependencies
    dependencies=(curl wget unzip git ssh ssh-keygen systemctl tcpdump)

    # Loop through each dependency and install if not present
    for cmd in "${dependencies[@]}"; do
        if ! command_exists "$cmd"; then
            echo "Installing $cmd..."
            sudo apt-get update
            sudo apt-get install -y "$cmd"
        else
            echo "$cmd is already installed."
        fi
    done

    echo "All necessary dependencies are installed."
}

# Function to download and setup the main script
setup_king_script() {
    echo "Downloading the main script from GitHub..."
    wget -O ~/king_script.sh https://github.com/lordvexer/KingTunnel/blob/main/Install_King%20V1/Install_King V1
    chmod +x ~/king_script.sh

    # Create an alias to run the script with the 'king' command
    if ! grep -q "alias king=" ~/.bashrc; then
        echo "alias king='~/king_script.sh'" >> ~/.bashrc
        source ~/.bashrc
    fi

    echo "Setup completed. You can now run the script using the 'king' command."
}

# Main script execution
install_dependencies
setup_king_script

echo "Installation completed. Please restart your terminal or run 'source ~/.bashrc' to use the 'king' command."
