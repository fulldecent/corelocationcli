# How To Make Releases

1. Draft the release using [GitHub Releases](https://github.com/fulldecent/corelocationcli/releases)

   1. Use SemVer

2. Create binaries

   1. ```sh
      swift build -c release
      ```

   2. ```sh
      ./.build/arm64-apple-macosx/debug/CoreLocationCLI --help
      ```

   3. Zip it using Finder

3. Copy that binary into the GitHub release

4. Push to Homebrew, see details [here](https://github.com/Homebrew/homebrew-cask/blob/master/CONTRIBUTING.md#updating-a-cask)

   1. ```sh
      brew bump-cask-pr --version 4.0.0 CoreLocationCLI
      ```
