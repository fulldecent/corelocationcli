# How To Make Releases

1. Create binaries

   ```sh
   swift build -c release
   ./.build/release/CoreLocationCLI --help
   cp ./.build/release/CoreLocationCLI .
   zip CoreLocationCLI.zip CoreLocationCLI
   ```

2. Draft the release using [GitHub Releases](https://github.com/fulldecent/corelocationcli/releases)

   1. Use SemVer
   2. Add that binary as attachment

3. Push to Homebrew, see details [here](https://github.com/Homebrew/homebrew-cask/blob/master/CONTRIBUTING.md#updating-a-cask)

   1. ```sh
      brew bump-cask-pr --version 4.0.1 CoreLocationCLI
      ```

