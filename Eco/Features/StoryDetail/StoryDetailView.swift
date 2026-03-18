//
//  StoryDetailView.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import CoreLocation
import SwiftUI

struct StoryDetailView: View {
    @Bindable var viewModel: StoryDetailViewModel
    @Environment(\.openURL) private var openURL

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
                    VStack(alignment: .leading, spacing: 16) {
                        Text(story.title)
                            .font(.title)
                            .bold()

                        if viewModel.isUnlocked {
                            Text(story.content)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                        } else {
                            lockedContentCard(for: story)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ubicación")
                                .font(.headline)
                            Text(String(format: "Lat: %.4f, Lon: %.4f",
                                        story.latitude, story.longitude))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Detalle del Eco")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadDetail()
        }
    }

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
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func openWalkingRoute(to story: Story) {
        let destination = "\(story.latitude),\(story.longitude)"
        guard let url = URL(string: "http://maps.apple.com/?daddr=\(destination)&dirflg=w") else {
            return
        }
        openURL(url)
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
                authorID: UUID(),
                latitude: 19.4326,
                longitude: -99.1332,
                isSynced: true
            )
        }
    }

    struct MockGetLocationUseCase: GetCurrentLocationForPlantingUseCaseProtocol {
        func requestLocation() async -> CLLocationCoordinate2D? {
            CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332)
        }
    }

    struct MockSessionRepository: SessionRepositoryProtocol {
        func getCurrentUserId() -> UUID {
            UUID()
        }
    }

    let vm = StoryDetailViewModel(
        storyId: UUID(),
        getStoryDetailUseCase: MockGetStoryDetailUseCase(),
        getLocationUseCase: MockGetLocationUseCase(),
        sessionRepository: MockSessionRepository()
    )

    return NavigationStack {
        StoryDetailView(viewModel: vm)
    }
}

