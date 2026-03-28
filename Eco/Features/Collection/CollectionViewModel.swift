//
//  CollectionViewModel.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Drive the Collection screen with planted vs discovered Ecos and sync-backed lists.
//
//  Responsibilities:
//  - Refresh from remote and load both tabs, surface loading and error state.
//  - Delete planted stories (single or by list offsets) and keep lists consistent.
//

import Foundation
import Observation

// MARK: - Tab & state types
enum CollectionTab {
    case planted
    case discovered
}

enum CollectionState: Equatable {
    case idle
    case loading
    case loaded(
        planted: [Story],
        discovered: [Story],
        plantedHasMore: Bool,
        isLoadingMorePlanted: Bool
    )
    case error(String)
}

@MainActor
@Observable
final class CollectionViewModel {

    // MARK: - Dependencies
    private let getPlantedStoriesUseCase: GetPlantedStoriesUseCaseProtocol
    private let getDiscoveredStoriesUseCase: GetDiscoveredStoriesUseCaseProtocol
    private let deleteStoryUseCase: DeleteStoryUseCaseProtocol
    private let syncStoriesUseCase: SyncStoriesUseCase

    /// Page size for planted list; use case fetches `pageSize + 1` rows to compute `hasMore`.
    private static let plantedPageSize = 20

    // MARK: - Published state
    var selectedSegment: CollectionTab = .planted
    var state: CollectionState = .idle

    /// Next `page` index for ``GetPlantedStoriesUseCaseProtocol.execute(page:pageSize:)`` after the initial refresh (starts at `0`, then `1`, …).
    private var nextPlantedPageToFetch: Int = 0

    // MARK: - Init
    init(
        getPlantedStoriesUseCase: GetPlantedStoriesUseCaseProtocol,
        getDiscoveredStoriesUseCase: GetDiscoveredStoriesUseCaseProtocol,
        deleteStoryUseCase: DeleteStoryUseCaseProtocol,
        syncStoriesUseCase: SyncStoriesUseCase
    ) {
        self.getPlantedStoriesUseCase = getPlantedStoriesUseCase
        self.getDiscoveredStoriesUseCase = getDiscoveredStoriesUseCase
        self.deleteStoryUseCase = deleteStoryUseCase
        self.syncStoriesUseCase = syncStoriesUseCase
    }

    // MARK: - Lifecycle
    /// Entry point for the view’s `.task`: loads both segments by calling `refresh()`.
    func onAppear() async {
        await refresh()
    }

    /// Runs a full remote pull via sync, then loads the first planted page and the full discovered list (discovered is not paginated yet).
    func refresh() async {
        state = .loading
        nextPlantedPageToFetch = 0
        await syncStoriesUseCase.executeWithFullRemotePull()
        do {
            async let plantedFirst = getPlantedStoriesUseCase.execute(page: 0, pageSize: Self.plantedPageSize)
            async let discovered = getDiscoveredStoriesUseCase.execute()
            let (plantedPage, discoveredStories) = try await (plantedFirst, discovered)
            nextPlantedPageToFetch = 1
            state = .loaded(
                planted: plantedPage.items,
                discovered: discoveredStories,
                plantedHasMore: plantedPage.hasMore,
                isLoadingMorePlanted: false
            )
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    /// Loads the next planted page when the user scrolls near the end. Ignores overlapping calls while a load is in progress.
    func loadMorePlantedIfNeeded() async {
        guard case let .loaded(planted, discovered, plantedHasMore, loadingMore) = state,
              plantedHasMore, !loadingMore else { return }

        state = .loaded(
            planted: planted,
            discovered: discovered,
            plantedHasMore: plantedHasMore,
            isLoadingMorePlanted: true
        )

        do {
            let page = try await getPlantedStoriesUseCase.execute(
                page: nextPlantedPageToFetch,
                pageSize: Self.plantedPageSize
            )
            nextPlantedPageToFetch += 1
            state = .loaded(
                planted: planted + page.items,
                discovered: discovered,
                plantedHasMore: page.hasMore,
                isLoadingMorePlanted: false
            )
        } catch {
            state = .loaded(
                planted: planted,
                discovered: discovered,
                plantedHasMore: plantedHasMore,
                isLoadingMorePlanted: false
            )
        }
    }

    // MARK: - Deletion
    /// Deletes planted rows at the given offsets, triggers sync, then reloads both lists.
    func deletePlantedStories(at offsets: IndexSet) async {
        guard case let .loaded(planted, _, _, _) = state else { return }

        let ids = offsets.compactMap { index in
            planted.indices.contains(index) ? planted[index].id : nil
        }

        do {
            for id in ids {
                try await deleteStoryUseCase.execute(storyId: id)
            }
            Task { await syncStoriesUseCase.execute() }
            await refresh()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    /// Deletes one planted story by id, triggers sync, then reloads both lists.
    func deletePlantedStory(id: UUID) async {
        do {
            try await deleteStoryUseCase.execute(storyId: id)
            Task { await syncStoriesUseCase.execute() }
            await refresh()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    // MARK: - Derived lists
    var plantedStories: [Story] {
        guard case let .loaded(planted, _, _, _) = state else {
            return []
        }
        return planted
    }

    var discoveredStories: [Story] {
        guard case let .loaded(_, discovered, _, _) = state else {
            return []
        }
        return discovered
    }

    var plantedListItems: [StoryViewData] {
        plantedStories.map { Self.listItem(for: $0) }
    }

    var discoveredListItems: [StoryViewData] {
        discoveredStories.map { Self.listItem(for: $0) }
    }

    /// True while the next planted page is being fetched (scroll infinite).
    var isLoadingMorePlanted: Bool {
        guard case let .loaded(_, _, _, loadingMore) = state else { return false }
        return loadingMore
    }

    // MARK: - Discovered map helpers

    /// Coordinate for opening Maps for a discovered story, if the story exists in the loaded list.
    func discoveredDestinationCoordinate(for id: UUID) -> (latitude: Double, longitude: Double)? {
        guard let story = discoveredStories.first(where: { $0.id == id }) else { return nil }
        return (story.latitude, story.longitude)
    }

    /// Title string for the Maps query for a discovered story (falls back to `"Eco"` when empty).
    func discoveredMapTitle(for id: UUID) -> String {
        guard let story = discoveredStories.first(where: { $0.id == id }) else { return "Eco" }
        let trimmed = story.title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Eco" : trimmed
    }

    // MARK: - Private helpers
    private static func listItem(for story: Story) -> StoryViewData {
        StoryViewData(
            id: story.id,
            title: story.title,
            subtitle: story.content,
            isSynced: story.isSynced,
            showMineBadge: false,
            footnote: EcoRelativeDateFormatting.relativeNamedString(for: story.updatedAt),
            footnoteIncludesDistance: false,
            showNearbyPill: false
        )
    }
}
