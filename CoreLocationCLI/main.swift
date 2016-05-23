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
    var format: String = "%latitude/%longitude (%address)"
    
    func start() -> Void {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
        if self.verbose {
            print("authorizationStatus: \(CLLocationManager.authorizationStatus())")
            print("locationServicesEnabled: \(CLLocationManager.locationServicesEnabled())")
            print("significantLocationChangeMonitoringAvailable: \(CLLocationManager.significantLocationChangeMonitoringAvailable())")
            print("headingAvailable: \(CLLocationManager.headingAvailable())")
            print("regionMonitoringAvailable for CLRegion: \(CLLocationManager.isMonitoringAvailableForClass(CLRegion))")
        }
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
        guard let newLocation = locations.first as? CLLocation else {
            return;
        }
        
        var output = self.format

        let helper : ((address: String)->Void) = { address in
            output = output.stringByReplacingOccurrencesOfString("%latitude", withString: "\(newLocation.coordinate.latitude)")
            output = output.stringByReplacingOccurrencesOfString("%longitude", withString: "\(newLocation.coordinate.longitude)")
            output = output.stringByReplacingOccurrencesOfString("%altitude", withString: "\(newLocation.altitude)")
            output = output.stringByReplacingOccurrencesOfString("%direction", withString: "\(newLocation.course)")
            output = output.stringByReplacingOccurrencesOfString("%speed", withString: "\(Int(newLocation.speed))")
            output = output.stringByReplacingOccurrencesOfString("%h_accuracy", withString: "\(Int(newLocation.horizontalAccuracy))")
            output = output.stringByReplacingOccurrencesOfString("%v_accuracy", withString: "\(Int(newLocation.verticalAccuracy))")
            output = output.stringByReplacingOccurrencesOfString("%time", withString: newLocation.timestamp.description)
            output = output.stringByReplacingOccurrencesOfString("%address", withString: address)

            print(output)
            
            if self.once {
                exit(0)
            }
            else {
                self.locationManager.startUpdatingLocation()
            }
        }
        

        if format.rangeOfString("%address") != nil {
            self.locationManager.stopUpdatingLocation()
            self.geoCoder.reverseGeocodeLocation(newLocation, completionHandler: { (placemarks, error) in
                if let postalAddress = placemarks?.first?.postalAddress {
                    let  str = CNPostalAddressFormatter.stringFromPostalAddress(postalAddress, style: CNPostalAddressFormatterStyle.MailingAddress)
                    helper(address:str)
                }
                else {
                    helper(address: "?")
                }
            })
            
        }
        else {
            helper(address:"")
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
    print("     %%address     (revsere geocode location)")
    print("")
    print("  the format defaults to '%%latitude/%%longitude (%%address)")
    print("")
}

// Show help if requested
if Process.arguments.count > 0 && Process.arguments[0] == "-h" {
    help()
    exit(0)
}

let args = NSUserDefaults.standardUserDefaults()
let delegate = Delegate()
if let format = args.stringForKey("format") {
    delegate.format = format
}
delegate.verbose = args.boolForKey("verbose")
delegate.once = args.boolForKey("once")
delegate.start()

autoreleasepool({
    var runLoop: NSRunLoop = NSRunLoop.mainRunLoop()
    runLoop.run()
})