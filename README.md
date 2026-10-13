# CoreLocationCLI

CoreLocationCLI gets the physical location of your device and prints it to standard output. If you move it can also print your updated location. *Kill it with CTRL-C.*

![Usage](https://cloud.githubusercontent.com/assets/382183/25063655/52c11234-221d-11e7-81fb-0f8712dac393.gif)

Note for Mac users: make sure Wi-Fi is turned on. Otherwise you will see `kCLErrorDomain error 0`.

## Usage

```sh
CoreLocationCLI --help
CoreLocationCLI --version
CoreLocationCLI [--watch] [--verbose] [--format FORMAT]
CoreLocationCLI [--watch] [--verbose] --json
```

| Switch            | Description                                        |
| ----------------- | -------------------------------------------------- |
| `-h`, `--help`    | Display this help message and exit                 |
| `--version`       | Display the program version                        |
| `-w`, `--watch`   | Continually print location updates                 |
| `-v`, `--verbose` | Show debugging output                              |
| `-f`, `--format`  | Print a string with the specified substitutions    |
| `-j`, `--json`    | Print a JSON object with all available information |

With the format specifiers:

| Format                   | Description                                         |
| ------------------------ | --------------------------------------------------- |
| `%latitude`              | Latitude (degrees north; negative for south)        |
| `%longitude`             | Longitude (degrees east; negative for west)         |
| `%altitude`              | Altitude in meters                                  |
| `%direction`             | Degrees from true north                             |
| `%speed`                 | Speed in meters per second                          |
| `%h_accuracy`            | Horizontal accuracy in meters                       |
| `%v_accuracy`            | Vertical accuracy in meters                         |
| `%time`                  | Timestamp of the location update                    |
| `%address`               | Reverse geocoded address                            |
| `%name`                  | Place name from reverse geocoding                   |
| `%isoCountryCode`        | ISO country code from reverse geocoding             |
| `%country`               | Country name from reverse geocoding                 |
| `%postalCode`            | Postal code from reverse geocoding                  |
| `%administrativeArea`    | State or province from reverse geocoding            |
| `%subAdministrativeArea` | Additional administrative area information          |
| `%locality`              | City name from reverse geocoding                    |
| `%subLocality`           | Additional city-level information                   |
| `%thoroughfare`          | Street address from reverse geocoding               |
| `%subThoroughfare`       | Additional street-level information                 |
| `%region`                | Geographic region from reverse geocoding            |
| `%timeZone`              | Time zone from reverse geocoding                    |
| `%time_local`            | Localized time using the reverse geocoded time zone |

**Note:** The default format is `%latitude %longitude`.

## Output examples

```sh
./CoreLocationCLI
```

> ```text
> 50.943829 6.941043
> ```

```sh
./CoreLocationCLI --format "%latitude %longitude\n%address"
```

> ```text
> 50.943829 6.941043
> Kaiser-Wilhelm-Ring 21
>  Cologne North Rhine-Westphalia 50672
>  Germany
> ```

```sh
./CoreLocationCLI --json
```

>```json
>{"address":"407 Keats Rd\nLower Moreland PA 19006\nUnited States","locality":"nLower Moreland","subThoroughfare":"407","time":"2019-10-03 04:10:05 +0000","subLocality":null,"administrativeArea":"PA","country":"United States","thoroughfare":"Keats Rd","region":"<+40.141196,-75.034815> radius 35.91","speed":"-1","latitude":"40.141196","name":"1354 Panther Rd","altitude":"92.00","timeZone":"America\/New_York","time_local": "2019-10-02 23:10:05 -0400","isoCountryCode":"US","longitude":"-75.034815","v_accuracy":"65","postalCode":"19006","direction":"-1.0","h_accuracy":"65","subAdministrativeArea":"Montgomery"}
>  ```

## Installation

Install the latest release using Homebrew with:

```sh
brew install --cask corelocationcli
```

Or build from the command line. See [RELEASE.md](./RELEASE.md).

## macOS Gatekeeper

The Homebrew cask installs the notarized GitHub release. Gatekeeper accepts that copy.

A dialog that says "CoreLocationCLI" can't be opened because it is from an unidentified developer means the copy was not that notarized release. Approve it in System Settings, Privacy & Security. See <https://support.apple.com/en-us/HT202491>.

## Project scope

This project exists to provide **a simple tool** for **getting a device's location**. It is expected that this will be **composed with other tools** or used directly for **testing** and **logging**.

The project maintainer was a victim of kidnapping in his past. Meanwhile his laptop was opened by the captors, at the time CoreLocation CLI could have helped to identify the location of his captors. Since then, he continues to maintain the software, he uses the software so it could collect evidence in this situation again, and he is more careful about not getting kidnapped.

## Contributing

Considering the project scope, please [report any issues](https://github.com/fulldecent/corelocationcli/issues) and [recommend a fix if possible](https://github.com/fulldecent/corelocationcli/pulls).

## Releasing

Use `fix:`, `feat:`, or `BREAKING CHANGE:` in commit messages. Release Please opens a pull request from those. Merging it publishes the notarized zip and `release.sigstore.jsonl`. The steps are in [RELEASE.md](RELEASE.md).

## References

1. Releases follow [best practices documented in swift-app-template](https://github.com/fulldecent/swift-app-template), release 1.1.0. Release Please uses the `simple` release type, a `VERSION` file, and the merged release pull request as the only publish trigger. `include-v-in-tag` is false, because the Homebrew cask downloads `releases/download/<version>/CoreLocationCLI.zip`. The template's tag is `v<version>`. This repository publishes the stapled zip. The template uploads an iOS build and a macOS build to TestFlight. The workflow creates the GitHub release after that build succeeds, which is the gate in that template's [release workflow](https://github.com/fulldecent/swift-app-template/blob/v1.1.0/.github/workflows/release.yml).
1. The release attestation follows [rust-template](https://github.com/fulldecent/rust-template) release 1.1.0. [actions/attest](https://github.com/actions/attest) signs `CoreLocationCLI.zip` twice. Passing no predicate selects [SLSA Provenance v1](https://slsa.dev/spec/v1.0/provenance). The second statement is `urn:version` with `{"version":"4.0.8"}`, and the version has no leading `v`. Both lines are `release.sigstore.jsonl`. Checking them follows [`gh attestation verify`](https://cli.github.com/manual/gh_attestation_verify). rust-template attests provenance in the build job. This repository attests both statements in the publish job, after notarization, because that is the only job that produces the zip.
