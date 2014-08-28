# Usage

`./CoreLocationCLI [-once]`

If running from a Mac, make sure your WiFi is turned on. Otherwise you will see `kCLErrorDomain error 0`.

# Overview

Prints location information from CoreLocation. If the `-once` option
is used, will exit after first location update. Otherwise, will
continuously print output. After you download, be sure to chmod 755
and run from Terminal.

# Output example

    ./CoreLocationCLI 
    <+39.96034992, -75.18981059> +/- 154.00m (speed -1.00 mps / course -1.00) @ 2010-07-30 12:35:01 -0400
    <+39.96036986, -75.18980353> +/- 157.00m (speed 0.00 mps / course -1.00) @ 2010-07-30 12:35:40 -0400
    <+39.96036986, -75.18980353> +/- 157.00m (speed 0.00 mps / course -1.00) @ 2010-07-30 12:35:48 -0400^C

# Building

To build this from the command line, run the compiler:

    xcodebuild
    
And then your executable can be run from this location: 

    build/Release/CoreLocationCLI

# Contact

Contact corelocationcli@phor.net

