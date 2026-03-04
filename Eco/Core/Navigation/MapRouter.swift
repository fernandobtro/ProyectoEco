//
//  MapRouter.swift
//  Eco
//
//  Created by Fernando Buenrostro on 03/03/26.
//

import Combine
import Foundation
import SwiftUI

// MARK: - Destinations
enum MapDestination: Identifiable, Hashable {
    case createStory
    
    var id: String {
        switch self {
        case .createStory: return "createStory"
        }
    }
}

// MARK: - Router
class MapRouter: ObservableObject {
    @Published var sheetDestination: MapDestination?
    
    // Needed dependencies for building the view
    private let plantStoryUseCase: PlantStoryUseCase
    private let locationService: LocationServiceProtocol
    
    init(plantStoryUseCase: PlantStoryUseCase, locationService: LocationServiceProtocol) {
        self.plantStoryUseCase = plantStoryUseCase
        self.locationService = locationService
    }
    
    func navigateToCreateStory() {
        sheetDestination = .createStory
    }
    
    func dismissSheet() {
        sheetDestination = nil
    }
    
    // Factory Method
    @ViewBuilder
    func view(for destination: MapDestination) -> some View {
        switch destination {
        case .createStory:
            let viewModel = StoryCreationViewModel(plantUseCase: plantStoryUseCase, locationService: locationService)
            StoryCreationView(viewModel: viewModel)
        }
    }
}
