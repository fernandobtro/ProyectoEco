//
//  MapView.swift
//  Eco
//
//  Created by Fernando Buenrostro on 02/03/26.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State var viewModel: MapViewModel
    @State var router: MapRouter

    var body: some View {
        @Bindable var viewModel = viewModel
        @Bindable var router = router

        ZStack {
            Map(position: $viewModel.cameraPosition) {

                ForEach(viewModel.annotations) { annotation in
                    Annotation(
                        "",
                        coordinate: annotation.coordinate
                    ) {
                        ZStack {
                            Circle()
                                .fill(annotation.isSynced ? Color.theme.accent : Color.orange)
                                .frame(width: 16, height: 16)

                            if !annotation.isSynced {
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat)) // 🎨 estilo blanco
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            .environment(\.colorScheme, .light)
            .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    Button {
                        viewModel.cameraPosition = .userLocation(
                            fallback: .region(
                                MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
                                    span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
                                )
                            )
                        )
                        Task { await viewModel.refreshStories() }
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.theme.primaryComponent)
                            .padding(12)
                            .background(Circle().fill(Color.theme.accent))
                            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                    }
                    .padding(.trailing, 12)
                    .padding(.top, 84) // Debajo de TopFloatingBar
                }
                Spacer()
            }
        }
        .task {
            await viewModel.onAppear()
        }
    }
}

/*
// MARK: - Preview

#Preview {
    struct MockDiscoverNearbyStoriesUseCase: DiscoverNearbyStoriesUseCaseProtocol {
        func nearbyStories() -> AsyncStream<[Story]> {
            AsyncStream { continuation in
                let sample = [
                    Story(
                        id: UUID(),
                        title: "Eco en la Alameda",
                        content: "Una historia plantada en el corazón de la ciudad.",
                        authorID: UUID(),
                        latitude: 19.4326,
                        longitude: -99.1332, isSynced: true
                    ),
                    Story(
                        id: UUID(),
                        title: "Eco en Coyoacán",
                        content: "Voces que resuenan entre calles empedradas.",
                        authorID: UUID(),
                        latitude: 19.3467,
                        longitude: -99.1617, isSynced: true
                    )
                ]
                continuation.yield(sample)
                continuation.finish()
            }
        }

        func refreshNearbyStories(latitude: Double, longitude: Double) async { }

        func currentNearbyStoryIDs() -> [UUID] { [] }
    }

    struct MockSyncPullStoriesUseCase: SyncPullStoriesUseCaseProtocol {
        func execute(since: Date?) async { }
    }

    final class MockDiscoveryController: LocationDiscoveryControlling {
        func startDiscovery() { }
        func requestPermission() async { }
    }

    let viewModel = MapViewModel(
        discoverUseCase: MockDiscoverNearbyStoriesUseCase(),
        discoveryController: MockDiscoveryController(),
        syncPullStoriesUseCase: MockSyncPullStoriesUseCase()
    )
    let router = MapRouter(storyCreationViewFactory: { nil })

    MapView(viewModel: viewModel, router: router)
}
*/
