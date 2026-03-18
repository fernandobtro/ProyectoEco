//
//  CollectionViewModel.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation
import Observation

enum CollectionTab {
    case planted
    case discovered
}

enum CollectionState: Equatable {
    case idle
    case loading
    case loaded(planted: [Story], discovered: [Story])
    case error(String)
}

@MainActor
@Observable
final class CollectionViewModel {
    var selectedSegment: CollectionTab = .planted
    var state: CollectionState = .idle
    
    private let getPlantedStoriesUseCase: GetPlantedStoriesUseCaseProtocol
    private let getDiscoveredStoriesUseCase: GetDiscoveredStoriesUseCaseProtocol
    private let deleteStoryUseCase: DeleteStoryUseCaseProtocol
    
    init(
        getPlantedStoriesUseCase: GetPlantedStoriesUseCaseProtocol,
        getDiscoveredStoriesUseCase: GetDiscoveredStoriesUseCaseProtocol,
        deleteStoryUseCase: DeleteStoryUseCaseProtocol
    ) {
        self.getPlantedStoriesUseCase = getPlantedStoriesUseCase
        self.getDiscoveredStoriesUseCase = getDiscoveredStoriesUseCase
        self.deleteStoryUseCase = deleteStoryUseCase
    }
    
    func onAppear() async {
        await refresh()
    }

    func refresh() async {
        state = .loading
        do {
            async let planted = getPlantedStoriesUseCase.execute()
            async let discovered = getDiscoveredStoriesUseCase.execute()
            let (p, d) = try await (planted, discovered)
            state = .loaded(planted: p, discovered: d)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func deletePlantedStories(at offsets: IndexSet) async {
        guard case let .loaded(planted, _) = state else { return }

        let ids = offsets.compactMap { index in
            planted.indices.contains(index) ? planted[index].id : nil
        }

        do {
            for id in ids {
                try await deleteStoryUseCase.execute(storyId: id)
            }
            await refresh()
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    var plantedStories: [Story] {
        guard case let .loaded(planted, _) = state else {
            return []
        }
        return planted
    }
    
    var discoveredStories: [Story] {
        guard case let .loaded(_, discovered) = state else {
            return []
        }
        return discovered
    }
}
