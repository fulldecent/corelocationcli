//
//  main.swift
//  Core Location CLI
//
//  Created by William Entriken on 2016-01-12.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import Foundation
import CoreLocation

class Delegate: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var once = false
    var verbose = false
    var format: String? = nil
    
    func start() -> Void {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
        if self.verbose {
            print("authorizationStatus: \(CLLocationManager.authorizationStatus())")
            print("locationServicesEnabled: \(CLLocationManager.locationServicesEnabled())")
            print("significantLocationChangeMonitoringAvailable: \(CLLocationManager.significantLocationChangeMonitoringAvailable())")
            print("headingAvailable: \(CLLocationManager.headingAvailable())")
            print("regionMonitoringAvailable: \(CLLocationManager.regionMonitoringAvailable)")
        }
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation)
    {
        if let format = self.format {
            var output = format
            output = output.stringByReplacingOccurrencesOfString("%latitude", withString: "\(newLocation.coordinate.latitude)")
            output = output.stringByReplacingOccurrencesOfString("%longitude", withString: "\(newLocation.coordinate.longitude)")
            output = output.stringByReplacingOccurrencesOfString("%altitude", withString: "\(newLocation.altitude)")
            output = output.stringByReplacingOccurrencesOfString("%direction", withString: "\(newLocation.course)")
            output = output.stringByReplacingOccurrencesOfString("%speed", withString: "\(Int(newLocation.speed))")
            output = output.stringByReplacingOccurrencesOfString("%h_accuracy", withString: "\(Int(newLocation.horizontalAccuracy))")
            output = output.stringByReplacingOccurrencesOfString("%v_accuracy", withString: "\(Int(newLocation.verticalAccuracy))")
            output = output.stringByReplacingOccurrencesOfString("%time", withString: newLocation.timestamp.description)
            print(output)
        } else {
            print("\(newLocation.description)")
        }
        if self.once {
            exit(0)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("ERROR: \(error.localizedDescription)")
        exit(1)
    }
}

func help() {
    print("USAGE: CoreLocationCLI [options]")
    print("       Displays current location using CoreLocation services.")
    print("       By default, this will continue printing locations until you kill it with Ctrl-C.")
    print("")
    print("OPTIONS:")
    print("  -h               Display this help message and exit")
    print("")
    print("  -once YES        Print one location and exit")
    print("  -verbose YES     Verbose mode")
    print("  -format 'format' Print a formatted string with the following specifiers")
    print("     %%latitude")
    print("     %%longitude")
    print("     %%altitude    (meters)")
    print("     %%direction   (degrees from true north)")
    print("     %%speed       (meters per second)")
    print("     %%h_accuracy  (meters)")
    print("     %%v_accuracy  (meters)")
    print("     %%time")
    print("")
}

// Show help if requested
if Process.arguments.count > 0 && Process.arguments[0] == "-h" {
    help()
    exit(0)
}

let args = NSUserDefaults.standardUserDefaults()
let delegate = Delegate()
delegate.format = args.stringForKey("format")
delegate.verbose = args.boolForKey("verbose")
delegate.once = args.boolForKey("once")
delegate.start()

autoreleasepool({
    var runLoop: NSRunLoop = NSRunLoop.mainRunLoop()
    runLoop.run()
})