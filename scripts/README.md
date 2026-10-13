# CoreLocationCLI scripts guide

## build.sh

Builds a universal binary, signs it with the Developer ID Application certificate, notarizes it, staples the ticket, and writes `CoreLocationCLI.zip`.

`VERSION` and `CFBundleShortVersionString` in `Info.plist` must match. The script stops when they do not.

### On this machine

1. The Developer ID Application certificate `Developer ID Application: William Entriken (8Q693ZG5RN)` is in the login keychain.
2. Notarization credentials are stored:

   ```sh
   xcrun notarytool store-credentials AC_PASSWORD \
       --apple-id "your@email.com" \
       --team-id "8Q693ZG5RN" \
       --password "app-specific-password"
   ```

```sh
./scripts/build.sh
```

To notarize with an App Store Connect team key instead of the keychain profile, set `APP_STORE_CONNECT_KEY_PATH`, `APP_STORE_CONNECT_KEY_ID`, and `APP_STORE_CONNECT_ISSUER_ID`. The key has to be a team key. An individual key cannot call `notarytool`.

GitHub Actions sets those three variables from repository secrets and imports the Developer ID certificate before it runs this script. The release steps are in [RELEASE.md](../RELEASE.md).
