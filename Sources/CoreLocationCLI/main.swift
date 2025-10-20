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

enum OutputFormat {
    case json
    case string(String)
}

class Delegate: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    var follow = false
    var verbose = false
    var format = OutputFormat.string("%latitude %longitude")
    var timeoutTimer: Timer? = nil
    var requiresPlacemarkLookup = false
    
    func start() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 2.0
        locationManager.delegate = self
        if verbose {
            print("locationServicesEnabled: \(CLLocationManager.locationServicesEnabled())")
            print("significantLocationChangeMonitoringAvailable: \(CLLocationManager.significantLocationChangeMonitoringAvailable())")
            print("headingAvailable: \(CLLocationManager.headingAvailable())")
            print("regionMonitoringAvailable for CLRegion: \(CLLocationManager.isMonitoringAvailable(for: CLRegion.self))")
        }
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false, block: {_ in self.timeout()})
        self.locationManager.startUpdatingLocation()
    }

    func timeout() {
        print("Fetching location timed out. Exiting.")
        exit(1)
    }
    
    func printFormattedLocation(location: CLLocation, placemark: CLPlacemark? = nil) {
        var formattedPostalAddress: String?
        if let postalAddress = placemark?.postalAddress {
            formattedPostalAddress = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
        }

        // Attempt to infer timezone for timestamp string
        var locatedTime: String?
        if let locatedTimeZone = placemark?.timeZone {
            let time = location.timestamp
            let formatter = DateFormatter()
            formatter.timeZone = locatedTimeZone
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            locatedTime = formatter.string(from: time)
        }
        
        let formattedParts: [String: String?] = [
            "latitude": String(format: "%0.6f", location.coordinate.latitude),
            "longitude": String(format: "%0.6f", location.coordinate.longitude),
            "altitude": String(format: "%0.2f", location.altitude),
            "direction": "\(location.course)",
            "speed": "\(Int(location.speed))",
            "h_accuracy": "\(Int(location.horizontalAccuracy))",
            "v_accuracy": "\(Int(location.verticalAccuracy))",
            "time": location.timestamp.description,

            // Placemark
            "name": placemark?.name,
            "isoCountryCode": placemark?.isoCountryCode,
            "country": placemark?.country,
            "postalCode": placemark?.postalCode,
            "administrativeArea": placemark?.administrativeArea,
            "subAdministrativeArea": placemark?.subAdministrativeArea,
            "locality": placemark?.locality,
            "subLocality": placemark?.subLocality,
            "thoroughfare": placemark?.thoroughfare,
            "subThoroughfare": placemark?.subThoroughfare,
            "region": placemark?.region?.identifier,
            "timeZone": placemark?.timeZone?.identifier,
            "time_local": locatedTime,

            // Address
            "address": formattedPostalAddress
        ]
        
        switch format {
        case .json:
            let output = try! JSONEncoder().encode(formattedParts)
            print(String(data: output, encoding: .utf8)!)
        case .string(let output):
            print(formattedParts.reduce(output, { partialResult, keyValuePair in
                partialResult.replacingOccurrences(of: "%\(keyValuePair.key)", with: keyValuePair.value ?? "")
            }))
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if self.verbose {
            print("Location authorization status: \(manager.authorizationStatus)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        timeoutTimer!.invalidate()
        let location = locations.first!
        if requiresPlacemarkLookup {
            self.geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if error != nil {
                    print("Reverse geocode failed: \(error?.localizedDescription ?? "unknown error")")
                    exit(1)
                }
                let placemark = placemarks?.first
                self.printFormattedLocation(location: location, placemark: placemark)
                if !self.follow {
                    exit(0)
                }
            })
        } else {
            printFormattedLocation(location: location)
            if !self.follow {
                exit(0)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if error._code == 1 {
            print("CoreLocationCLI: ❌ Location services are disabled or location access denied. Please visit System Settings > Privacy & Security > Location Services")
            exit(1)
        } 
        print("CoreLocationCLI: ❌ \(error.localizedDescription)")
        exit(1)
    }

    func help() {
        print("""
        USAGE: CoreLocationCLI --help
               CoreLocationCLI --version
               CoreLocationCLI [--watch] [--verbose] [--format FORMAT]
               CoreLocationCLI [--watch] [--verbose] --json

               Displays current location using CoreLocation services
        
        OPTIONS:
          -h, --help               Display this help message and exit
          -w, --watch              Continually print location
          -v, --verbose            Show debugging output
          -f, --format FORMAT      Print a string with these substitutions
            %latitude              Latitude (degrees north; or negative for south)
            %longitude             Longitude (degrees west; or negative for east)
            %altitude              Altitude (meters)
            %direction             Degrees from true north
            %speed                 Meters per second
            %h_accuracy            Horizontal accuracy (meters)
            %v_accuracy            Vertical accuracy (meters)
            %time                  Time
            %address               Reverse geocoded location to an address
            %name                  Reverse geocoded place name
            %isoCountryCode        Reverse geocoded ISO country code
            %country               Reverse geocoded country name
            %postalCode            Reverse geocoded postal code
            %administrativeArea    Reverse geocoded state or province
            %subAdministrativeArea Additional administrative area information
            %locality              Reverse geocoded city name
            %subLocality           Additional city-level information
            %thoroughfare          Reverse geocoded street address
            %subThoroughfare       Additional street-level information
            %region                Reverse geocoded geographic region
            %timeZone              Reverse geocoded time zone
            %time_local            Localized time using reverse geocoded time zone
          -j, --json               Prints a JSON object with all information available
        
          Default format if not specified is: %latitude %longitude.
          Using -json with -follow produces one line of JSON per location update. And is
          compatible with the JSON Lines text format.
        """)
    }

    func version() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        print("CoreLocationCLI version \(version)")
    }
}

let delegate = Delegate()
for (i, argument) in ProcessInfo().arguments.enumerated() {
    switch argument {
    case "-h", "--help":
        delegate.help()
        exit(0)
    case "--version":
        delegate.version()
        exit(0)
    case "-w", "--watch":
        delegate.follow = true
    case "-v", "--verbose":
        delegate.verbose = true
    case "-f", "--format":
        if ProcessInfo().arguments.count > i+1 {
            delegate.format = .string(ProcessInfo().arguments[i+1])
            let placemarkStrings = ["%address", "%name", "%isoCountryCode", "%country", "%postalCode", "%administrativeArea", "%subAdministrativeArea", "%locality", "%subLocality", "%thoroughfare", "%subThoroughfare", "%region", "%timeZone", "%time_local"]
            if placemarkStrings.contains(where:ProcessInfo().arguments[i+1].contains) {
                delegate.requiresPlacemarkLookup = true
            }
        }
    case "-j", "--json":
        delegate.format = .json
        delegate.requiresPlacemarkLookup = true
    default:
        break
    }
}

delegate.start()

autoreleasepool {
    RunLoop.main.run()
}
