# CoreLocationCLI

CoreLocationCLI gets the physical location of your device and prints it to standard output. If you move it will also print out your updated location. *Kill it with CTRL-C.*

![Usage](https://cloud.githubusercontent.com/assets/382183/25063655/52c11234-221d-11e7-81fb-0f8712dac393.gif)

Note for Mac users: make sure WiFi is turned on. Otherwise you will see `kCLErrorDomain error 0`.

# Usage

```sh
CoreLocationCLI -h
CoreLocationCLI [-once] -json
CoreLocationCLI [-once] [-verbose] [-format FORMAT]
```

| Switch           | Description                                            |
| ---------------- | ------------------------------------------------------ |
| `-h`             | Display this help message and exit                     |
| `-once`          | Print one location and exit                            |
| `-verbose`       | Verbose mode                                           |
| `-json`          | JSON output mode                                       |
| `-format FORMAT` | Print a formatted string with the following specifiers |

| Format         | Description                                    |
| -------------- | ---------------------------------------------- |
| `%%latitude`   | Latitude (degrees north; or negative for south |
| `%%longitude`  | Longitude (degrees west; or negative for east  |
| `%%altitude`   | Altitude (meters)                              |
| `%%direction`  | Degrees from true north                        |
| `%%speed`      | Meters per second                              |
| `%%h_accuracy` | Horizontal accuracy (meters)                   |
| `%%v_accuracy` | Vertical accuracy (meters)                     |
| `%%time`       | Time                                           |
| `%%address`    | Reverse geocoded location to an address        |

The default format if unspecified is: `%%latitude %%longitude`.

# Output examples

```sh
./CoreLocationCLI
```

> 50.943829 6.941043

```sh
./CoreLocationCLI -once yes -format "%latitude %longitude\n%address"
```

    50.943829 6.941043
    Kaiser-Wilhelm-Ring 21
    	Cologne North Rhine-Westphalia 50672
    	Germany

```sh
./CoreLocationCLI -json
```

```json
{"latitude":40.124159, "longitude":-75.036274}
```

# Installation

Install the latest release using Homebrew with:

```sh
brew cask install corelocationcli
```

Or build from the command line using the Xcode compiler:

```sh
xcodebuild
```

Then run your executable from this location:

```sh
build/Release/CoreLocationCLI
```
