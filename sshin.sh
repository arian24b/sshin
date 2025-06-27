#!/bin/bash
#
# sshin - A secure SSH connection helper and session logger.

# --- Configuration ---
CONFIG_FILE="$HOME/.config/sshin/servers.conf"
LOGS_DIR="$HOME/.local/share/sshin/logs/$USER"
HOST_ALIAS=$1

# --- Sanity Checks ---
if [ -z "$HOST_ALIAS" ]; then
    echo "sshin: An SSH session manager"
    echo "Usage: sshin {host_alias}"
    echo "Define aliases in $CONFIG_FILE"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Configuration file not found at $CONFIG_FILE"
    echo "Please run the setup and create the configuration file first."
    exit 1
fi

# --- Read Configuration ---
SERVER_CONFIG=$(grep "^${HOST_ALIAS}:" "$CONFIG_FILE")

if [ -z "$SERVER_CONFIG" ]; then
    echo "ERROR: Host alias '$HOST_ALIAS' not found in $CONFIG_FILE"
    exit 1
fi

# --- Parse Configuration ---
# Format: alias:user@hostname:port:key_path
REMOTE_USER=$(echo "$SERVER_CONFIG" | cut -d':' -f2 | cut -d'@' -f1)
REMOTE_HOST=$(echo "$SERVER_CONFIG" | cut -d':' -f2 | cut -d'@' -f2)
REMOTE_PORT=$(echo "$SERVER_CONFIG" | cut -d':' -f3)
SSH_KEY_PATH=$(echo "$SERVER_CONFIG" | cut -d':' -f4)

if [ -z "$REMOTE_PORT" ]; then
    REMOTE_PORT=22
fi

SSH_KEY_PATH="${SSH_KEY_PATH/#\~/$HOME}"

if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "ERROR: SSH private key not found at $SSH_KEY_PATH"
    exit 1
fi

# --- Logging ---
mkdir -p "$LOGS_DIR"
LOG_FILE="$LOGS_DIR/$(date +'%Y-%m-%d_%H-%M-%S')-$HOST_ALIAS.log"

# --- Connect ---
echo "Connecting to $REMOTE_USER@$REMOTE_HOST on port $REMOTE_PORT..."
echo "Session log will be saved to: $LOG_FILE"

ssh -i "$SSH_KEY_PATH" \
    -p "$REMOTE_PORT" \
    -t "$REMOTE_USER@$REMOTE_HOST" "sudo su -" | tee -a "$LOG_FILE"
