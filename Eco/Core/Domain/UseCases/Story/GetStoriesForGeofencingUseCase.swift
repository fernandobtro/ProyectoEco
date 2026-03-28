//
//  GetStoriesForGeofencingUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//

import CoreLocation
import Foundation

protocol GetStoriesForGeofencingUseCaseProtocol {
    /// Devuelve las historias más cercanas a la coordenada para monitoreo por geofencing.
    /// iOS limita ~20 regiones activas.
    func execute(near coordinate: CLLocationCoordinate2D, limit: Int) async throws -> [Story]
}
