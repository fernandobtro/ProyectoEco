//
//  StoryDetailView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Full-screen read and manage flow for one Eco, including map context and actions.
//
//  Responsibilities:
//  - Show title, body, distance, author line, and map preview when it makes sense.
//  - Offer read, edit, delete, and navigation back while keeping the viewModel in charge of data.
//

import CoreLocation
import MapKit
import SwiftUI

/// Detail screen for one Eco: loading and error states, locked vs unlocked content, and author actions.
struct StoryDetailView: View {

    // MARK: - Properties

    @Bindable var viewModel: StoryDetailViewModel
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @State private var isEditSheetPresented = false
    @State private var isDeleteConfirmationPresented = false

    /// Callback invoked after a successful delete.
    ///
    /// - Important: Use it to refresh views still under the navigation stack (for example the Collection list).
    var onDelete: (() async -> Void)?

    // MARK: - Body
    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Cargando Eco...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .error(let message):
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text(message)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded(let story):
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text(story.title)
                            .font(.poppins(.bold, size: 30))
                            .foregroundStyle(Color.theme.accent)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(storyPreviewText(for: story))
                            .font(.poppins(.regular, size: 16))
                            .foregroundStyle(Color.theme.secondaryText)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Ubicación")
                                .font(.poppins(.semiBold, size: 16))
                                .foregroundStyle(Color.theme.accent)

                            locationPreviewMap(for: story)
                        }

                        if !viewModel.isUnlocked {
                            lockedContentCard(for: story)
                        }

                        Button("Ir") {
                            openWalkingRoute(to: story)
                        }
                        .font(.poppins(.semiBold, size: 16))
                        .buttonStyle(.borderedProminent)
                        .tint(Color.theme.accent)
                    }
                    .padding(20)
                }
                .background(Color.theme.exploreBackground.ignoresSafeArea())
            }
        }
        .navigationTitle("Eco")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.isAuthor {
                ToolbarItem(placement: .primaryAction) {
                    Button("Editar") {
                        isEditSheetPresented = true
                    }
                    .disabled(viewModel.isDeleting)
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button("Eliminar", role: .destructive) {
                        isDeleteConfirmationPresented = true
                    }
                    .disabled(viewModel.isDeleting)
                }
            }
        }
        .confirmationDialog("Eliminar Eco", isPresented: $isDeleteConfirmationPresented) {
            Button("Eliminar", role: .destructive) {
                Task {
                    if await viewModel.deleteStory() {
                        await onDelete?()
                        dismiss()
                    }
                }
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("¿Estás seguro? Esta acción no se puede deshacer.")
        }
        .overlay {
            if viewModel.isDeleting {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView("Eliminando...")
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.updateError != nil },
            set: { if !$0 { viewModel.updateError = nil } }
        )) {
            Button("OK") { }
        } message: {
            if let error = viewModel.updateError {
                Text(error)
            }
        }
        .sheet(isPresented: $isEditSheetPresented) {
            EditStoryView(viewModel: viewModel)
        }
        .task(id: debugRenderStateKey) {
            #if DEBUG
            print("[StoryDetailView] render state=\(debugRenderStateKey) storyId=\(viewModel.storyId.uuidString)")
            #endif
        }
        .task {
            #if DEBUG
            print("[StoryDetailView] task load storyId=\(viewModel.storyId.uuidString)")
            #endif
            await viewModel.loadDetail()
        }
    }

    // MARK: - Debug
    /// Stable string key for `.task(id:)` so DEBUG logs fire when `viewModel.state` changes.
    private var debugRenderStateKey: String {
        switch viewModel.state {
        case .idle:
            return "idle"
        case .loading:
            return "loading"
        case .error(let message):
            return "error:\(message)"
        case .loaded(let story):
            return "loaded:\(story.id.uuidString)"
        }
    }

    // MARK: - Private helpers

    /// Card explaining that the reader must move closer physically to reveal the full Eco content.
    @ViewBuilder
    private func lockedContentCard(for story: Story) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.circle.fill")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)

            Text("Este Eco está fuera de tu alcance")
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(viewModel.distanceText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("¿Cómo llegar?") {
                openWalkingRoute(to: story)
            }
            .font(.poppins(.semiBold, size: 15))
            .buttonStyle(.borderedProminent)
            .tint(Color.theme.accent)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.theme.primaryComponent.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    /// Opens Apple Maps with walking directions to the story coordinates.
    private func openWalkingRoute(to story: Story) {
        let destination = "\(story.latitude),\(story.longitude)"
        guard let url = URL(string: "http://maps.apple.com/?daddr=\(destination)&dirflg=w") else {
            return
        }
        openURL(url)
    }

    /// Returns the full body or the first 100 characters with an ellipsis for the preview line.
    private func storyPreviewText(for story: Story) -> String {
        let text = story.content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.count > 100 else { return text }
        let end = text.index(text.startIndex, offsetBy: 100)
        return String(text[..<end]) + "..."
    }

    /// Read-only map thumbnail centered on the Eco with a simple pin-style marker.
    @ViewBuilder
    private func locationPreviewMap(for story: Story) -> some View {
        let center = CLLocationCoordinate2D(latitude: story.latitude, longitude: story.longitude)
        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        )
        Map(initialPosition: .region(region)) {
            Annotation("Eco", coordinate: center) {
                Circle()
                    .fill(Color.theme.accent)
                    .frame(width: 14, height: 14)
                    .overlay {
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    }
            }
        }
        .mapStyle(.standard(elevation: .flat))
        .environment(\.colorScheme, .light)
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Preview
#Preview {
    struct MockGetStoryDetailUseCase: GetStoryDetailUseCaseProtocol {
        func execute(id: UUID) async throws -> Story? {
            Story(
                id: id,
                title: "Eco en la Alameda",
                content: "Una historia que solo puedes leer en el corazón de la ciudad.",
                authorID: "mock-uid",
                latitude: 19.4326,
                longitude: -99.1332,
                isSynced: true,
                updatedAt: Date()
            )
        }
    }

    struct MockGetLocationUseCase: GetCurrentLocationForPlantingUseCaseProtocol {
        func requestLocation() async -> CLLocationCoordinate2D? {
            CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332)
        }
    }

    struct MockSessionRepository: SessionRepositoryProtocol {
        func getCurrentUserId() throws -> String {
            "mock-uid"
        }

        func getNickname() -> String? {
            "Mock User"
        }

        func saveNickname(_ name: String) {}
    }

    struct MockUpdateStoryUseCase: UpdateStoryUseCaseProtocol {
        func execute(_ story: Story) async throws { }
    }

    struct MockDeleteStoryUseCase: DeleteStoryUseCaseProtocol {
        func execute(storyId: UUID) async throws { }
    }

    struct MockSyncStoriesUseCase: SyncStoriesUseCase {
        func execute() async { }
    }

    let vml = StoryDetailViewModel(
        storyId: UUID(),
        getStoryDetailUseCase: MockGetStoryDetailUseCase(),
        getLocationUseCase: MockGetLocationUseCase(),
        updateStoryUseCase: MockUpdateStoryUseCase(),
        deleteStoryUseCase: MockDeleteStoryUseCase(),
        syncStoriesUseCase: MockSyncStoriesUseCase(),
        sessionRepository: MockSessionRepository()
    )

    return NavigationStack {
        StoryDetailView(viewModel: vml)
    }
}
