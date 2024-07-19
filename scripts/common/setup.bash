#!/bin/bash

# Function to set the hostname
set_hostname() {
  read -p "Do you want to set the hostname? (yes/no): " set_hostname_choice
  if [[ "$set_hostname_choice" == "yes" ]]; then
    echo "Please enter the desired hostname: "
    read NEW_HOSTNAME
    hostnamectl set-hostname "$NEW_HOSTNAME"
    echo "Hostname set to $NEW_HOSTNAME"
  else
    echo "Hostname setting skipped"
  fi
}

# Function to install SSH server
install_ssh_server() {
  echo "Installing SSH server..."
  apt update
  apt install -y openssh-server curl 
  echo "SSH server installed."
}

# Function to display network interface IP addresses
display_ip_addresses() {
  echo "Network Interface IP Addresses:"
  ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
}

# Function to create an admin account
create_admin_account() {
    read -p "Do you want to create an admin account? (yes/no): " create_account
    if [[ "$create_account" == "yes" ]]; then
        while true; do
            read -p "Enter the username for the new admin account: " admin_username
            if id "$admin_username" &>/dev/null; then
                echo "User $admin_username already exists. Skipping..."
                break
            else
                sudo adduser "$admin_username"
                sudo usermod -aG sudo "$admin_username"
                echo "Admin account $admin_username created with sudo privileges"
                break
            fi
        done
    else
        echo "Admin account creation skipped"
        admin_username=""
    fi
}

# Function to add GitHub SSH keys to the admin account
add_github_keys() {
    read -p "Do you want to add GitHub SSH keys to admin account? (yes/no): " add_keys
    if [[ "$add_keys" == "yes" ]]; then
        read -p "Enter your GitHub username: " github_username

        if [[ -z "$admin_username" ]]; then
            read -p "Enter the username for the admin account: " admin_username
        fi

        mkdir -p /home/$admin_username/.ssh
        curl "https://github.com/$github_username.keys" | sudo tee -a /home/$admin_username/.ssh/authorized_keys
        chown -R "$admin_username:$admin_username" /home/$admin_username/.ssh
        chmod 600 /home/$admin_username/.ssh/authorized_keys
        echo "GitHub SSH keys added to $admin_username's account."
    fi
}

# Main script logic
set -e

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

set_hostname
install_ssh_server
display_ip_addresses
create_admin_account
add_github_keys

echo "Setup completed successfully!"
