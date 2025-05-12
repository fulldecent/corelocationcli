# How to make a release

1. Create binaries

   ```sh
   swift build -c release --arch arm64 --arch x86_64
   
   # Package as app
   mkdir -p CoreLocationCLI.app/Contents/MacOS/
   cp ./.build/apple/Products/Release/CoreLocationCLI CoreLocationCLI.app/Contents/MacOS/
   cp Info.plist CoreLocationCLI.app/Contents
   codesign --force --deep --sign - CoreLocationCLI.app
   
   # Test it
   ./CoreLocationCLI.app/Contents/MacOS/CoreLocationCLI --json
   
   # Bundle it
   zip -r CoreLocationCLI.zip CoreLocationCLI.app
   ```

1. Draft the release using [GitHub Releases](https://github.com/fulldecent/corelocationcli/releases)

   1. Use SemVer
   2. Add that binary as attachment

2. Push to Homebrew, see [brew documentation](https://github.com/Homebrew/homebrew-cask/blob/master/CONTRIBUTING.md#updating-a-cask)

   ```sh
   # Get version
   VERSION=$(defaults read "$(pwd)/CoreLocationCLI.app/Contents/Info" CFBundleShortVersionString)
   
   brew bump-cask-pr --version $VERSION CoreLocationCLI
   ```
