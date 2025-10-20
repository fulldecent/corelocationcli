#!/bin/sh

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
codesign --force --deep --sign - CoreLocationCLI.app

# Smoke test it
# ./CoreLocationCLI.app/Contents/MacOS/CoreLocationCLI --json

# Bundle it
zip -r CoreLocationCLI.zip CoreLocationCLI.app

echo "Build complete: CoreLocationCLI.zip"