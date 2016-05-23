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
         %address	  (revsere geocode location)
	
      the format defaults to '%%latitude/%%longitude (%%address)
      
# Output example

./CoreLocationCLI


	50.9438299979853/6.94104380198676 (Kaiser-Wilhelm-Ring 21
	Cologne North Rhine-Westphalia 50672
	Germany)
    
./CoreLocationCLI -once yes -format '%latitude : %longitude'


	50.9438299979853 6.94104380198676
	
# Building

To build this from the command line, run the compiler:

    xcodebuild
    
And then your executable can be run from this location: 

    build/Release/CoreLocationCLI

# Contact

Contact corelocationcli@phor.net

