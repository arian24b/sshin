# sshin - SSH Session Manager

**sshin** is a command-line tool designed to simplify and streamline the process of connecting to and managing multiple remote servers over SSH. It uses simple aliases to connect to pre-configured servers and automatically logs your sessions for auditing and review.

English | [فارسی](README.fa.md)

## Features

-   **Alias-Based Connections**: Connect to your servers using short, memorable names instead of long hostnames or IP addresses.
-   **Centralized Configuration**: Manage all your server connections from a single, easy-to-read configuration file.
-   **Automatic Session Logging**: Automatically saves a log of every session to a local directory.
-   **Source Code Obfuscation**: The main client is distributed as a binary to prevent casual inspection of the source code.
-   **Automated Releases**: Integrated with GitHub Actions to automatically build and publish new releases.
-   **Helper Scripts**: Includes utilities for client-side key generation, guided server setup, and optional security hardening.

## Project Files

This tool consists of four core scripts that you will manage in your repository:

1.  **`sshin`**: The main client script source code. This gets compiled into a binary during the release process.
2.  **`sshin-setup`**: A one-time utility for your client machine to generate the necessary SSH keys.
3.  **`sshin-server-setup.sh`**: A helper script to run on a remote server to securely prepare it for `sshin` management.
4.  **`sshin-harden-ssh.sh`**: An optional script to apply security best practices to a server's SSH configuration.

## Installation & Setup

### Step 1: Configure Your Client Machine

First, set up the `sshin` tool on your local computer.

1.  **Download the Latest Release**: Go to the "Releases" page of the GitHub repository and download the latest `sshin` binary and the `sshin-setup` script.
2.  **Place Files in Your PATH**:
    Move the downloaded files to a directory in your system's `PATH`, like `/usr/local/bin/`.
    ```bash
    sudo mv ./sshin /usr/local/bin/sshin
    sudo mv ./sshin-setup /usr/local/bin/sshin-setup
    sudo chmod +x /usr/local/bin/sshin /usr/local/bin/sshin-setup
    ```

3.  **Generate SSH Keys**:
    Run the setup utility to create the SSH key pairs.
    ```bash
    sshin-setup
    ```
    This will create keys like `~/.ssh/management_key`. You will need the public key (`.pub` file) for the server setup.

4.  **Create Your Configuration File**:
    `sshin` uses a central file to manage your server list.
    ```bash
    mkdir -p ~/.config/sshin
    touch ~/.config/sshin/servers.conf
    ```
    Add your servers to this file using the format: `alias:user@hostname:port:key_path`.

    **Example `~/.config/sshin/servers.conf`**:
    ```ini
    prod-web-1:sysadmin@192.0.2.10:22:~/.ssh/management_key
    ```

### Step 2: Configure Your Remote Server

Run the `sshin-server-setup.sh` script (downloaded from the release page) on each remote server.

```bash
# On the remote server:
sudo chmod +x sshin-server-setup.sh
sudo ./sshin-server-setup.sh
```

This script will guide you through creating a new user and installing their public SSH key.

### Step 3: (Optional) Harden Server SSH Configuration

For enhanced security, you can use the `sshin-harden-ssh.sh` script on your remote server. This script disables password-based logins and prevents the root user from logging in directly via SSH.

**Warning**: This is a potentially destructive action. The script will create a backup of your SSH configuration, but you should use it with caution.

1.  Download `sshin-harden-ssh.sh` from the GitHub release page to your server.
2.  Run it with `sudo`:
    ```bash
    # On the remote server:
    sudo chmod +x sshin-harden-ssh.sh
    sudo ./sshin-harden-ssh.sh
    ```

The script will ask for confirmation before applying any changes.

## Usage

Connect to any configured server by running `sshin` with its alias.

```bash
# Connect to the server with alias 'prod-web-1'
sshin prod-web-1
```

## Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

Don't forget to give the project a star\! Thanks again\!

1.  **Fork the Project**
2.  **Create your Feature Branch**
    ```sh
    git checkout -b feature/AmazingFeature
    ```
3.  **Commit your Changes**
    ```sh
    git commit -m 'Add some AmazingFeature'
    ```
4.  **Push to the Branch**
    ```sh
    git push origin feature/AmazingFeature
    ```
5.  **Open a Pull Request**

## License

This project is licensed under the MIT License. See the [LICENSE](https://www.google.com/search?q=LICENSE) file for the full text.
