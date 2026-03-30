//
//  StoryCreationView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Sheet to compose and plant a story at the current map location (preview map + title/body).
//

import CoreLocation
import MapKit
import SwiftUI

private enum StoryCreationFocusedField: Hashable {
    case title
    case content
}

/// Presented from ``RootView`` / ``MapRouter``, `onPlantingSuccess` passes coordinate and new story id for map animation.
///
/// Narrative: `docs/EcoCorePipelines.md` — **Plant Story Pipeline**.
struct StoryCreationView: View {
    @Bindable var viewModel: StoryCreationViewModel
    @Environment(\.dismiss) var dismiss
    var onPlantingSuccess: ((CLLocationCoordinate2D, UUID) -> Void)?

    @State private var mapPosition: MapCameraPosition = .automatic
    @FocusState private var focusedField: StoryCreationFocusedField?

    var body: some View {
        ZStack {
            Color.theme.accent
                .ignoresSafeArea()
                .onTapGesture {
                    focusedField = nil
                    EcoKeyboard.dismiss()
                }

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(
                        action: { dismiss() },
                        label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(Color.theme.primaryText.opacity(0.8))
                        }
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 24) {
                            Text("¿Qué historia vive aquí?")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.theme.primaryText)
                                .multilineTextAlignment(.center)

                            if let location = viewModel.lastLocation {
                                Map(position: $mapPosition) {
                                    MapCircle(center: location, radius: 50)
                                        .foregroundStyle(Color.theme.primaryComponent.opacity(0.4))
                                        .mapOverlayLevel(level: .aboveRoads)

                                    Marker("Tú", coordinate: location)
                                        .tint(Color.theme.primaryComponent)
                                }
                                .frame(width: 180, height: 180)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.theme.primaryText, lineWidth: 3))
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                .onAppear {
                                    mapPosition = .region(MKCoordinateRegion(center: location, latitudinalMeters: 150, longitudinalMeters: 150))
                                }
                                .onTapGesture {
                                    focusedField = nil
                                    EcoKeyboard.dismiss()
                                }
                            } else {
                                Circle()
                                    .fill(Color.theme.primaryText.opacity(0.1))
                                    .frame(width: 180, height: 180)
                                    .overlay(ProgressView().tint(Color.theme.primaryText))
                            }

                            storyInputBlock

                            plantButton
                                .padding(.top, 8)

                            Spacer(minLength: 120)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: focusedField) { _, new in
                        guard let new else { return }
                        let scrollId: String
                        let anchor: UnitPoint
                        switch new {
                        case .title:
                            scrollId = "storyTitleField"
                            anchor = UnitPoint(x: 0.5, y: 0.2)
                        case .content:
                            scrollId = "storyContentField"
                            anchor = UnitPoint(x: 0.5, y: 0.28)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                            withAnimation(.easeInOut(duration: 0.32)) {
                                proxy.scrollTo(scrollId, anchor: anchor)
                            }
                        }
                    }
                }
            }
        }
        .alert("¡Ups!", isPresented: .init(get: { viewModel.error != nil }, set: { _ in viewModel.error = nil })) {
            Button("Entendido", role: .cancel) { }
        } message: {
            Text(viewModel.error ?? "")
        }
        .task {
            await viewModel.updateLocation()
            if let loc = viewModel.lastLocation {
                mapPosition = .region(MKCoordinateRegion(center: loc, latitudinalMeters: 150, longitudinalMeters: 150))
            }
        }
    }

    private var storyInputBlock: some View {
        VStack(spacing: 0) {
            TextField(
                "",
                text: $viewModel.title,
                prompt: Text("Título de tu eco").foregroundColor(Color.theme.primaryText.opacity(0.6))
            )
            .font(.headline)
            .foregroundStyle(Color.theme.primaryText)
            .padding()
            .focused($focusedField, equals: .title)
            .id("storyTitleField")

            Rectangle()
                .fill(Color.theme.primaryText.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, 16)

            TextEditor(text: $viewModel.content)
                .scrollContentBackground(.hidden)
                .foregroundStyle(Color.theme.primaryText)
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .frame(minHeight: 160)
                .focused($focusedField, equals: .content)
                .id("storyContentField")
                .overlay(alignment: .topLeading) {
                    if viewModel.content.isEmpty {
                        Text("Escribe aquí tu historia...")
                            .foregroundStyle(Color.theme.primaryText.opacity(0.5))
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .allowsHitTesting(false)
                    }
                }
        }
        .background {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.theme.primaryText.opacity(0.5), lineWidth: 1)
                .background(Color.theme.primaryText.opacity(0.05).cornerRadius(16))
        }
    }

    private var plantButton: some View {
        Button(
            action: {
                Task {
                    focusedField = nil
                    EcoKeyboard.dismiss()
                    await viewModel.plantStory()
                    if viewModel.error == nil {
                        if let coordinate = viewModel.lastLocation,
                           let storyId = viewModel.lastPlantedStoryId {
                            onPlantingSuccess?(coordinate, storyId)
                        }
                        dismiss()
                    }
                }
            },
            label: {
                if viewModel.isPlanting {
                    ProgressView()
                        .tint(Color.theme.accent)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Capsule().fill(Color.theme.primaryComponent.opacity(0.5)))
                } else {
                    Text("Plantar eco")
                        .font(.headline)
                        .foregroundStyle(Color.theme.accent)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Capsule().fill(Color.theme.primaryComponent))
                }
            }
        )
        .disabled(viewModel.content.isEmpty || viewModel.title.isEmpty || viewModel.isPlanting)
        .opacity((viewModel.content.isEmpty || viewModel.title.isEmpty) ? 0.6 : 1.0)
    }
}

// MARK: - Preview

#Preview {
    struct MockPlantStoryUseCase: PlantStoryUseCaseProtocol {
        func execute(title: String, content: String, latitude: Double, longitude: Double) async throws -> UUID {
            UUID()
        }
    }

    struct MockGetLocationForPlantingUseCase: GetCurrentLocationForPlantingUseCaseProtocol {
        func requestLocation() async -> CLLocationCoordinate2D? {
            CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332)
        }
    }

    struct MockSyncStoriesUseCase: SyncStoriesUseCase {
        func execute() async { }
    }

    let viewModel = StoryCreationViewModel(
        plantUseCase: MockPlantStoryUseCase(),
        getLocationUseCase: MockGetLocationForPlantingUseCase(),
        syncStoriesUseCase: MockSyncStoriesUseCase()
    )

    return StoryCreationView(viewModel: viewModel)
}
