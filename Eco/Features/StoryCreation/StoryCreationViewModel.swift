//
//  StoryCreationViewModel.swift
//  Eco
//
//  Created by Fernando Buenrostro on 03/03/26.
//

import Combine
import CoreLocation
import Foundation

@MainActor
class StoryCreationViewModel: ObservableObject {
    
    // Inputs
    @Published var title: String = ""
    @Published var content: String = ""
    
    // Operation Status
    @Published var isPlanting: Bool = false
    @Published var error: String?
    @Published var lastLocation: CLLocationCoordinate2D?
    
    private let plantUseCase: PlantStoryUseCase
    private var locationService: LocationServiceProtocol
    private var cancellable = Set<AnyCancellable>()
    
    var locationDisplayString: String {
        guard let location = lastLocation else {
            return "Buscando ubicación..."
        }
        
        return String(format: "Lat: %.4f, Lon: %.4f", location.latitude, location.longitude)
    }
    
    init(plantUseCase: PlantStoryUseCase, locationService: LocationServiceProtocol) {
        self.plantUseCase = plantUseCase
        self.locationService = locationService
        setupLocationSubscription()
    }
    
    func plantStory() async {
        // Validate coordinates.
        guard let location = lastLocation else {
            self.error = "Esperando señal del GPS..."
            return
        }
        
        isPlanting = true
        do {
            try await plantUseCase.execute(title: title,
                                           content: content,
                                           authorId: UUID(), // TODO: Id temporal hasta que tengamos auth
                                           latitude: location.latitude,
                                           longitude: location.longitude)
            isPlanting = false
        } catch {
            self.error = "No pudimos plantar tu Eco: \(error.localizedDescription)"
            isPlanting = false
        }
    }
}

extension StoryCreationViewModel: LocationServiceDelegate {
    
    func setupLocationSubscription() {
        locationService.delegate = self
        locationService.requestSingleLocation()
    }
    
    func didUpdateLocation(latitude: Double, longitude: Double) {
        self.lastLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func didFailWithError(_ error: any Error) {
        self.error = "No pudimos obtener tu ubicación: \(error.localizedDescription)"
    }
    
    func didEnterStoryRegion(id: UUID) {
        
    }
}
