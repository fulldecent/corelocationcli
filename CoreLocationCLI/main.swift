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
    var follow = false
    var verbose = false
    var format = "%latitude %longitude"
    var exitAtTimeout = true
    var placemark: CLPlacemark?
    
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
    
    func printFormattedLocation(_ location: CLLocation) {
        var output = self.format
        if placemark != nil {
            if let postalAddress = placemark?.postalAddress {
                let formattedAddress = CNPostalAddressFormatter.string(from: postalAddress, style: CNPostalAddressFormatterStyle.mailingAddress)
                output = output.replacingOccurrences(of: "%address", with: formattedAddress)
            }
            output = output.replacingOccurrences(of: "%name", with: String(placemark?.name ?? ""))
            output = output.replacingOccurrences(of: "%isoCountryCode", with: String(placemark?.isoCountryCode ?? ""))
            output = output.replacingOccurrences(of: "%country", with: String(placemark?.country ?? ""))
            output = output.replacingOccurrences(of: "%postalCode", with: String(placemark?.postalCode ?? ""))
            output = output.replacingOccurrences(of: "%administrativeArea", with: String(placemark?.administrativeArea ?? ""))
            output = output.replacingOccurrences(of: "%subAdministrativeArea", with: String(placemark?.subAdministrativeArea ?? ""))
            output = output.replacingOccurrences(of: "%locality", with: String(placemark?.locality ?? ""))
            output = output.replacingOccurrences(of: "%subLocality", with: String(placemark?.subLocality ?? ""))
            output = output.replacingOccurrences(of: "%thoroughfare", with: String(placemark?.thoroughfare ?? ""))
            output = output.replacingOccurrences(of: "%subThoroughfare", with: String(placemark?.subThoroughfare ?? ""))
            output = output.replacingOccurrences(of: "%region", with: String(placemark?.region?.identifier ?? ""))
            output = output.replacingOccurrences(of: "%timeZone", with: String(placemark?.timeZone?.identifier ?? ""))
        }
        output = output.replacingOccurrences(of: "%latitude", with: String(format: "%0.6f", location.coordinate.latitude))
        output = output.replacingOccurrences(of: "%longitude", with: String(format: "%0.6f", location.coordinate.longitude))
        output = output.replacingOccurrences(of: "%altitude", with: String(format: "%0.2f", location.altitude))
        output = output.replacingOccurrences(of: "%direction", with: "\(location.course)")
        output = output.replacingOccurrences(of: "%speed", with: "\(Int(location.speed))")
        output = output.replacingOccurrences(of: "%h_accuracy", with: "\(Int(location.horizontalAccuracy))")
        output = output.replacingOccurrences(of: "%v_accuracy", with: "\(Int(location.verticalAccuracy))")
        output = output.replacingOccurrences(of: "%time", with: location.timestamp.description)

        print(output)
        if !self.follow {
            exit(0)
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            if self.verbose {
                print("Location access authorized.")
            }
        case .notDetermined:
            if self.verbose {
                print("Undetermined location access.")
            }
        case .denied:
            if self.verbose {
                print("User denied location access. Exiting.")
            }
            exit(1)
        case .restricted:
            if self.verbose {
                print("Location access restricted. Exiting.")
            }
            exit(1)
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        exitAtTimeout = false
        let location = locations.first!
        let formatStrings = ["%address", "%name", "%isoCountryCode", "%country", "%postalCode", "%administrativeArea", "%subAdministrativeArea", "%locality", "%subLocality", "%thoroughfare", "%subThoroughfare", "%region", "%timeZone"]
        if formatStrings.contains(where: format.contains) {
            self.locationManager.stopUpdatingLocation()
            self.geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if error != nil {
                    print("Reverse geocode failed: \(error?.localizedDescription ?? "unknown error")")
                }
                self.placemark = placemarks?.first
                self.locationManager.startUpdatingLocation()
                self.printFormattedLocation(location)
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
        print("  -h                       Display this help message and exit")
        print("")
        print("  -follow YES              Continually print location")
        print("  -verbose YES             Verbose mode")
        print("  -format 'format'         Print a formatted string with the")
        print("                             following specifiers")
        print("    %latitude              Latitude (degrees north; or negative for south")
        print("    %longitude             Longitude (degrees west; or negative for east")
        print("    %altitude              Altitude (meters)")
        print("    %direction             Degrees from true north")
        print("    %speed                 Meters per second")
        print("    %h_accuracy            Horizontal accuracy (meters)")
        print("    %v_accuracy            Vertical accuracy (meters)")
        print("    %time                  Time")
        print("    %address               Reverse geocoded location to an address")
        print("    %name                  Reverse geocoded place name")
        print("    %isoCountryCode        Reverse geocoded ISO country code")
        print("    %country               Reverse geocoded country name")
        print("    %postalCode            Reverse geocoded postal code")
        print("    %administrativeArea    Reverse geocoded state or province")
        print("    %subAdministrativeArea Additional administrative area information")
        print("    %locality              Reverse geocoded city name")
        print("    %subLocality           Additional city-level information")
        print("    %thoroughfare          Reverse geocoded street address")
        print("    %subThoroughfare       Additional street-level information")
        print("    %region                Reverse geocoded geographic region")
        print("    %timeZone              Reverse geocoded time zone")
        print("  -json                    Prints a JSON object with all information available")
        print("                           Also disables -follow")
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
    case "-follow":
        delegate.follow = true
    case "-verbose":
        delegate.verbose = true
    case "-format":
        if ProcessInfo().arguments.count > i+1 {
            delegate.format = ProcessInfo().arguments[i+1]
        }
    case "-json":
        delegate.follow = false
        delegate.format = "{"
        delegate.format.append("\n  \"latitude\": %latitude,")
        delegate.format.append("\n  \"longitude\": %longitude,")
        delegate.format.append("\n  \"altitude\": %altitude,")
        delegate.format.append("\n  \"direction\": %direction,")
        delegate.format.append("\n  \"speed\": %speed,")
        delegate.format.append("\n  \"h_accuracy\": %h_accuracy,")
        delegate.format.append("\n  \"v_accuracy\": %v_accuracy,")
        delegate.format.append("\n  \"time\": \"%time\",")
        delegate.format.append("\n  \"address\": \"%address\"")
        delegate.format.append("\n}")
    default:
        break
    }
}
delegate.start()

autoreleasepool {
    RunLoop.main.run()
}
