//
//  main.swift
//  Core Location CLI
//
//  Created by William Entriken on 2016-01-12.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import Foundation
import CoreLocation
import Contacts

class Delegate: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    
    var once = false
    var verbose = false
    var format = "%latitude %longitude"
    
    func start() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 2.0
        self.locationManager.delegate = self
        if self.verbose {
            print("authorizationStatus: \(CLLocationManager.authorizationStatus())")
            print("locationServicesEnabled: \(CLLocationManager.locationServicesEnabled())")
            print("deferredLocationUpdatesAvailable: \(CLLocationManager.deferredLocationUpdatesAvailable())")
            print("significantLocationChangeMonitoringAvailable: \(CLLocationManager.significantLocationChangeMonitoringAvailable())")
            print("headingAvailable: \(CLLocationManager.headingAvailable())")
            print("regionMonitoringAvailable for CLRegion: \(CLLocationManager.isMonitoringAvailableForClass(CLRegion))")
        }
        self.locationManager.startUpdatingLocation()
    }
    
    func printFormattedLocation(location: CLLocation, address: String? = nil) {
        var output = self.format
        output = output.stringByReplacingOccurrencesOfString("%latitude", withString: String(format: "%+.6f", location.coordinate.latitude))
        output = output.stringByReplacingOccurrencesOfString("%longitude", withString: String(format: "%+.6f", location.coordinate.longitude))
        output = output.stringByReplacingOccurrencesOfString("%altitude", withString: "\(location.altitude)")
        output = output.stringByReplacingOccurrencesOfString("%direction", withString: "\(location.course)")
        output = output.stringByReplacingOccurrencesOfString("%speed", withString: "\(Int(location.speed))")
        output = output.stringByReplacingOccurrencesOfString("%h_accuracy", withString: "\(Int(location.horizontalAccuracy))")
        output = output.stringByReplacingOccurrencesOfString("%v_accuracy", withString: "\(Int(location.verticalAccuracy))")
        output = output.stringByReplacingOccurrencesOfString("%time", withString: location.timestamp.description)
        if let address = address {
            output = output.stringByReplacingOccurrencesOfString("%address", withString: address)
        }
        print(output)
        if self.once {
            exit(0)
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
        let location = locations.first as! CLLocation
        
        if format.rangeOfString("%address") != nil {
            self.locationManager.stopUpdatingLocation()
            self.geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if let postalAddress = placemarks?.first?.postalAddress {
                    let formattedAddress = CNPostalAddressFormatter.stringFromPostalAddress(postalAddress, style: CNPostalAddressFormatterStyle.MailingAddress)
                    self.printFormattedLocation(location, address: formattedAddress)
                }
                else {
                    self.printFormattedLocation(location, address: "?")
                }
                self.locationManager.startUpdatingLocation()
            })
        } else {
            printFormattedLocation(location)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("LOCATION MANAGER ERROR: \(error.localizedDescription)")
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
    print("     %%address     (revsere geocode location)")
    print("")
    print("  the format defaults to '%%latitude/%%longitude (%%address)")
    print("")
}

let delegate = Delegate()
for (i, argument) in Process.arguments.enumerate() {
    switch argument {
    case "-h":
        help()
        exit(0)
    case "-once":
        delegate.once = true
    case "-verbose":
        delegate.verbose = true
    case "-format":
        if Process.arguments.count > i+1 {
            delegate.format = Process.arguments[i+1]
        }
    default:
        break
    }
}
delegate.start()

autoreleasepool({
    var runLoop: NSRunLoop = NSRunLoop.mainRunLoop()
    runLoop.run()
})