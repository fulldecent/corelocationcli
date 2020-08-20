# How To Make Releases

1. Draft the release using [GitHub Releases](https://github.com/fulldecent/corelocationcli/releases)

   1. Use SemVer

2. Create binaries

   1. ```sh
      xcodebuild
      ```

   2. ```sh
      build/Release/CoreLocationCLI -h
      ```

   3. Zip it using Finder

3. Copy that binary into the GitHub release

4. Push to Homebrew cask

   1. I forget how to do this, but see https://github.com/caskroom/homebrew-cask/pull/31827/files
