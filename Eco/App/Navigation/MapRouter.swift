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
    
    private let plantStoryUseCase: PlantStoryUseCaseProtocol
    private let getLocationForPlantingUseCase: GetCurrentLocationForPlantingUseCaseProtocol

    init(plantStoryUseCase: PlantStoryUseCaseProtocol, getLocationForPlantingUseCase: GetCurrentLocationForPlantingUseCaseProtocol) {
        self.plantStoryUseCase = plantStoryUseCase
        self.getLocationForPlantingUseCase = getLocationForPlantingUseCase
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
            let viewModel = StoryCreationViewModel(plantUseCase: plantStoryUseCase, getLocationUseCase: getLocationForPlantingUseCase)
            StoryCreationView(viewModel: viewModel)
        }
    }
}
