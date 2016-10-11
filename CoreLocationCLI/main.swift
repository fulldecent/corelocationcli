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
    let geoCoder = CLGeocoder()
    let locationManager = CLLocationManager()
    var once = false
    var verbose = false
    var format = "%latitude %longitude"
    var exitAtTimeout = true
    
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
        let _ = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.timeout), userInfo: nil, repeats: false)
        self.locationManager.startUpdatingLocation()
    }

    @objc func timeout() {
        if exitAtTimeout {
            print("Fetching location timed out. Exiting.")
            exit(1)
        }
    }
    
    func printFormattedLocation(_ location: CLLocation, address: String? = nil) {
        var output = self.format
        output = output.replacingOccurrences(of: "%latitude", with: String(format: "%0.6f", location.coordinate.latitude))
        output = output.replacingOccurrences(of: "%longitude", with: String(format: "%0.6f", location.coordinate.longitude))
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

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard verbose else {
            return
        }
        switch status {
        case .authorizedAlways:
            print("Location access authorized.")
        case .notDetermined:
            print("Undetermined location access.")
        case .denied:
            print("User denied location access. Exiting.")
            exit(1)
        case .restricted:
            print("Location access restricted. Exiting.")
            exit(1)
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        exitAtTimeout = false
        let location = locations.first!
        
        if format.range(of: "%address") != nil {
            self.locationManager.stopUpdatingLocation()
            self.geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if let postalAddress = placemarks?.first?.postalAddress {
                    let formattedAddress = CNPostalAddressFormatter.string(from: postalAddress, style: CNPostalAddressFormatterStyle.mailingAddress)
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LOCATION MANAGER ERROR: \(error.localizedDescription)")
        exit(1)
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
        print("     %%latitude    Latitude (degrees north; or negative for south")
        print("     %%longitude   Longitude (degrees west; or negative for east")
        print("     %%altitude    Altitude (meters)")
        print("     %%direction   Degrees from true north")
        print("     %%speed       Meters per second")
        print("     %%h_accuracy  Horizontal accuracy (meters)")
        print("     %%v_accuracy  Vertical accuracy (meters)")
        print("     %%time        Time")
        print("     %%address     Reverse geocoded location to an address")
        print("  -json            Use the format {\"latitude\":%latitude, \"longitude\":%longitude}")
        print("                   Also implies -once")
        print("")
        print("  Default format if unspecified is: %%latitude %%longitude")
        print("")
    }
}

let delegate = Delegate()
for (i, argument) in ProcessInfo().arguments.enumerated() {
    switch argument {
    case "-h":
        delegate.help()
        exit(0)
    case "-once":
        delegate.once = true
    case "-verbose":
        delegate.verbose = true
    case "-format":
        if ProcessInfo().arguments.count > i+1 {
            delegate.format = ProcessInfo().arguments[i+1]
        }
    case "-json":
        delegate.once = true
        delegate.format = "{\"latitude\":%latitude, \"longitude\":%longitude}"
    default:
        break
    }
}
delegate.start()

autoreleasepool {
    RunLoop.main.run()
}
