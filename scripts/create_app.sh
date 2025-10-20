#!/bin/bash

# CoreLocationCLI Application Creator Script
# This script builds CoreLocationCLI and packages it as a macOS application

echo "Creating CoreLocationCLI Application..."

# Add execution permission
# chmod +x scripts/create_app.sh

# User selection for brew installation
echo "Is this for giving permissions to a brew-installed CoreLocationCLI? (y/n)"
read -n 1 -r BREW_INSTALL
echo ""

# Default configuration
BUILD_CONFIG="release"
OUTPUT_DIR="./dist"
APP_NAME="CoreLocationCLI"
ICON_PATH=""
SIGN_APP=true
NOTARIZE_APP=false
DEVELOPER_ID=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --output|-o)
            if [[ $# -gt 1 ]]; then
                OUTPUT_DIR="$2"
                shift 2
            else
                echo "Error: --output requires a directory path"
                exit 1
            fi
            ;;
        --name|-n)
            if [[ $# -gt 1 ]]; then
                APP_NAME="$2"
                shift 2
            else
                echo "Error: --name requires an application name"
                exit 1
            fi
            ;;
        --icon|-i)
            if [[ $# -gt 1 ]]; then
                ICON_PATH="$2"
                shift 2
            else
                echo "Error: --icon requires a path to an .icns file"
                exit 1
            fi
            ;;
        --sign|-s)
            SIGN_APP=true
            if [[ $# -gt 1 && ! "$2" == --* ]]; then
                DEVELOPER_ID="$2"
                shift 2
            else
                shift
            fi
            ;;
        --notarize|-nt)
            NOTARIZE_APP=true
            SIGN_APP=true
            shift
            ;;
        --help|-h)
            echo "CoreLocationCLI Application Creator"
            echo ""
            echo "Usage:"
            echo "  $0 [options]"
            echo ""
            echo "Options:"
            echo "  --output, -o DIR     Output directory (default: ./dist)"
            echo "  --name, -n NAME      Application name (default: CoreLocationCLI)"
            echo "  --icon, -i PATH      Path to .icns icon file"
            echo "  --sign, -s [ID]      Sign the application (optionally with Developer ID)"
            echo "  --notarize, -nt      Notarize the application (implies --sign)"
            echo "  --help, -h           Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Verify Swift is installed
if ! command -v swift &> /dev/null; then
    echo "Error: Swift compiler not found. Please install Swift to build CoreLocationCLI."
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Determine build path based on user selection
if [[ $BREW_INSTALL =~ ^[Yy]$ ]]; then
    # Get the path to the brew-installed CoreLocationCLI
    BREW_CLI_PATH=$(command -v "CoreLocationCLI")
    if [ -z "$BREW_CLI_PATH" ]; then
        echo "Error: CoreLocationCLI not found in PATH. Is it installed via brew?"
        echo "Please install it with: brew install cask corelocationcli"
        exit 1
    fi
    
    # Get the real path if it's a symlink
    ORIGINAL_CLI_PATH=$(readlink -f "$BREW_CLI_PATH" || echo "$BREW_CLI_PATH")
    echo "Using brew-installed CoreLocationCLI at: $ORIGINAL_CLI_PATH"
else
    # Build the CLI from source
    echo "Building CoreLocationCLI in $BUILD_CONFIG mode..."
    swift build --disable-sandbox -c $BUILD_CONFIG

    if [ $? -ne 0 ]; then
        echo "Build failed!"
        exit 1
    fi
    
    # Use the locally built version
    ORIGINAL_CLI_PATH="./.build/arm64-apple-macosx/$BUILD_CONFIG/CoreLocationCLI"
fi

if [ ! -f "$ORIGINAL_CLI_PATH" ]; then
    echo "Error: CoreLocationCLI executable not found at $ORIGINAL_CLI_PATH"
    exit 1
fi

# Create app bundle structure
APP_BUNDLE="$OUTPUT_DIR/$APP_NAME.app"
APP_CONTENTS="$APP_BUNDLE/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"

echo "Creating application bundle at $APP_BUNDLE..."
mkdir -p "$APP_MACOS"
mkdir -p "$APP_RESOURCES"

# Copy executable
cp "$ORIGINAL_CLI_PATH" "$APP_MACOS/"
chmod +x "$APP_MACOS/CoreLocationCLI"

# Create Info.plist
cat > "$APP_CONTENTS/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>CoreLocationCLI</string>
    <key>CFBundleIdentifier</key>
    <string>com.fulldecent.CoreLocationCLI</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>NSLocationUsageDescription</key>
    <string>This application requires location services to function.</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This application requires location services to function.</string>
    <key>NSLocationAlwaysUsageDescription</key>
    <string>This application requires location services to function.</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>This application requires location services to function.</string>
</dict>
</plist>
EOF

# Sign the application if requested
if [ "$SIGN_APP" = true ]; then
    echo "Signing application..."
    
    if [ ! -z "$DEVELOPER_ID" ]; then
        # Sign with provided identity
        echo "Using Developer ID: $DEVELOPER_ID"
        codesign -f --deep -s "$DEVELOPER_ID" "$APP_BUNDLE"
    else
        # Sign with ad-hoc identity (-)
        codesign -f --deep -s - "$APP_BUNDLE"
    fi
    
    if [ $? -ne 0 ]; then
        echo "Application signing failed!"
        exit 1
    fi
    
    echo "Application signed successfully."
    
    # Notarize if requested
    if [ "$NOTARIZE_APP" = true ]; then
        echo "Notarization is enabled but requires Apple Developer account credentials."
        echo "Please notarize the application manually using 'xcrun notarytool'."
        echo "See Apple's documentation for details: https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution"
    fi
fi

echo "Application bundle created successfully at: $APP_BUNDLE"
echo ""
echo "To run the application: open \"$APP_BUNDLE\""
open "$APP_BUNDLE"
echo ""
echo "Note: When first running the application, macOS Gatekeeper may block it."
echo "To approve, go to System Settings → Privacy & Security → General"

# Press any key to continue
echo ""
echo "Press any key to continue..."
read -n 1 -s

# Create a separate folder for CLI usage
CLI_DIR="$OUTPUT_DIR/cli_standalone"
mkdir -p "$CLI_DIR"

# Copy Info.plist and CLI executable to the new folder
echo ""
echo "Creating standalone CLI version in $CLI_DIR..."
cp "$APP_CONTENTS/Info.plist" "$CLI_DIR/"
cp "$APP_MACOS/CoreLocationCLI" "$CLI_DIR/"
chmod +x "$CLI_DIR/CoreLocationCLI"

echo "Standalone CLI version created at: $CLI_DIR"
echo "You can use it directly with: $CLI_DIR/CoreLocationCLI"

# If this was for brew installation, replace the original executable
if [[ $BREW_INSTALL =~ ^[Yy]$ ]]; then
    echo ""
    echo "Replacing the original CoreLocationCLI with the permission-enabled version..."
    
    BREW_CLI_PATH=$(command -v "CoreLocationCLI")
    if [ ! -z "$BREW_CLI_PATH" ]; then
        # Get the real path if it's a symlink
        ORIGINAL_CLI_PATH=$(readlink -f "$BREW_CLI_PATH" || echo "$BREW_CLI_PATH")
        echo "Original executable path: $ORIGINAL_CLI_PATH"
        
        # Get the directory of the original executable
        ORIGINAL_CLI_DIR=$(dirname "$ORIGINAL_CLI_PATH")
        
        # Backup the original executable
        sudo cp "$ORIGINAL_CLI_PATH" "${ORIGINAL_CLI_PATH}.backup"
        # Replace with our new executable
        sudo cp "$APP_MACOS/CoreLocationCLI" "$ORIGINAL_CLI_PATH"
        # Copy Info.plist to the same directory as the executable
        sudo cp "$APP_CONTENTS/Info.plist" "$ORIGINAL_CLI_DIR/"
        
        echo "Original executable backed up to: ${ORIGINAL_CLI_PATH}.backup"
        echo "CoreLocationCLI has been replaced with the permission-enabled version."
        echo "Info.plist has been copied to: $ORIGINAL_CLI_DIR/"
        
        echo ""
        echo "🎉 Congratulations! You can now use CoreLocationCLI normally."
        echo ""
        echo "Tip: If you get an error like \"CoreLocationCLI: ❌ The operation couldn't be completed. (kCLErrorDomain error 0.)\","
        echo "     try restarting your Wi-Fi, as this might help resolve the issue."
    else
        echo "Error: Could not find the original CoreLocationCLI executable."
    fi
fi

