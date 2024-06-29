#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install dependencies
install_dependencies() {
    echo "Checking and installing necessary dependencies..."
    sleep 2

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
            sleep 2
        fi
    done

    echo "All necessary dependencies are installed."
    sleep 2
}

# Function to download and setup the main script
setup_king_script() {
    echo "Downloading the main script from GitHub..."
    sleep 2
    wget -O /root/KingTunnel_V3.sh https://raw.githubusercontent.com/lordvexer/KingTunnel/main/KingTunnel_V3.sh
    chmod +x /root/KingTunnel_V3.sh
    echo "alias king='/root/KingTunnel_V3.sh'" >>~/.bashrc
    source ~/.bashrc

}

# Main script execution
install_dependencies
setup_king_script

echo "Installation completed.Reboot in 10 secend"
sleep 2
echo "Run Menu With "king" Command"
sleep 8
sudo systemctl reboot
