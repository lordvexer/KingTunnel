#!/bin/bash

# Function to display the menu
show_menu() {
    echo "=============================="
    echo "          Main Menu           "
    echo "=============================="
    echo "1. Install Marzban"
    echo "2. Install Shahan"
    echo "3. Install Sanaie"
    echo "4. Install SoftEther (soon)"
    echo "5. Install Tunnel"
    echo "6. Uninstall Tunnel"
    echo "7. Show Status Tunnel"
    echo "8. Show Ports Traffic"
    echo "9. Backup"
    echo "10. Restore"
    echo "11. Exit"
    echo "=============================="
    echo -n "Enter your choice [1-11]: "
}

# Function to install tunnel
install_tunnel() {
    echo "Installing Tunnel..."
    stop 2
    echo "Creating RSA key..."
    stop 2
    ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""

    read -p "Enter Kharej server IP: " kharej_ip
    read -p "Enter number of Iran servers: " num_iran_servers

    declare -a iran_servers
    for ((i = 1; i <= num_iran_servers; i++)); do
        read -p "Enter IP of Iran server $i: " iran_server_ip
        iran_servers+=("$iran_server_ip")
    done

    echo "Kharej server IP: $kharej_ip" > Kharej_server_ips.txt
    echo "Number of Iran servers: $num_iran_servers"
    echo "Iran servers IPs:" >> Iran_server_ips.txt
    for iran_server in "${iran_servers[@]}"; do
        echo "$iran_server" >> servers_ips.txt
    done

    echo "Copying RSA key to Iran servers..."
    for iran_server in "${iran_servers[@]}"; do
        ssh-copy-id -o StrictHostKeyChecking=no "$iran_server"
    done

    echo "Tunnel installation completed."
}

}

# Function to uninstall tunnel
uninstall_tunnel() {
    echo "Uninstalling Tunnel..."
    # Add the commands to uninstall the tunnel here
}

# Function to show tunnel status
show_status_tunnel() {
    echo "Showing Tunnel Status..."
    # Add the commands to show tunnel status here
}

# Function to show ports traffic
show_ports_traffic() {
    echo "Showing Ports Traffic..."
    # Add the commands to show ports traffic here
}

# Function to install Marzban
install_marzban() {
    echo "Installing Marzban..."
    sudo bash -c "$(curl -sL https://github.com/Gozargah/Marzban-scripts/raw/master/marzban.sh)" @ install

    echo "Create user and password for Marzban panel"
    sudo marzban cli create

    echo "Marzban installation and user creation completed."
}

# Function to install Shahan
install_shahan() {
    echo "Installing Shahan..."
    sudo bash <(curl -Ls https://raw.githubusercontent.com/HamedAp/Ssh-User-management/master/install.sh --ipv4)
    echo "Shahan installation completed"
}

# Function to install Sanaie
install_sanaie() {
    echo "Installing Sanaei..."
    sudo bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
    echo "sanaie installation completed"
}

# Function to install SoftEther
install_softether() {
    echo "Installing SoftEther..."
    # Add the commands to install SoftEther here
}

# Function to backup
backup() {
    echo "Backing Up..."
    # Add the commands to backup here
}

# Function to restore
restore() {
    echo "Restoring..."
    # Add the commands to restore here
}

# Function to exit
exit_script() {
    echo "Exiting..."
    exit 0
}

# Main script logic
while true
do
    show_menu
    read choice
    case $choice in
        1) install_marzban ;;
        2) install_shahan ;;
        3) install_sanaie ;;
        4) install_softether ;;
        5) install_tunnel ;;
        6) uninstall_tunnel ;;
        7) show_status_tunnel ;;
        8) show_ports_traffic ;;
        9) backup ;;
        10) restore ;;
        11) exit_script ;;
        *) echo "Invalid choice, please choose again [1-11]";;
    esac
done
