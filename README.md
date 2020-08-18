# CoreLocationCLI

CoreLocationCLI gets the physical location of your device and prints it to standard output. If you move it can also print your updated location. *Kill it with CTRL-C.*

![Usage](https://cloud.githubusercontent.com/assets/382183/25063655/52c11234-221d-11e7-81fb-0f8712dac393.gif)

Note for Mac users: make sure Wi-Fi is turned on. Otherwise you will see `kCLErrorDomain error 0`.

## Usage

```sh
CoreLocationCLI -h
CoreLocationCLI [-follow] [-verbose] [-format FORMAT]
CoreLocationCLI [-follow] [-verbose] -json
```

| Switch           | Description                                            |
| ---------------- | ------------------------------------------------------ |
| `-h`             | Display this help message and exit                     |
| `-follow`        | Continually print location                             |
| `-verbose`       | Show debugging output                                  |
| `-format FORMAT` | Print a formatted string with the following specifiers |
| `-json`          | JSON output mode                                       |

| Format         | Description                              |
| -------------- | ---------------------------------------- |
| `%latitude`   | Latitude (degrees north; or negative for south) |
| `%longitude`  | Longitude (degrees west; or negative for east) |
| `%altitude`   | Altitude (meters)                        |
| `%direction`  | Degrees from true north                  |
| `%speed`      | Meters per second                        |
| `%h_accuracy` | Horizontal accuracy (meters)             |
| `%v_accuracy` | Vertical accuracy (meters)               |
| `%time`       | Time                                     |
| `%address`    | Reverse geocoded location to an address  |
| `%name`       | Reverse geocoded place name |
| `%isoCountryCode` | Reverse geocoded ISO country code |
| `%country` | Reverse geocoded country name |
| `%postalCode` | Reverse geocoded postal code |
| `%administrativeArea` | Reverse geocoded state or province |
| `%subAdministrativeArea` | additional administrative area information |
| `%locality` | Reverse geocoded city name |
| `%subLocality` | additional city-level information |
| `%thoroughfare` | Reverse geocoded street address |
| `%subThoroughfare` | additional street-level information |
| `%region` | Reverse geocoded geographic region |
| `%timeZone` | Reverse geocoded time zone |
| `%time_local` | Localized time using reverse geocoded time zone |

The default format is: `%latitude %longitude`.

## Output examples

```sh
./CoreLocationCLI
```

> ```
> 50.943829 6.941043
> ```

```sh
./CoreLocationCLI -format "%latitude %longitude\n%address"
```

> ```
> 50.943829 6.941043
> Kaiser-Wilhelm-Ring 21
> 	Cologne North Rhine-Westphalia 50672
> 	Germany
> ```

```sh
./CoreLocationCLI -json
```

>```json
>{"address":"407 Keats Rd\nLower Moreland PA 19006\nUnited States","locality":"nLower Moreland","subThoroughfare":"407","time":"2019-10-03 04:10:05 +0000","subLocality":null,"administrativeArea":"PA","country":"United States","thoroughfare":"Keats Rd","region":"<+40.141196,-75.034815> radius 35.91","speed":"-1","latitude":"40.141196","name":"1354 Panther Rd","altitude":"92.00","timeZone":"America\/New_York","time_local": "2019-10-02 23:10:05 -0400","isoCountryCode":"US","longitude":"-75.034815","v_accuracy":"65","postalCode":"19006","direction":"-1.0","h_accuracy":"65","subAdministrativeArea":"Montgomery"}
>  ```

## Installation

Install the latest release using Homebrew with:

```sh
brew cask install corelocationcli
```

Or build from the command line using the Xcode compiler with one of these commands:

```sh
xcodebuild # requires Apple Developer account
# ... or ...
swift build --disable-sandbox -c release --static-swift-stdlib # does not require account
```

Then run your executable from this location:

```sh
build/Release/CoreLocationCLI
```

## Project scope

This project exists to provide **a simple tool** for **getting a device's location**. It is expected that this will be **composed with other tools** or used directly for **testing** and **logging**.

The project maintainer was a victim of kidnapping in his past. Meanwhile his laptop was opened by the captors, at the time CoreLocation CLI could have helped to identify the location of his captors. Since then, he continues to maintain the software, he uses the software so it could collect evidence in this situation again, and he is more careful about not getting kidnapped.

## Contributing

Considering the project scope, please report any issues at https://github.com/fulldecent/corelocationcli/issues and recommend a fix if possible.

You can fund the project maintainer at https://github.com/sponsors/fulldecent. Even the most modest contribution will surely be noticed.

