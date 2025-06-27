#!/usr/bin/env bash
#
# sshin-server-setup.sh - Securely prepare a server for sshin management.
#
# This script creates a new user, adds them to the sudo group, and installs
# a public SSH key for passwordless login.

# --- Sanity Check ---
if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root. Please use 'sudo ./sshin-server-setup.sh'"
   exit 1
fi

# --- Main Logic ---
echo "--- sshin Server Setup Utility ---"
echo "This script will guide you through creating a new user for SSH management."

# --- Get New Username ---
read -p "Enter the username for the new management user (e.g., sysadmin): " NEW_USER
if [ -z "$NEW_USER" ]; then
    echo "Username cannot be empty. Aborting."
    exit 1
fi

if id "$NEW_USER" &>/dev/null; then
    echo "User '$NEW_USER' already exists. Aborting."
    exit 1
fi

# --- Create User ---
echo "Creating user '$NEW_USER'..."
adduser --disabled-password --gecos "" "$NEW_USER"
if [ $? -ne 0 ]; then
    echo "Failed to create user. Aborting."
    exit 1
fi

echo "Adding user '$NEW_USER' to the 'sudo' group..."
usermod -aG sudo "$NEW_USER"
echo "User '$NEW_USER' created and granted sudo privileges."

# --- Install SSH Key ---
USER_HOME=$(eval echo "~$NEW_USER")
SSH_DIR="$USER_HOME/.ssh"
AUTH_KEYS_FILE="$SSH_DIR/authorized_keys"

echo ""
echo "Please provide the public SSH key for the '$NEW_USER' user."
echo "On your local machine, you can get this key by running a command like:"
echo "cat ~/.ssh/management_key.pub"
echo ""
read -p "Paste the public key here: " PUBLIC_KEY

if [ -z "$PUBLIC_KEY" ]; then
    echo "No public key provided. Aborting."
    deluser --remove-home "$NEW_USER"
    exit 1
fi

echo "Installing public key for '$NEW_USER'..."

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
echo "$PUBLIC_KEY" >> "$AUTH_KEYS_FILE"
chmod 600 "$AUTH_KEYS_FILE"
chown -R "$NEW_USER:$NEW_USER" "$USER_HOME"

echo "Public key installed successfully."

# --- Final Recommendations ---
echo ""
echo "--- Setup Complete ---"
echo "User '$NEW_USER' is ready for SSH login with their key."
echo ""
echo "For enhanced security, you can now run the 'sshin-harden-ssh.sh' script."
echo "It automatically disables password logins and root access over SSH."
echo ""

exit 0
