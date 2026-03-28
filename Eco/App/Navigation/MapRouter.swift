//
//  MapRouter.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Coordinates map sheets for creating a story and opening the reader from the map.
//
//  Responsibilities:
//  - Track the active sheet, reader dismiss behavior, and the last planting result for the map flow.
//  - Build sheet content from factories so the router stays small and testable.
//

import Foundation
import Observation
import CoreLocation
import SwiftUI

// MARK: - Routes
enum MapDestination: Identifiable, Hashable {
    case createStory
    case storyDetail(UUID)

    var id: String {
        switch self {
        case .createStory: return "createStory"
        case .storyDetail(let uuid): return "storyDetail-\(uuid.uuidString)"
        }
    }
}

// MARK: - Router
@Observable
class MapRouter {
    // MARK: - Navigation state
    /// The sheet shown on the map, or nil when nothing is presented.
    var sheetDestination: MapDestination?

    private var storyReaderSheetWasPresented = false

    private var recentPlanting: (coordinate: CLLocationCoordinate2D, storyId: UUID)?
    private let storyCreationViewFactory: (@escaping (CLLocationCoordinate2D, UUID) -> Void) -> StoryCreationView?
    private let makeStoryDetailViewModel: (UUID) -> StoryDetailViewModel
    private let authorProfileByIdUseCase: GetAuthorProfileByIdUseCaseProtocol

    // MARK: - Init
    init(
        storyCreationViewFactory: @escaping (@escaping (CLLocationCoordinate2D, UUID) -> Void) -> StoryCreationView?,
        makeStoryDetailViewModel: @escaping (UUID) -> StoryDetailViewModel,
        authorProfileByIdUseCase: GetAuthorProfileByIdUseCaseProtocol
    ) {
        self.storyCreationViewFactory = storyCreationViewFactory
        self.makeStoryDetailViewModel = makeStoryDetailViewModel
        self.authorProfileByIdUseCase = authorProfileByIdUseCase
    }

    // MARK: - Public navigation methods
    func navigateToCreateStory() {
        storyReaderSheetWasPresented = false
        sheetDestination = .createStory
    }

    func navigateToStoryDetail(id: UUID) {
        storyReaderSheetWasPresented = true
        sheetDestination = .storyDetail(id)
    }

    func dismissSheet() {
        sheetDestination = nil
    }

    func consumeStoryReaderSheetDismissed() -> Bool {
        let wasReader = storyReaderSheetWasPresented
        storyReaderSheetWasPresented = false
        return wasReader
    }

    /// Returns the last planting result once, then clears it.
    func consumeRecentPlanting() -> (coordinate: CLLocationCoordinate2D, storyId: UUID)? {
        defer { recentPlanting = nil }
        return recentPlanting
    }

    /// Builds the sheet content for a destination using the factories from `init`.
    @ViewBuilder
    func view(for destination: MapDestination) -> some View {
        switch destination {
        case .createStory:
            if let view = storyCreationViewFactory({ [weak self] coordinate, storyId in
                self?.recentPlanting = (coordinate: coordinate, storyId: storyId)
            }) {
                view
            } else {
                EmptyView()
            }
        case .storyDetail(let storyId):
            MapPresentedStoryDetailView(
                storyId: storyId,
                makeViewModel: makeStoryDetailViewModel,
                authorProfileByIdUseCase: authorProfileByIdUseCase
            )
        }
    }
}

// MARK: - Sheet wrapper (story detail)
private struct MapPresentedStoryDetailView: View {
    let authorProfileByIdUseCase: GetAuthorProfileByIdUseCaseProtocol
    @State private var viewModel: StoryDetailViewModel

    @Environment(\.dismiss) private var dismiss

    init(
        storyId: UUID,
        makeViewModel: @escaping (UUID) -> StoryDetailViewModel,
        authorProfileByIdUseCase: GetAuthorProfileByIdUseCaseProtocol
    ) {
        self.authorProfileByIdUseCase = authorProfileByIdUseCase
        _viewModel = State(initialValue: makeViewModel(storyId))
    }

    var body: some View {
        NavigationStack {
            MapStoryReaderView(
                viewModel: viewModel,
                authorProfileByIdUseCase: authorProfileByIdUseCase
            )
            .navigationTitle("Eco")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
