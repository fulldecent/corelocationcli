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
            print("regionMonitoringAvailable for CLRegion: \(CLLocationManager.isMonitoringAvailable(for: CLRegion.self))")
        }
        self.locationManager.startUpdatingLocation()
    }
    
    func printFormattedLocation(location: CLLocation, address: String? = nil) {
        var output = self.format
        output = output.replacingOccurrences(of: "%latitude", with: String(format: "%+.6f", location.coordinate.latitude))
        output = output.replacingOccurrences(of: "%longitude", with: String(format: "%+.6f", location.coordinate.longitude))
        output = output.replacingOccurrences(of: "%altitude", with: "\(location.altitude)")
        output = output.replacingOccurrences(of: "%direction", with: "\(location.course)")
        output = output.replacingOccurrences(of: "%speed", with: "\(Int(location.speed))")
        output = output.replacingOccurrences(of: "%h_accuracy", with: "\(Int(location.horizontalAccuracy))")
        output = output.replacingOccurrences(of: "%v_accuracy", with: "\(Int(location.verticalAccuracy))")
        output = output.replacingOccurrences(of: "%time", with: location.timestamp.description)
        if let address = address {
            output = output.replacingOccurrences(of: "%address", with: address)
        }
        print(output)
        if self.once {
            exit(0)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
        
        if format.range(of: "%address") != nil {
            self.locationManager.stopUpdatingLocation()
            self.geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if let postalAddress = placemarks?.first?.postalAddress {
                    let formattedAddress = CNPostalAddressFormatter.string(from: postalAddress, style: CNPostalAddressFormatterStyle.mailingAddress)
                    self.printFormattedLocation(location: location, address: formattedAddress)
                }
                else {
                    self.printFormattedLocation(location: location, address: "?")
                }
                self.locationManager.startUpdatingLocation()
            })
        } else {
            printFormattedLocation(location: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
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
for (i, argument) in ProcessInfo().arguments.enumerated() {
    switch argument {
    case "-h":
        help()
        exit(0)
    case "-once":
        delegate.once = true
    case "-verbose":
        delegate.verbose = true
    case "-format":
        if ProcessInfo().arguments.count > i+1 {
            delegate.format = ProcessInfo().arguments[i+1]
        }
    default:
        break
    }
}
delegate.start()

autoreleasepool {
    RunLoop.main.run()
}
