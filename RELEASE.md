# How to make a release

Use `fix:`, `feat:`, or `BREAKING CHANGE:` in the commit message. Release Please opens a pull request from those commits. `ci:` and `chore:` do not. The pull request updates [VERSION](VERSION), `CFBundleShortVersionString` in [Info.plist](Info.plist), and [CHANGELOG.md](CHANGELOG.md). Do not edit those version lines by hand.

Merging that pull request is the release. GitHub Actions builds the universal binary, signs it with the Developer ID Application certificate, notarizes it, staples the ticket, and publishes `CoreLocationCLI.zip` on a GitHub release. The tag is the version with no `v` prefix. The [Homebrew cask](https://github.com/Homebrew/homebrew-cask/blob/master/Casks/c/corelocationcli.rb) downloads `https://github.com/fulldecent/corelocationcli/releases/download/<version>/CoreLocationCLI.zip`.

`--version` reads `CFBundleShortVersionString` from the app bundle. There is no version literal in the Swift source.

Homebrew's [BrewTestBot](https://docs.brew.sh/Autobump) opens the cask pull request after the GitHub release exists. This cask is on that autobump list, so `brew bump-cask-pr` refuses it.

The notary credential is a team API key with the Developer role. An individual key cannot call `notarytool`, and a team key cannot be limited to one app. The Developer ID certificate is a separate secret. The repository secrets are:

* `APP_STORE_CONNECT_KEY`
* `APP_STORE_CONNECT_KEY_ID`
* `APP_STORE_CONNECT_ISSUER_ID`
* `DEVELOPER_ID_APPLICATION_P12` (base64 of the Developer ID Application `.p12`)
* `DEVELOPER_ID_APPLICATION_P12_PASSWORD`

A local build still uses [scripts/build.sh](scripts/build.sh). Store a notarytool keychain profile named `AC_PASSWORD`, or set `APP_STORE_CONNECT_KEY_PATH`, `APP_STORE_CONNECT_KEY_ID`, and `APP_STORE_CONNECT_ISSUER_ID`.

Release Please is configured the way [swift-app-template](https://github.com/fulldecent/swift-app-template) release 1.1.0 configures it, with two differences. `include-v-in-tag` is false, because this cask's URL has no `v`. The workflow publishes the stapled zip instead of uploading to TestFlight. The same "create the GitHub release after the build succeeds" gate is the one in [8 Ball Answer](https://github.com/fulldecent/8-ball-answer/blob/main/.github/workflows/release.yml).
