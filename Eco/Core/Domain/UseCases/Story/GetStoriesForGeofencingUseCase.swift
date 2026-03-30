//
//  GetStoriesForGeofencingUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Domain use case contract `GetStoriesForGeofencingUseCase` for Features - Data wiring.
//

import CoreLocation
import Foundation

/// Domain use case contract `GetStoriesForGeofencingUseCase` for Features - Data wiring.
protocol GetStoriesForGeofencingUseCaseProtocol {
    /// Nearest stories to the coordinate for geofence registration.
    /// iOS limits 20 active regions.
    func execute(near coordinate: CLLocationCoordinate2D, limit: Int) async throws -> [Story]
}
