#!/bin/zsh

# MasterControl Installation Script for macOS

# Function to print messages in color
print_message() {
  echo -e "\033[1;34m$1\033[0m"
}

# Check if user is root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or using sudo."
  exit 1
fi

print_message "Starting installation of MasterControl..."

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
  print_message "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ $? -ne 0 ]; then
    echo "Failed to install Homebrew. Please install it manually from https://brew.sh/."
    exit 1
  fi
else
  print_message "Homebrew is already installed."
fi

# Dependencies check and installation
print_message "Checking for dependencies..."

# Install NASM if not present
if ! command -v nasm &> /dev/null; then
  print_message "NASM not found. Installing NASM..."
  brew install nasm
  if [ $? -ne 0 ]; then
    echo "Failed to install NASM. Please install it manually using 'brew install nasm'."
    exit 1
  fi
else
  print_message "NASM is already installed."
fi

# Install Figlet and Lolcat if not present
if ! command -v figlet &> /dev/null; then
  print_message "Figlet not found. Installing Figlet..."
  brew install figlet
  if [ $? -ne 0 ]; then
    echo "Failed to install Figlet. Please install it manually using 'brew install figlet'."
    exit 1
  fi
else
  print_message "Figlet is already installed."
fi

if ! command -v lolcat &> /dev/null; then
  print_message "Lolcat not found. Installing Lolcat..."
  brew install lolcat
  if [ $? -ne 0 ]; then
    echo "Failed to install Lolcat. Please install it manually using 'brew install lolcat'."
    exit 1
  fi
else
  print_message "Lolcat is already installed."
fi

# Clone MasterControl repository
print_message "Cloning MasterControl repository..."
if [ ! -d "mastercontrol" ]; then
  git clone https://github.com/mastercontroller-lang/mastercontrol.git
  if [ $? -ne 0 ]; then
    echo "Failed to clone the MasterControl repository. Please check your internet connection."
    exit 1
  fi
else
  print_message "MasterControl repository already exists. Pulling latest changes..."
  cd mastercontrol && git pull && cd ..
fi

cd mastercontrol

# Assemble MasterControl
print_message "Assembling MasterControl with NASM..."

if [ ! -f "mastercontrol.asm" ]; then
  echo "Error: 'mastercontrol.asm' not found in the repository. Please ensure the repository is up-to-date."
  exit 1
fi

nasm -f macho64 mastercontrol.asm -o mastercontrol.o
if [ $? -ne 0 ]; then
  echo "Error assembling 'mastercontrol.asm'."
  exit 1
fi

# Link MasterControl
print_message "Linking MasterControl..."
ld -o mc mastercontrol.o -macosx_version_min 10.12 -e _start -lSystem
if [ $? -ne 0 ]; then
  echo "Error linking 'mastercontrol.o'."
  exit 1
fi

# Set permissions for the binary
print_message "Setting permissions for MasterControl binary..."
sudo chown root:wheel mc
sudo chmod u+s mc

# Move binary to /usr/local/bin
print_message "Installing MasterControl to /usr/local/bin..."
if [ ! -d "/usr/local/bin" ]; then
  mkdir -p /usr/local/bin
fi
mv mc /usr/local/bin/
if [ $? -ne 0 ]; then
  echo "Error moving 'mc' to /usr/local/bin."
  exit 1
fi

print_message "MasterControl installed successfully!"

# Display success message with Figlet and Lolcat
print_message "Displaying MasterControl logo..."
echo "MasterControl installed!" | figlet | lolcat

# Usage instructions
print_message "To use MasterControl, run: mc <command>\nFor example: mc ls /root"

