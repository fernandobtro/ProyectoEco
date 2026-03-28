//
//  CollectionView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Collection tab UI for planted and discovered Ecos, with detail sheet and empty states.
//
//  Responsibilities:
//  - Show segmented lists, pull to refresh, navigation into detail, and map shortcuts for discovered items.
//  - Wire StoryDetailView with a factory and refresh the collection after delete.
//

import CoreLocation
import Foundation
import SwiftUI

/// Tab screen listing the user’s planted Ecos and discovered Ecos, with optional empty-state actions.
struct CollectionView: View {

    // MARK: - Properties

    @Bindable var viewModel: CollectionViewModel

    /// Builds a `StoryDetailViewModel` for the given story id (typically from `AppDIContainer`).
    let makeDetailViewModel: (UUID) -> StoryDetailViewModel

    /// Invoked from the empty state when the user has no planted stories yet.
    var onPlantFirstStory: (() -> Void)? = nil

    /// Invoked from the empty state to jump to the map when there are no discoveries yet.
    var onGoToMap: (() -> Void)? = nil

    @Environment(\.openURL) private var openURL
    @State private var selectedStoryForDetail: IdentifiableStoryID?
    @State private var detailViewModel: StoryDetailViewModel?

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.theme.exploreBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerView

                CollectionSegmentedControl(selection: $viewModel.selectedSegment)
                    .padding(.bottom, 12)

                Group {
                    switch viewModel.state {
                    case .idle, .loading:
                        ProgressView()
                            .tint(Color.theme.accent)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .error(let message):
                        Text(message)
                            .font(.poppins(.regular, size: 15))
                            .foregroundStyle(Color.theme.secondaryText.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .loaded:
                        listContent
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 92)
            }
            .padding(.top, 84)
        }
        .task {
            await viewModel.onAppear()
        }
        .onChange(of: selectedStoryForDetail) { _, new in
            if let id = new?.value {
                detailViewModel = makeDetailViewModel(id)
            } else {
                detailViewModel = nil
            }
        }
        .sheet(
            item: $selectedStoryForDetail,
            onDismiss: { detailViewModel = nil },
            content: { _ in
                NavigationStack {
                    if let detailVM = detailViewModel {
                        StoryDetailView(
                            viewModel: detailVM,
                            onDelete: { await viewModel.refresh() }
                        )
                    }
                }
            }
        )
    }

    // MARK: - Private views

    @ViewBuilder
    private var listContent: some View {
        switch viewModel.selectedSegment {
        case .planted:
            if viewModel.plantedStories.isEmpty {
                CollectionEmptyStateView(
                    kind: .plantedNoStories,
                    primaryActionTitle: "Plantar mi primera historia",
                    primaryAction: onPlantFirstStory
                )
            } else {
                plantedList
            }
        case .discovered:
            if viewModel.discoveredStories.isEmpty {
                CollectionEmptyStateView(
                    kind: .discoveredNone,
                    primaryActionTitle: "Ir al Mapa",
                    primaryAction: onGoToMap
                )
            } else {
                discoveredList
            }
        }
    }

    private var plantedList: some View {
        List {
            ForEach(viewModel.plantedListItems) { item in
                Button {
                    #if DEBUG
                    print("[CollectionView] open planted detail id=\(item.id.uuidString)")
                    #endif
                    selectedStoryForDetail = IdentifiableStoryID(value: item.id)
                } label: {
                    CollectionStoryCardRow(viewData: item)
                }
                .buttonStyle(.plain)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button {
                        Task { await viewModel.deletePlantedStory(id: item.id) }
                    } label: {
                        Image(systemName: "trash")
                            .font(.body.weight(.medium))
                            .foregroundStyle(.white)
                    }
                    .tint(Color.red)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .listRowSpacing(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var discoveredList: some View {
        List {
            ForEach(viewModel.discoveredListItems) { item in
                VStack(alignment: .leading, spacing: 10) {
                    Button {
                        #if DEBUG
                        print("[CollectionView] open discovered detail id=\(item.id.uuidString)")
                        #endif
                        selectedStoryForDetail = IdentifiableStoryID(value: item.id)
                    } label: {
                        CollectionStoryCardRow(viewData: item)
                    }
                    .buttonStyle(.plain)

                    Button {
                        openRouteToDiscoveredStory(id: item.id)
                    } label: {
                        Text("Ir")
                            .font(.poppins(.semiBold, size: 14))
                            .foregroundStyle(Color.theme.primaryComponent)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                Capsule()
                                    .fill(Color.theme.accent)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .listRowSpacing(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var headerView: some View {
        Text("Mis Ecos")
            .font(.poppins(.bold, size: 28))
            .foregroundStyle(Color.theme.accent)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
    }

    // MARK: - Private helpers
    /// Opens Apple Maps centered on the discovered story with a titled pin query.
    private func openRouteToDiscoveredStory(id: UUID) {
        guard let coordinate = viewModel.discoveredDestinationCoordinate(for: id) else { return }
        let name = viewModel.discoveredMapTitle(for: id)

        var components = URLComponents(string: "http://maps.apple.com/")
        components?.queryItems = [
            URLQueryItem(name: "ll", value: "\(coordinate.latitude),\(coordinate.longitude)"),
            URLQueryItem(name: "q", value: "Eco · \(name)")
        ]

        guard let url = components?.url else { return }
        openURL(url)
    }
}

// MARK: - Sheet identity
/// Wraps a `UUID` so SwiftUI `.sheet(item:)` can use stable identity for story detail.
private struct IdentifiableStoryID: Identifiable, Equatable {
    let value: UUID
    var id: UUID { value }
}

// MARK: - Preview mocks
private struct MockGetPlantedStoriesUseCaseForPreview: GetPlantedStoriesUseCaseProtocol {
    func execute() async throws -> [Story] {
        [
            Story(
                id: UUID(),
                title: "Mi Eco",
                content: "Historia creada por mí.",
                authorID: "mock-uid",
                latitude: 19.4326,
                longitude: -99.1332,
                isSynced: true,
                updatedAt: Date()
            )
        ]
    }
}

private struct MockGetDiscoveredStoriesUseCaseForPreview: GetDiscoveredStoriesUseCaseProtocol {
    func execute() async throws -> [Story] {
        [
            Story(
                id: UUID(),
                title: "Eco descubierto",
                content: "Historia encontrada cerca de ti.",
                authorID: "another-uid",
                latitude: 19.43,
                longitude: -99.13,
                isSynced: true,
                updatedAt: Date()
            )
        ]
    }
}

private struct MockDeleteStoryUseCaseForCollectionPreview: DeleteStoryUseCaseProtocol {
    func execute(storyId: UUID) async throws { }
}

private struct MockSyncStoriesUseCaseForCollectionPreview: SyncStoriesUseCase {
    func execute() async { }
}

private struct MockGetStoryDetailUseCaseForCollectionPreview: GetStoryDetailUseCaseProtocol {
    func execute(id: UUID) async throws -> Story? { nil }
}

private struct MockGetLocationUseCaseForCollectionPreview: GetCurrentLocationForPlantingUseCaseProtocol {
    func requestLocation() async -> CLLocationCoordinate2D? { nil }
}

private struct MockUpdateStoryUseCaseForCollectionPreview: UpdateStoryUseCaseProtocol {
    func execute(_ story: Story) async throws { }
}

private struct MockSessionRepositoryForCollectionPreview: SessionRepositoryProtocol {
    func getCurrentUserId() throws -> String { "mock-uid" }
    func getNickname() -> String? { "Mock" }
    func saveNickname(_ name: String) { }
}

// MARK: - Preview

#Preview("Con historias") {
    let collectionViewModel = CollectionViewModel(
        getPlantedStoriesUseCase: MockGetPlantedStoriesUseCaseForPreview(),
        getDiscoveredStoriesUseCase: MockGetDiscoveredStoriesUseCaseForPreview(),
        deleteStoryUseCase: MockDeleteStoryUseCaseForCollectionPreview(),
        syncStoriesUseCase: MockSyncStoriesUseCaseForCollectionPreview()
    )
    return NavigationStack {
        CollectionView(
            viewModel: collectionViewModel,
            makeDetailViewModel: { id in
                StoryDetailViewModel(
                    storyId: id,
                    getStoryDetailUseCase: MockGetStoryDetailUseCaseForCollectionPreview(),
                    getLocationUseCase: MockGetLocationUseCaseForCollectionPreview(),
                    updateStoryUseCase: MockUpdateStoryUseCaseForCollectionPreview(),
                    deleteStoryUseCase: MockDeleteStoryUseCaseForCollectionPreview(),
                    syncStoriesUseCase: MockSyncStoriesUseCaseForCollectionPreview(),
                    sessionRepository: MockSessionRepositoryForCollectionPreview()
                )
            },
            onPlantFirstStory: {},
            onGoToMap: {}
        )
    }
}
