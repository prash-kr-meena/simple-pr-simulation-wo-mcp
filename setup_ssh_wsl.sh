#!/bin/bash

# Script to set up SSH on Windows WSL (Ubuntu)
# This script will:
# 1. Check if SSH is installed, install if not
# 2. Generate SSH keys if they don't exist
# 3. Set proper permissions for SSH files
# 4. Configure SSH for common use cases
# 5. Provide instructions for adding the public key to services

# Text formatting
BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m" # No Color

echo -e "${BOLD}${BLUE}===== WSL Ubuntu SSH Setup Script =====${NC}\n"

# Step 1: Check if SSH is installed
echo -e "${BOLD}Step 1: Checking if SSH is installed...${NC}"
if ! command -v ssh &> /dev/null; then
    echo -e "${YELLOW}SSH client not found. Installing OpenSSH...${NC}"
    sudo apt update
    sudo apt install -y openssh-client
    echo -e "${GREEN}OpenSSH client installed successfully.${NC}\n"
else
    echo -e "${GREEN}SSH is already installed.${NC}\n"
fi

# Step 2: Create .ssh directory if it doesn't exist
echo -e "${BOLD}Step 2: Setting up SSH directory...${NC}"
SSH_DIR="$HOME/.ssh"
if [ ! -d "$SSH_DIR" ]; then
    echo "Creating .ssh directory..."
    mkdir -p "$SSH_DIR"
    echo -e "${GREEN}Created $SSH_DIR directory.${NC}\n"
else
    echo -e "${GREEN}SSH directory already exists.${NC}\n"
fi

# Step 3: Generate SSH key if it doesn't exist
echo -e "${BOLD}Step 3: Checking for existing SSH keys...${NC}"
if [ ! -f "$SSH_DIR/id_ed25519" ] && [ ! -f "$SSH_DIR/id_rsa" ]; then
    echo -e "${YELLOW}No SSH keys found. Let's generate a new key.${NC}"
    
    # Ask for email
    read -p "Enter your email address (used as a label for your key): " email
    
    # Ask for key type
    echo -e "\nSelect key type:"
    echo "1) ED25519 (recommended, more secure and newer)"
    echo "2) RSA (better compatibility with older systems)"
    read -p "Enter your choice (1/2): " key_choice
    
    if [ "$key_choice" = "1" ]; then
        # Generate ED25519 key
        ssh-keygen -t ed25519 -C "$email"
    else
        # Generate RSA key with 4096 bits
        ssh-keygen -t rsa -b 4096 -C "$email"
    fi
    
    echo -e "${GREEN}SSH key generated successfully.${NC}\n"
else
    echo -e "${GREEN}SSH keys already exist.${NC}\n"
fi

# Step 4: Set correct permissions for SSH files
echo -e "${BOLD}Step 4: Setting correct permissions for SSH files...${NC}"
chmod 700 "$SSH_DIR"
chmod 600 "$SSH_DIR"/id_* 2>/dev/null || true
chmod 644 "$SSH_DIR"/id_*.pub 2>/dev/null || true
chmod 644 "$SSH_DIR"/config 2>/dev/null || true
echo -e "${GREEN}Permissions set correctly.${NC}\n"

# Step 5: Start SSH agent
echo -e "${BOLD}Step 5: Starting SSH agent...${NC}"
eval "$(ssh-agent -s)"
echo -e "${GREEN}SSH agent started.${NC}\n"

# Step 6: Add key to SSH agent
echo -e "${BOLD}Step 6: Adding SSH key to agent...${NC}"
if [ -f "$SSH_DIR/id_ed25519" ]; then
    ssh-add "$SSH_DIR/id_ed25519"
    KEY_PATH="$SSH_DIR/id_ed25519.pub"
elif [ -f "$SSH_DIR/id_rsa" ]; then
    ssh-add "$SSH_DIR/id_rsa"
    KEY_PATH="$SSH_DIR/id_rsa.pub"
fi
echo -e "${GREEN}SSH key added to agent.${NC}\n"

# Step 7: Create/update SSH config file with common settings
echo -e "${BOLD}Step 7: Setting up SSH config file...${NC}"
CONFIG_FILE="$SSH_DIR/config"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating SSH config file..."
    cat > "$CONFIG_FILE" << EOF
# SSH Configuration File

# Default settings for all hosts
Host *
    AddKeysToAgent yes
    IdentitiesOnly yes
    ServerAliveInterval 60
    ServerAliveCountMax 5

# Example: GitHub configuration
# Host github.com
#     User git
#     IdentityFile ~/.ssh/id_ed25519
#     IdentitiesOnly yes

# Example: Custom server configuration
# Host myserver
#     HostName server.example.com
#     User username
#     Port 22
#     IdentityFile ~/.ssh/id_ed25519
EOF
    echo -e "${GREEN}SSH config file created with default settings.${NC}\n"
else
    echo -e "${GREEN}SSH config file already exists. Skipping creation.${NC}\n"
fi

# Step 8: Display public key and instructions
echo -e "${BOLD}Step 8: Your SSH public key${NC}"
echo -e "${YELLOW}Here is your public SSH key. Add this to GitHub, GitLab, or any other service:${NC}\n"

if [ -f "$KEY_PATH" ]; then
    echo -e "${BLUE}$(cat "$KEY_PATH")${NC}\n"
    
    # Copy to clipboard if available
    if command -v clip.exe &> /dev/null; then
        cat "$KEY_PATH" | clip.exe
        echo -e "${GREEN}✓ Public key copied to clipboard!${NC}"
    else
        echo -e "${YELLOW}Note: Install 'xclip' package to enable clipboard functionality.${NC}"
    fi
else
    echo -e "${RED}Could not find your public key file.${NC}\n"
fi

# Step 9: Add to .bashrc or .zshrc to auto-start SSH agent
echo -e "\n${BOLD}Step 9: Setting up SSH agent to start automatically${NC}"
read -p "Would you like to configure SSH agent to start automatically? (y/n): " auto_start

if [ "$auto_start" = "y" ] || [ "$auto_start" = "Y" ]; then
    # Determine which shell is being used
    if [ -f "$HOME/.bashrc" ]; then
        SHELL_RC="$HOME/.bashrc"
        SHELL_NAME="Bash"
    elif [ -f "$HOME/.zshrc" ]; then
        SHELL_RC="$HOME/.zshrc"
        SHELL_NAME="Zsh"
    else
        echo -e "${RED}Could not find .bashrc or .zshrc. Skipping auto-start configuration.${NC}"
        SHELL_RC=""
    fi
    
    if [ -n "$SHELL_RC" ]; then
        # Check if SSH agent configuration already exists
        if ! grep -q "SSH_AUTH_SOCK" "$SHELL_RC"; then
            echo -e "\n# Start SSH agent automatically" >> "$SHELL_RC"
            echo 'if [ -z "$SSH_AUTH_SOCK" ]; then' >> "$SHELL_RC"
            echo '   eval "$(ssh-agent -s)" > /dev/null' >> "$SHELL_RC"
            echo 'fi' >> "$SHELL_RC"
            echo -e "${GREEN}SSH agent auto-start configured in $SHELL_NAME.${NC}"
        else
            echo -e "${GREEN}SSH agent auto-start already configured in $SHELL_NAME.${NC}"
        fi
    fi
else
    echo -e "${YELLOW}Skipping auto-start configuration.${NC}"
fi

# Step 10: Test SSH connection
echo -e "\n${BOLD}Step 10: Testing SSH connection${NC}"
echo -e "${YELLOW}To test your SSH connection to GitHub, run:${NC}"
echo -e "  ${BLUE}ssh -T git@github.com${NC}"
echo -e "${YELLOW}For GitLab, run:${NC}"
echo -e "  ${BLUE}ssh -T git@gitlab.com${NC}"

# Final instructions
echo -e "\n${BOLD}${GREEN}===== SSH Setup Complete =====${NC}"
echo -e "${YELLOW}Your SSH keys are now set up and ready to use.${NC}"
echo -e "${YELLOW}Remember to add your public key to any services you want to connect to.${NC}"
echo -e "${YELLOW}For GitHub: https://github.com/settings/keys${NC}"
echo -e "${YELLOW}For GitLab: https://gitlab.com/-/profile/keys${NC}"
echo -e "\n${BOLD}${BLUE}Happy coding!${NC}"
