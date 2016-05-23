//
//  CLPlacemark+CNPostalAddress.swift
//
//  Created by Dominik Pich on 5/23/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import CoreLocation
import Contacts

extension CLPlacemark {
    var postalAddress : CNPostalAddress? {
        get {
            guard let addressdictionary = self.addressDictionary else {
                return nil
            }
            
            let address = CNMutablePostalAddress()
            address.street = addressdictionary["Street"] as? String ?? ""
            address.state = addressdictionary["State"] as? String ?? ""
            address.city = addressdictionary["City"] as? String ?? ""
            address.country = addressdictionary["Country"] as? String ?? ""
            address.postalCode = addressdictionary["ZIP"] as? String ?? ""
            return address
        }
    }
}