# How to make a release

1. Update version in `Info.plist`.

2. Create binaries, use ./scripts/build.sh

3. Draft the release using [GitHub Releases](https://github.com/fulldecent/corelocationcli/releases)

   1. Use SemVer
   2. Add that binary as attachment

4. Push to Homebrew, see [brew documentation](https://github.com/Homebrew/homebrew-cask/blob/master/CONTRIBUTING.md#updating-a-cask)

   ```sh
   # Get version
   VERSION=$(defaults read "$(pwd)/CoreLocationCLI.app/Contents/Info" CFBundleShortVersionString)
   
   brew bump-cask-pr --version $VERSION CoreLocationCLI
   ```
