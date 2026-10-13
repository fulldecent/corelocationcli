# CoreLocationCLI scripts guide

## build.sh

Builds a universal binary, signs it with the Developer ID Application certificate, notarizes it, staples the ticket, and writes `CoreLocationCLI.zip`.

`VERSION` and `CFBundleShortVersionString` in `Info.plist` must match. The script stops when they do not.

### On this machine

1. The Developer ID Application certificate `Developer ID Application: William Entriken (8Q693ZG5RN)` is in the login keychain.
2. Notarization credentials are stored:

   ```sh
   xcrun notarytool store-credentials AC_PASSWORD \
       --apple-id "example@example.com" \
       --team-id "8Q693ZG5RN" \
       --password "app-specific-password"
   ```

```sh
./scripts/build.sh
```

The release is in [RELEASE.md](../RELEASE.md). GitHub Actions uses a team API key instead of this keychain profile.
