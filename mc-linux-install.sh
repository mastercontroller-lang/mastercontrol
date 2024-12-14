#!/bin/bash

# Define variables
SOURCE_FILE="mastercontrol.asm"
OUTPUT_FILE="mc"
INSTALL_DIR="/usr/local/bin"

# Check if the source file exists
if [[ ! -f "$SOURCE_FILE" ]]; then
    echo "Error: Source file '$SOURCE_FILE' not found!"
    exit 1
fi

# Step 1: Assemble the program
echo "Assembling $SOURCE_FILE..."
nasm -f elf64 "$SOURCE_FILE" -o "${OUTPUT_FILE}.o"
if [[ $? -ne 0 ]]; then
    echo "Error: Assembly failed!"
    exit 1
fi

# Step 2: Link the program
echo "Linking ${OUTPUT_FILE}.o..."
ld "${OUTPUT_FILE}.o" -o "$OUTPUT_FILE"
if [[ $? -ne 0 ]]; then
    echo "Error: Linking failed!"
    exit 1
fi

# Step 3: Make the program executable
echo "Setting execute permissions on $OUTPUT_FILE..."
chmod +x "$OUTPUT_FILE"

# Step 4: Move the program to the install directory
echo "Installing $OUTPUT_FILE to $INSTALL_DIR..."
sudo mv "$OUTPUT_FILE" "$INSTALL_DIR"
if [[ $? -ne 0 ]]; then
    echo "Error: Installation failed! Are you running this script with sufficient privileges?"
    exit 1
fi

# Step 5: Verify installation
echo "Verifying installation..."
if command -v mc &>/dev/null; then
    echo "Success! 'mc' is now installed and available as a command."
    echo "You can run it from anywhere, e.g., 'mc ls'."
else
    echo "Error: 'mc' was not found in your PATH after installation."
    exit 1
fi
