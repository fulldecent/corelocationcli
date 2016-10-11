# Usage

`./CoreLocationCLI [-once]`

If running from a Mac, make sure your WiFi is turned on. Otherwise you will see `kCLErrorDomain error 0`.

# Overview

Prints location information from CoreLocation. If the `-once YES` option
is used, will exit after first location update. Otherwise, will
continuously print output. After you download, be sure to chmod 755
and run from Terminal.

```
USAGE: CoreLocationCLI [options]
       Displays current location using CoreLocation services.
       By default, this will continue printing locations until you kill it with Ctrl-C.

OPTIONS:
  -h               Display this help message and exit

  -once YES        Print one location and exit
  -verbose YES     Verbose mode
  -format 'format' Print a formatted string with the following specifiers
     %%latitude    Latitude (degrees north; or negative for south
     %%longitude   Longitude (degrees west; or negative for east
     %%altitude    Altitude (meters)
     %%direction   Degrees from true north
     %%speed       Meters per second
     %%h_accuracy  Horizontal accuracy (meters)
     %%v_accuracy  Vertical accuracy (meters)
     %%time        Time
     %%address     Reverse geocoded location to an address
  -json            Use the format {\"latitude\":%latitude, \"longitude\":%longitude}
                   Also implies -once

  Default format if unspecified is: %%latitude %%longitude
```

# Output example

./CoreLocationCLI

	50.943829 6.941043

./CoreLocationCLI -once yes -format "%latitude %longitude\n%address"

  50.943829 6.941043
  Kaiser-Wilhelm-Ring 21
	Cologne North Rhine-Westphalia 50672
	Germany

./CoreLocationCLI -json

  {"latitude":40.124159, "longitude":-75.036274}

# Building

To build this from the command line, run the compiler:

    xcodebuild

And then your executable can be run from this location:

    build/Release/CoreLocationCLI

# Contact

Contact corelocationcli@phor.net
