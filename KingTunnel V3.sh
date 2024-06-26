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
    echo "Creating RSA key..."
    ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""

    read -p "Enter Kharej server IP: " kharej_ip
    read -p "Enter number of Iran servers: " num_iran_servers

    declare -a iran_servers
    for ((i = 1; i <= num_iran_servers; i++)); do
        read -p "Enter IP of Iran server $i: " iran_server_ip
        iran_servers+=("$iran_server_ip")
    done

    echo "Kharej server IP: $kharej_ip" > server_ips.txt
    echo "Number of Iran servers: $num_iran_servers" >> server_ips.txt
    echo "Iran servers IPs:" >> server_ips.txt
    for iran_server in "${iran_servers[@]}"; do
        echo "$iran_server" >> server_ips.txt
    done

    echo "Copying RSA key to Iran servers..."
    for iran_server in "${iran_servers[@]}"; do
        ssh-copy-id -o StrictHostKeyChecking=no "$iran_server"
        ssh "$iran_server" 'echo "GatewayPorts yes" >> /etc/ssh/sshd_config'
        ssh "$iran_server" 'systemctl restart sshd.service'
        ssh "$iran_server" 'reboot'
    done

    read -p "How many ports need to be tunneled? " num_ports
    declare -a ports
    for ((i = 1; i <= num_ports; i++)); do
        read -p "Enter port $i: " port
        ports+=("$port")
    done

    echo "Creating systemd service for each port..."
    for port in "${ports[@]}"; do
        for iran_server in "${iran_servers[@]}"; do
            service_file="/etc/systemd/system/KingTunnel@${port}.service"
            cat <<EOL | sudo tee $service_file
[Unit]
Description=Reverse SSH Tunnel Port $port to $iran_server
After=network-online.target

[Service]
Type=simple
ExecStart=ssh -N -R 0.0.0.0:$port:localhost:$port root@$iran_server
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOL
            sudo systemctl daemon-reload
            sudo systemctl enable KingTunnel@$port
            sudo systemctl start KingTunnel@$port
        done
    done

    echo "Tunnel installation completed."
    sleep 3
    systemctl status KingTunnel@*

}





# Function to uninstall tunnel
uninstall_tunnel() {
    if [ ! -f server_ips.txt ]; then
        echo "server_ips.txt not found! Exiting..."
        return
    fi

    source server_ips.txt

    read -p "How many ports need to be untunneled? " num_ports
    declare -a ports
    for ((i = 1; i <= num_ports; i++)); do
        read -p "Enter port $i: " port
        ports+=("$port")
    done

    echo "Disabling and removing systemd service for each port..."
    for port in "${ports[@]}"; do
        for iran_server in "${iran_servers[@]}"; do
            service_file="/etc/systemd/system/KingTunnel@${port}.service"
            sudo systemctl stop KingTunnel@$port
            sudo systemctl disable KingTunnel@$port
            sudo rm $service_file
        done
    done

    sudo systemctl daemon-reload
    echo "Tunnel uninstallation completed."
}


# Function to show tunnel status
show_status_tunnel() {
    echo "Showing Tunnel Status..."
    systemctl status KingTunnel@*
}


show_ports_traffic() {
    echo "Showing live ports traffic..."
    sleep 2
    # Display current network connections and traffic using tcpdump
    sudo tcpdump -i any -nnn -vvv
    
    # Prompt user to start or stop a port
    read -p "Enter port number to start or stop (0 to exit): " port_number
    
    while [ "$port_number" != "0" ]; do
        # Check if the port service exists
        if systemctl status KingTunnel@$port_number &> /dev/null; then
            read -p "Port $port_number is currently running. Do you want to stop it? (yes/no): " action
            if [[ "$action" == "yes" ]]; then
                sudo systemctl stop KingTunnel@$port_number
                echo "Port $port_number stopped."
            else
                echo "No action taken."
            fi
        else
            read -p "Port $port_number is currently stopped. Do you want to start it? (yes/no): " action
            if [[ "$action" == "yes" ]]; then
                sudo systemctl start KingTunnel@$port_number
                echo "Port $port_number started."
            else
                echo "No action taken."
            fi
        fi
        
        # Prompt again for another port or to exit
        read -p "Enter port number to start or stop (0 to exit): " port_number
    done
    
    echo "Exiting show ports traffic."
}

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

# Function to perform backup for Marzban
backup_marzban() {
    echo "Performing backup for Marzban..."
    
    # Create a timestamp for the backup file
    backup_time=$(date +'%Y-%m-%d_%H-%M-%S')
    backup_file="marzban_backup_$backup_time.zip"

    # Compress the /var/lib/marzban/ directory into a zip file
    sudo zip -r "$backup_file" /var/lib/marzban/

    # Move the backup file to a temporary directory accessible to the user
    mv "$backup_file" /tmp/

    echo "Backup completed: $backup_file"

    # Provide download link to the user
    echo "Download link: http://$kharej_ip/tmp/$backup_file"
}

# Function to perform backups
backup() {
    while true; do
        echo "=============================="
        echo "         Backup Menu          "
        echo "=============================="
        echo "1. Backup Marzban"
        echo "2. Backup Sanaei(Soon)"
        echo "3. Backup Shahan(Soon)"
        echo "4. Back to Main Menu"
        echo "=============================="
        echo -n "Enter your choice [1-4]: "
        read choice
        
        case $choice in
            1)
                echo "Performing backup for Marzban..."
                sleep 2
                backup_marzban
                echo "Marzban backup completed."
                sleep 2
                ;;
            2)
                echo "Performing backup for Sanaei..."
                backup
                ;;
            3)
                echo "Performing backup for Shahan..."
                backup
                ;;
            4)
                echo "Returning to Main Menu..."
                return
                ;;
            *)
                echo "Invalid choice. Please enter a number between 1 and 4."
                ;;
        esac
    done
}

# Function to restore Marzban from a backup file
restore_marzban() {
    echo "Restore Marzban from backup"
    
    # Prompt user for the backup file path
    read -p "Enter the path of the backup file to restore: " backup_file_path
    
    # Check if the file exists
    if [ ! -f "$backup_file_path" ]; then
        echo "Error: Backup file not found!"
        return
    fi

    # Extract the backup file to /var/lib/marzban/
    sudo unzip -o "$backup_file_path" -d /var/lib/marzban/
    
    echo "Restore completed."
}

# Function to restore
restore() {
    echo "Restoring..."
    sleep 2
    while true; do
        echo "=============================="
        echo "         Restore Menu          "
        echo "=============================="
        echo "1. Restore Marzban"
        echo "2. Restore Sanaei(Soon)"
        echo "3. Restore Shahan(Soon)"
        echo "4. Back to Main Menu"
        echo "=============================="
        echo -n "Enter your choice [1-4]: "
        read choice
        
        case $choice in
            1)
                echo "Performing backup for Marzban..."
                sleep 2
                restore_marzban
                echo "Marzban backup completed."
                sleep 2
                ;;
            2)
                echo "Comming Soon...."
                Sleep 2
                restore
                ;;
            3)
                echo "Performing backup for Shahan..."
                restore
                ;;
            4)
                echo "Returning to Main Menu..."
                return
                ;;
            *)
                echo "Invalid choice. Please enter a number between 1 and 4."
                ;;
        esac
    done
}
# Function to exit
exit_script() {
    echo "Exiting..."
    exit 0
}

# Main script logic
while true
do
    clear
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
