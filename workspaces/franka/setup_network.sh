#!/bin/bash

# Function to display an error message and exit
function error_exit {
    echo "$1" 1>&2
    exit 1
}

# Check if the user is root
if [ "$(id -u)" -ne 0; then
    error_exit "This script must be run as root."
fi

# Check if nmcli is installed
if ! command -v nmcli &> /dev/null; then
    error_exit "nmcli could not be found. Please install NetworkManager."
fi

# Get the list of network interfaces managed by NetworkManager
interfaces=$(nmcli device status | grep -w "ethernet\|wifi" | awk '{print $1}')

# check if dialog is installed
if ! command -v dialog &> /dev/null; then
    error_exit "dialog could not be found. Please install dialog."
fi

# Use dialog to let the user select an interface
interface=$(dialog --stdout --menu "Select a network interface:" 15 50 5 $(for iface in $interfaces; do echo $iface $iface; done))

# Check if the user canceled the dialog
if [ $? -ne 0 ]; then
    clear
    echo "Operation canceled."
    exit 1
fi

# Set the IP address and netmask
ip_address="172.16.0.1"
netmask="255.255.255.0"
prefix_length="24"  # Equivalent to netmask 255.255.255.0

# detect if the connection profile already exists
if ! nmcli con show "$interface" &> /dev/null; then
    echo "Connection profile for $interface not found. Creating a new profile."
    nmcli con add type ethernet ifname "$interface" con-name "$interface" || error_exit "Failed to create connection profile for $interface."
fi

# Apply the settings using nmcli
nmcli con mod "$interface" ipv4.addresses "$ip_address/$prefix_length" ipv4.method manual || error_exit "Failed to set IP address."
nmcli con up "$interface" || error_exit "Failed to bring the interface up."

# Clear the dialog and show success message
clear
echo "Successfully configured $interface with IP $ip_address and netmask $netmask."

exit 0