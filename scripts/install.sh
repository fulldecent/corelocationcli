#!/bin/bash

# CoreLocationCLI Installation Script

echo "Installing CoreLocationCLI..."

# Check if CoreLocationCLI is already installed
if command -v CoreLocationCLI &> /dev/null; then
    echo "CoreLocationCLI is already installed."
    read -p "Do you want to continue with reinstallation? (y/n): " CONTINUE
    if [[ ! $CONTINUE =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    echo "Continuing with installation..."
fi

# Check if Homebrew is installed
if command -v brew &> /dev/null; then
    # Homebrew exists but CoreLocationCLI is not installed, ask for installation method
    echo "Homebrew is available."
    echo "How would you like to install CoreLocationCLI?"
    echo "1) Via Homebrew (recommended)"
    echo "2) Build from source"
    read -p "Enter your choice (1/2): " INSTALL_CHOICE
    
    if [[ $INSTALL_CHOICE == "1" ]]; then
        echo "Installing via Homebrew..."
        brew install cask corelocationcli
        echo "Installation via Homebrew completed."
    else
        echo "Building from source..."
        # Check if Swift is installed
        if command -v swift &> /dev/null; then
            echo "Building with Swift compiler..."
            swift build --disable-sandbox -c release
            echo "Build completed. Executable is located at: ./.build/arm64-apple-macosx/release/CoreLocationCLI"
            echo "You may want to copy it to a location in your PATH."
        else
            echo "Error: Swift compiler not found. Please install Swift to build CoreLocationCLI."
            exit 1
        fi
    fi
else
    echo "Homebrew not found, building from source..."
    # Check if Swift is installed
    if command -v swift &> /dev/null; then
        echo "Building with Swift compiler..."
        swift build --disable-sandbox -c release
        echo "Build completed. Executable is located at: ./.build/arm64-apple-macosx/release/CoreLocationCLI"
        echo "You may want to copy it to a location in your PATH."
    else
        echo "Error: Swift compiler not found. Please install Swift or Homebrew to install CoreLocationCLI."
        exit 1
    fi
fi

echo "Installation process completed."
