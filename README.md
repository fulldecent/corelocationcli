# Usage

`./CoreLocationCLI [-once]`

If running from a Mac, make sure your WiFi is turned on. Otherwise you will see `kCLErrorDomain error 0`.

# Overview

Prints location information from CoreLocation. If the `-once YES` option
is used, will exit after first location update. Otherwise, will
continuously print output. After you download, be sure to chmod 755
and run from Terminal.

    USAGE: CoreLocationCLI [options]
           Displays current location using CoreLocation services.
           By default, this will continue printing locations until you kill it with Ctrl-C.
    
    OPTIONS:
      -h               Display this help message and exit
    
      -once YES        Print one location and exit
      -verbose YES     Verbose mode
      -format 'format' Print a formatted string with the following specifiers
         %latitude
         %longitude
         %altitude    (meters)
         %direction   (degrees from true north)
         %speed       (meters per second)
         %h_accuracy  (meters)
         %v_accuracy  (meters)
         %time

# Output example

    ./CoreLocationCLI 
    <+39.96034992, -75.18981059> +/- 154.00m (speed -1.00 mps / course -1.00) @ 2010-07-30 12:35:01 -0400
    <+39.96036986, -75.18980353> +/- 157.00m (speed 0.00 mps / course -1.00) @ 2010-07-30 12:35:40 -0400
    <+39.96036986, -75.18980353> +/- 157.00m (speed 0.00 mps / course -1.00) @ 2010-07-30 12:35:48 -0400^C
    
    ./CoreLocationCLI -once yes -format '%latitude : %longitude'
    39.96036986 : -75.18980353

# Building

To build this from the command line, run the compiler:

    xcodebuild
    
And then your executable can be run from this location: 

    build/Release/CoreLocationCLI

# Contact

Contact corelocationcli@phor.net

