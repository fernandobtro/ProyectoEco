//
//  Story+Distance.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 18/03/26.
//

import CoreLocation
import Foundation

extension Story {
    /// Distancia en metros hasta la ubicación dada.
    func distance(to location: CLLocation) -> CLLocationDistance {
        let storyLocation = CLLocation(latitude: latitude, longitude: longitude)
        return storyLocation.distance(from: location)
    }
}
