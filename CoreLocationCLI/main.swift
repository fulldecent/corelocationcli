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
            print("authorizationStatus: \(CLLocationManager.authorizationStatus())")
            print("locationServicesEnabled: \(CLLocationManager.locationServicesEnabled())")
            print("deferredLocationUpdatesAvailable: \(CLLocationManager.deferredLocationUpdatesAvailable())")
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
        let formattedPostalAddress = placemark?.postalAddress == nil
            ? ""
            : CNPostalAddressFormatter.string(from: placemark!.postalAddress!, style: CNPostalAddressFormatterStyle.mailingAddress)

        // Attempt to infer timezone for timestamp string
        var locatedTime: String?
        if let locatedTimeZone = placemark?.timeZone {
            let time = location.timestamp

            let formatter = DateFormatter()
            formatter.timeZone = locatedTimeZone
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"

            locatedTime = formatter.string(from: time)
        }

        switch format {
        case .json:
            let outputObject: [String: String?] = [
                "latitude": String(format: "%0.6f", location.coordinate.latitude),
                "longitude": String(format: "%0.6f", location.coordinate.longitude),
                "altitude": String(format: "%0.2f", location.altitude),
                "direction": "\(location.course)",
                "speed": "\(Int(location.speed))",
                "h_accuracy": "\(Int(location.horizontalAccuracy))",
                "v_accuracy": "\(Int(location.verticalAccuracy))",
                "time": locatedTime ?? location.timestamp.description,

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

                // Address
                "address": formattedPostalAddress
            ]
            let encoder = JSONEncoder()
            print(String(data: try! encoder.encode(outputObject), encoding: .utf8)!)
        case .string(var output):
            output = output.replacingOccurrences(of: "%latitude", with: String(format: "%0.6f", location.coordinate.latitude))
            output = output.replacingOccurrences(of: "%longitude", with: String(format: "%0.6f", location.coordinate.longitude))
            output = output.replacingOccurrences(of: "%altitude", with: String(format: "%0.2f", location.altitude))
            output = output.replacingOccurrences(of: "%direction", with: "\(location.course)")
            output = output.replacingOccurrences(of: "%speed", with: "\(Int(location.speed))")
            output = output.replacingOccurrences(of: "%h_accuracy", with: "\(Int(location.horizontalAccuracy))")
            output = output.replacingOccurrences(of: "%v_accuracy", with: "\(Int(location.verticalAccuracy))")
            output = output.replacingOccurrences(of: "%time", with: locatedTime ?? location.timestamp.description)

            // Placemark
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

            // Address
            output = output.replacingOccurrences(of: "%address", with: formattedPostalAddress)
            print(output)
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
        print("LOCATION MANAGER ERROR: \(error.localizedDescription)")
        exit(1)
    }

    func help() {
        print("""
        USAGE: CoreLocationCLI -h
               CoreLocationCLI [-follow] [-verbose] [-format FORMAT]
               CoreLocationCLI [-follow] [-verbose] -json

               Displays current location using CoreLocation services
        
        OPTIONS:
          -h                       Display this help message and exit
          -follow YES              Continually print location
          -verbose YES             Show debugging output
          -format FORMAT           Print a string with these substitutions
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
          -json                    Prints a JSON object with all information available
        
          Default format if not specified is: %latitude %longitude.
          Using -json with -follow produces one line of JSON per location update. And is
          compatible with the JSON Lines text format.
        """)
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
            delegate.format = .string(ProcessInfo().arguments[i+1])
            let placemarkStrings = ["%address", "%name", "%isoCountryCode", "%country", "%postalCode", "%administrativeArea", "%subAdministrativeArea", "%locality", "%subLocality", "%thoroughfare", "%subThoroughfare", "%region", "%timeZone"]
            if placemarkStrings.contains(where:ProcessInfo().arguments[i+1].contains) {
                delegate.requiresPlacemarkLookup = true
            }
        }
    case "-json":
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
