#!/usr/bin/env bash
#
# sshin-harden-ssh.sh - Applies recommended security settings to sshd_config.
#
# This script will:
# 1. Create a timestamped backup of your current sshd_config.
# 2. Disable root login over SSH.
# 3. Disable password-based authentication, enforcing key-based login.
# 4. Disable authentication using empty passwords.

# --- Sanity Check ---
if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root. Please use 'sudo ./sshin-harden-ssh.sh'"
   exit 1
fi

SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP_FILE="/etc/ssh/sshd_config.bak-$(date +%Y%m%d-%H%M%S)"

# --- Confirmation ---
echo "--- SSH Hardening Utility ---"
echo "This script will modify your SSH configuration ($SSHD_CONFIG) to enhance security."
echo "It will apply the following settings:"
echo "  - PermitRootLogin no"
echo "  - PasswordAuthentication no"
echo "  - PermitEmptyPasswords no"
echo ""
echo "A backup of your current configuration will be created at: $BACKUP_FILE"
echo ""
read -p "Are you sure you want to proceed? (yes/no): " CONFIRMATION

if [ "$CONFIRMATION" != "yes" ]; then
    echo "Aborting. No changes have been made."
    exit 1
fi

# --- Hardening Logic ---
echo "Creating backup..."
cp "$SSHD_CONFIG" "$BACKUP_FILE"
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create backup file. Aborting."
    exit 1
fi
echo "Backup created successfully."

# Function to update a setting in sshd_config
# It removes any existing instance (commented or not) and appends the new setting.
update_sshd_setting() {
    local key="$1"
    local value="$2"
    local config_file="$3"

    echo "Applying setting: $key $value"
    # Remove any existing line with the key
    sed -i "/^#\?${key}/d" "$config_file"
    # Append the new, correct setting to the end of the file
    echo "${key} ${value}" >> "$config_file"
}

# Apply the recommended security settings
update_sshd_setting "PermitRootLogin" "no" "$SSHD_CONFIG"
update_sshd_setting "PasswordAuthentication" "no" "$SSHD_CONFIG"
update_sshd_setting "PermitEmptyPasswords" "no" "$SSHD_CONFIG"

# --- Final Instructions ---
echo ""
echo "--- Hardening Complete ---"
echo "Your SSH configuration has been updated."
echo "Please restart the SSH service to apply the changes."
echo "You can do this with: sudo systemctl restart sshd"
echo "If you encounter any issues, you can restore your old configuration from $BACKUP_FILE"
echo ""

exit 0
