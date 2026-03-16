#!/bin/sh
set -e

# Configuration - set these environment variables or edit here
SIGNING_IDENTITY="${SIGNING_IDENTITY:-Developer ID Application: William Entriken (8Q693ZG5RN)}"
TEAM_ID="${TEAM_ID:-8Q693ZG5RN}"
APPLE_ID="${APPLE_ID:-}"
KEYCHAIN_PROFILE="${KEYCHAIN_PROFILE:-AC_PASSWORD}"

# Clean previous builds
rm -rf .build
rm -rf CoreLocationCLI.app
rm -f CoreLocationCLI.zip

# Build the project for both architectures
swift build -c release --arch arm64 --arch x86_64

# Package as app
mkdir -p CoreLocationCLI.app/Contents/MacOS/
cp ./.build/apple/Products/Release/CoreLocationCLI CoreLocationCLI.app/Contents/MacOS/
cp Info.plist CoreLocationCLI.app/Contents

# Sign with Developer ID
echo "Signing with: $SIGNING_IDENTITY"
codesign --force --deep --options runtime --sign "$SIGNING_IDENTITY" CoreLocationCLI.app

# Verify signature
echo "Verifying signature..."
codesign --verify --verbose=2 CoreLocationCLI.app
spctl --assess --type execute --verbose=2 CoreLocationCLI.app

# Create zip for notarization
ditto -c -k --keepParent CoreLocationCLI.app CoreLocationCLI.zip

# Notarize
echo "Submitting for notarization..."
xcrun notarytool submit CoreLocationCLI.zip \
    --keychain-profile "$KEYCHAIN_PROFILE" \
    --wait

# Staple the notarization ticket
echo "Stapling notarization ticket..."
xcrun stapler staple CoreLocationCLI.app

# Re-create the final zip with stapled app
rm CoreLocationCLI.zip
zip -r CoreLocationCLI.zip CoreLocationCLI.app

# Smoke test it
# ./CoreLocationCLI.app/Contents/MacOS/CoreLocationCLI --json

echo "Build complete: CoreLocationCLI.zip"