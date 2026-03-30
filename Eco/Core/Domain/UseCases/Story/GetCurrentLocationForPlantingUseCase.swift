//
//  GetCurrentLocationForPlantingUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 03/03/26.
//
//  Purpose: Domain use case contract `GetCurrentLocationForPlantingUseCase` for Features - Data wiring.
//

import CoreLocation
import Foundation

/// Domain use case contract `GetCurrentLocationForPlantingUseCase` for Features - Data wiring.
protocol GetCurrentLocationForPlantingUseCaseProtocol {
    /// Requests one fix and returns when available (`nil` on failure or timeout).
    func requestLocation() async -> CLLocationCoordinate2D?
}
