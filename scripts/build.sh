#!/bin/sh
set -e

# Sign with Developer ID, notarize, staple, and write CoreLocationCLI.zip.
# VERSION and Info.plist CFBundleShortVersionString must already match.
# Release Please updates both. The Swift --version flag reads the plist
# from the app bundle this script copies into place.
#
# Local notarization uses the notarytool keychain profile AC_PASSWORD.
# GitHub Actions sets APP_STORE_CONNECT_KEY_PATH, APP_STORE_CONNECT_KEY_ID,
# and APP_STORE_CONNECT_ISSUER_ID instead. That key is a team key with the
# Developer role. An individual key cannot call notarytool.

SIGNING_IDENTITY="${SIGNING_IDENTITY:-Developer ID Application: William Entriken (8Q693ZG5RN)}"
KEYCHAIN_PROFILE="${KEYCHAIN_PROFILE:-AC_PASSWORD}"

version=$(grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' VERSION | head -1)
plist_version=$(defaults read "$(pwd)/Info" CFBundleShortVersionString)
if [ "$version" != "$plist_version" ]; then
  echo "VERSION $version does not match Info.plist $plist_version" >&2
  exit 1
fi

rm -rf .build
rm -rf CoreLocationCLI.app
rm -f CoreLocationCLI.zip

swift build -c release --arch arm64 --arch x86_64

mkdir -p CoreLocationCLI.app/Contents/MacOS/
cp ./.build/apple/Products/Release/CoreLocationCLI CoreLocationCLI.app/Contents/MacOS/
cp Info.plist CoreLocationCLI.app/Contents

echo "Signing with: $SIGNING_IDENTITY"
codesign --force --deep --options runtime --sign "$SIGNING_IDENTITY" CoreLocationCLI.app
codesign --verify --verbose=2 CoreLocationCLI.app

ditto -c -k --keepParent CoreLocationCLI.app CoreLocationCLI.zip

echo "Submitting for notarization..."
if [ -n "${APP_STORE_CONNECT_KEY_PATH:-}" ]; then
  xcrun notarytool submit CoreLocationCLI.zip \
    --key "$APP_STORE_CONNECT_KEY_PATH" \
    --key-id "$APP_STORE_CONNECT_KEY_ID" \
    --issuer "$APP_STORE_CONNECT_ISSUER_ID" \
    --wait
else
  xcrun notarytool submit CoreLocationCLI.zip \
    --keychain-profile "$KEYCHAIN_PROFILE" \
    --wait
fi

echo "Stapling notarization ticket..."
xcrun stapler staple CoreLocationCLI.app
xcrun stapler validate CoreLocationCLI.app
# Gatekeeper assessment has to follow stapling. Before the ticket is
# stapled, spctl rejects a Developer ID app and the script would stop
# before notarization.
spctl --assess --type execute --verbose=2 CoreLocationCLI.app

rm CoreLocationCLI.zip
zip -r CoreLocationCLI.zip CoreLocationCLI.app

echo "Build complete: CoreLocationCLI.zip"
