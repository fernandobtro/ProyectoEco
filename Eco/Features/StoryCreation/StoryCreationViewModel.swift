//
//  StoryCreationViewModel.swift
//  Eco
//
//  Created by Fernando Buenrostro on 03/03/26.
//

import CoreLocation
import Foundation
import Observation

@MainActor
@Observable
class StoryCreationViewModel {
    
    // Inputs
    var title: String = ""
    var content: String = ""
    
    // Operation Status
    var isPlanting: Bool = false
    var error: String?
    var lastLocation: CLLocationCoordinate2D?
    
    private let plantUseCase: PlantStoryUseCaseProtocol
    private let getLocationUseCase: GetCurrentLocationForPlantingUseCaseProtocol
    
    var locationDisplayString: String {
        guard let location = lastLocation else {
            return "Buscando ubicación..."
        }
        return String(format: "Lat: %.4f, Lon: %.4f", location.latitude, location.longitude)
    }
    
    init(plantUseCase: PlantStoryUseCaseProtocol, getLocationUseCase: GetCurrentLocationForPlantingUseCaseProtocol) {
        self.plantUseCase = plantUseCase
        self.getLocationUseCase = getLocationUseCase
    }
    
    /// Llamar desde la vista en `.task { await viewModel.updateLocation() }`.
    func updateLocation() async {
        lastLocation = await getLocationUseCase.requestLocation()
    }
    
    func plantStory() async {
        guard let location = lastLocation else {
            self.error = "Esperando señal del GPS..."
            return
        }
        
        isPlanting = true
        defer { isPlanting = false }
        do {
            try await plantUseCase.execute(title: title,
                                           content: content,
                                           authorId: UUID(), // TODO: Id temporal hasta que tengamos auth
                                           latitude: location.latitude,
                                           longitude: location.longitude)
        } catch {
            self.error = "No pudimos plantar tu Eco: \(error.localizedDescription)"
        }
    }
}
