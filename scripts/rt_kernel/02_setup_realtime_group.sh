#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Check if the group 'realtime' already exists, if not, create it
if ! getent group realtime > /dev/null; then
  addgroup realtime
else
  echo "Group 'realtime' already exists."
fi

# Detect the presence of @realtime in limits.conf, skip if true
if ! grep -q "@realtime" /etc/security/limits.conf; then
  cat <<EOT >> /etc/security/limits.conf
@realtime soft rtprio 99
@realtime soft priority 99
@realtime soft memlock 102400
@realtime hard rtprio 99
@realtime hard priority 99
@realtime hard memlock 102400

# End of file
EOT
else
  echo "@realtime settings already present in /etc/security/limits.conf."
fi

# Prompt the user to enter the username, then add this user to the realtime group
read -p "Enter the username to add to the 'realtime' group: " username

# Check if the username exists on the system
if id -u "$username" >/dev/null 2>&1; then
  usermod -aG realtime "$username"
  echo "User '$username' has been added to the 'realtime' group. run getent group for verification"
else
  echo "User '$username' does not exist."
  exit 1
fi
