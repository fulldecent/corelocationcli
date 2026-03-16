# CoreLocationCLI scripts guide

## build.sh

Builds, signs, notarizes, and packages CoreLocationCLI for release.

### Prerequisites

1. A Developer ID Application certificate installed in Keychain
2. Notarization credentials stored:
   ```bash
   xcrun notarytool store-credentials AC_PASSWORD \
       --apple-id "your@email.com" \
       --team-id "8Q693ZG5RN" \
       --password "app-specific-password"
   ```

### Usage

```bash
./scripts/build.sh
```

Output: `CoreLocationCLI.zip` (signed and notarized app bundle)
