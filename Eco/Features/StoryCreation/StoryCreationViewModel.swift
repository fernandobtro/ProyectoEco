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
    private let syncStoriesUseCase: SyncStoriesUseCase
    
    var locationDisplayString: String {
        guard let location = lastLocation else {
            return "Buscando ubicación..."
        }
        return String(format: "Lat: %.4f, Lon: %.4f", location.latitude, location.longitude)
    }
    
    init(
        plantUseCase: PlantStoryUseCaseProtocol,
        getLocationUseCase: GetCurrentLocationForPlantingUseCaseProtocol,
        syncStoriesUseCase: SyncStoriesUseCase
    ) {
        self.plantUseCase = plantUseCase
        self.getLocationUseCase = getLocationUseCase
        self.syncStoriesUseCase = syncStoriesUseCase
    }
    
    /// Llamar desde la vista en `.task { await viewModel.updateLocation() }`.
    func updateLocation() async {
        lastLocation = await getLocationUseCase.requestLocation()
    }
    
    func plantStory() async {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanTitle.isEmpty, !cleanContent.isEmpty else {
            self.error = "El Título y la historia no pueden estar vacíos."
            return
        }
        
        guard let location = lastLocation else {
            self.error = "Esperando señal del GPS..."
            return
        }
        
        isPlanting = true
        defer { isPlanting = false }
        
        do {
            try await plantUseCase.execute(
                title: cleanTitle,
                content: cleanContent,
                latitude: location.latitude,
                longitude: location.longitude
            )
            await syncStoriesUseCase.execute()

            self.title = ""
            self.content = ""
            self.error = nil
        } catch {
            self.error = "No pudimos plantar tu Eco: \(error.localizedDescription)"
        }
    }
}
