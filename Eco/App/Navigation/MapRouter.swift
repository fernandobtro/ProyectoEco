//
//  MapRouter.swift
//  Eco
//
//  Created by Fernando Buenrostro on 03/03/26.
//

import Foundation
import Observation
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
@Observable
class MapRouter {
    var sheetDestination: MapDestination?
    
    private let storyCreationViewFactory: () -> StoryCreationView?

    init(storyCreationViewFactory: @escaping () -> StoryCreationView?) {
        self.storyCreationViewFactory = storyCreationViewFactory
    }
    
    func navigateToCreateStory() {
        sheetDestination = .createStory
    }
    
    func dismissSheet() {
        sheetDestination = nil
    }
    
    @ViewBuilder
    func view(for destination: MapDestination) -> some View {
        switch destination {
        case .createStory:
            if let view = storyCreationViewFactory() {
                view
            } else {
                EmptyView()
            }
        }
    }
}
