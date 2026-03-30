//
//  Story+Distance.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 18/03/26.
//
//  Purpose: Distance helpers for `Story` and map/collection copy.
//

import CoreLocation
import Foundation

/// Distance helpers for `Story` and map/collection copy.
extension Story {
    /// Distance in meters to the given coordinate.
    func distance(to location: CLLocation) -> CLLocationDistance {
        let storyLocation = CLLocation(latitude: latitude, longitude: longitude)
        return storyLocation.distance(from: location)
    }
}
