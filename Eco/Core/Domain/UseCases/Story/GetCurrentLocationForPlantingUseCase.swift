//
//  GetCurrentLocationForPlantingUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 03/03/26.
//

import CoreLocation
import Foundation

protocol GetCurrentLocationForPlantingUseCaseProtocol {
    /// Solicita una ubicación y devuelve cuando está disponible (o nil si falla/timeout).
    func requestLocation() async -> CLLocationCoordinate2D?
}
