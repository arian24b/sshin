#!/usr/bin/env bash
#
# sshin-setup - A helper script to generate SSH keys for use with sshin.

# --- Configuration ---
SSH_DIR="$HOME/.ssh"

# Define the default keys you want to create
declare -a KEYS_TO_CREATE=(
    "management_key"
    "app_key"
)

# --- Main Logic ---
echo "--- sshin Client Key Setup Utility ---"

if [ ! -d "$SSH_DIR" ]; then
    echo "Creating .ssh directory..."
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
else
    echo ".ssh directory already exists."
fi

# Function to generate an SSH key if it doesn't exist
generate_key_if_not_exists() {
    local key_name="$1"
    local key_file="$SSH_DIR/$key_name"
    local key_comment="$USER@$(hostname)"

    if [ -f "$key_file" ]; then
        echo "Key '$key_name' already exists at $key_file. Skipping."
    else
        echo "---"
        echo "Generating key '$key_name'..."
        ssh-keygen -t rsa -b 4096 -f "$key_file" -N "" -C "$key_comment"
        if [ $? -eq 0 ]; then
            echo "Successfully generated $key_file and $key_file.pub"
        else
            echo "ERROR: Failed to generate $key_file"
            exit 1
        fi
    fi
}

for key in "${KEYS_TO_CREATE[@]}"; do
    generate_key_if_not_exists "$key"
done

echo "---"
echo "Setup complete. You can now add these PUBLIC keys to your remote servers."
echo "Use a command like this to get the key for pasting:"
echo "cat $SSH_DIR/management_key.pub"
