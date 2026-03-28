//
//  MapView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Paints the map experience, pins, overlays, and the selected story callout.
//
//  Responsibilities:
//  - Render the map, pins, camera updates, and taps on the map versus pins.
//  - Layer recenter, hints, location denied, planting animation, and the story reader entry points.
//

import SwiftUI
import MapKit
import CoreLocation
import UIKit

struct MapView: View {
    // MARK: - State and navigation
    @State var viewModel: MapViewModel
    @State var router: MapRouter

    @Environment(\.openURL) private var openURL

    private var isLocationDenied: Bool {
        let status = CLLocationManager().authorizationStatus
        return status == .denied || status == .restricted
    }

    // MARK: - Body
    var body: some View {
        @Bindable var viewModel = viewModel
        @Bindable var router = router

        ZStack {
            mapWithAnnotations(
                cameraPosition: $viewModel.cameraPosition,
                viewModel: viewModel,
                router: router
            )

            recenterButtonOverlay

            if let story = viewModel.selectedStory {
                VStack {
                    Spacer()
                    mapStoryCallout(story: story)
                }
            }

            if viewModel.showExploreTheMapHint {
                exploreTheMapHintOverlay
            }

            if isLocationDenied {
                locationDeniedOverlay
            }

            if viewModel.pendingPlanting != nil {
                PlantingAnimationOverlay {
                    viewModel.completePlantingAnimation()
                }
                .allowsHitTesting(false)
                .transition(.opacity)
            }
        }
        .task {
            await viewModel.onAppear()
        }
    }

    // MARK: - Map components (annotations)
    @ViewBuilder
    private func mapWithAnnotations(
        cameraPosition: Binding<MapKit.MapCameraPosition>,
        viewModel: MapViewModel,
        router: MapRouter
    ) -> some View {
        Map(position: cameraPosition) {
            ForEach(viewModel.annotations) { annotation in
                Annotation(
                    "",
                    coordinate: annotation.coordinate
                ) {
                    storyAnnotationContent(annotation: annotation, viewModel: viewModel, router: router)
                }
            }
        }
        .mapStyle(.standard(elevation: .flat))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .environment(\.colorScheme, .light)
        .onMapCameraChange(frequency: .onEnd) { context in
            viewModel.onMapCameraChanged(region: context.region)
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                guard viewModel.selectedStoryId != nil else { return }
                if viewModel.shouldIgnoreMapBackgroundTap() { return }
                viewModel.clearStorySelection()
            }
        )
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func storyAnnotationContent(
        annotation: MapViewModel.StoryAnnotation,
        viewModel: MapViewModel,
        router: MapRouter
    ) -> some View {
        let isSelected = viewModel.selectedStoryId == annotation.id
        Button {
            guard let outcome = viewModel.handlePinTap(storyId: annotation.id) else { return }
            switch outcome {
            case .selected:
                break
            case .shouldOpenReader:
                router.navigateToStoryDetail(id: annotation.id)
                viewModel.clearStorySelection()
            }
        } label: {
            ZStack {
                if isSelected {
                    Circle()
                        .stroke(Color.theme.accent, lineWidth: 2)
                        .frame(width: 38, height: 38)
                }
                Image("Plantita")
                    .resizable()
                    .scaledToFit()
                    .frame(width: isSelected ? 30 : 26, height: isSelected ? 30 : 26)
                if !annotation.isSynced {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 10, height: 10)
                        .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                        .offset(x: 12, y: -12)
                }
            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .offset(x: annotation.horizontalScreenOffset)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            isSelected
                ? "Eco seleccionado. Toca de nuevo para leer."
                : "Eco. Toca para seleccionar."
        )
    }

    // MARK: - Overlays
    private var recenterButtonOverlay: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    Task { await viewModel.userRequestedRecenter() }
                } label: {
                    Image(systemName: "location.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.theme.primaryComponent)
                        .padding(12)
                        .background(Circle().fill(Color.theme.accent))
                        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                }
                .padding(.trailing, 12)
                .padding(.top, 84)
            }
            Spacer()
        }
    }

    private var exploreTheMapHintOverlay: some View {
        VStack {
            Spacer()
            Text("Mueve el mapa para ver Ecos en la zona visible.")
                .font(.poppins(.medium, size: 13))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.theme.primaryText)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 24)
                .padding(.bottom, 120)
        }
        .allowsHitTesting(false)
    }

    private var locationDeniedOverlay: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Text("Eco necesita tu ubicación para mostrar historias cercanas.")
                    .font(.poppins(.bold, size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.theme.primaryText)

                Button("Abrir Ajustes") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
                .font(.poppins(.semiBold, size: 15))
                .foregroundColor(Color.theme.accent)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(Color.theme.primaryComponent)
                )
            }
            .padding(16)
            .background(Color.theme.primaryComponent.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .transition(.opacity)
    }

    // MARK: - Sub-components
    @ViewBuilder
    private func mapStoryCallout(story: Story) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(story.title)
                .font(.poppins(.semiBold, size: 16))
                .foregroundStyle(Color.theme.accent)
                .lineLimit(2)
                .accessibilityAddTraits(.isHeader)

            if let meters = viewModel.selectedStoryDistanceMeters {
                Text("A \(Int(meters.rounded())) m")
                    .font(.poppins(.medium, size: 13))
                    .foregroundStyle(Color.theme.secondaryText.opacity(0.88))
            }

            Button {
                router.navigateToStoryDetail(id: story.id)
                viewModel.clearStorySelection()
            } label: {
                Text("Leer Eco")
                    .font(.poppins(.semiBold, size: 15))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(Color.theme.primaryComponent)
                    .background(Color.theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Leer Eco")
        }
        .padding(16)
        .background(Color.theme.primaryComponent.opacity(0.98))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 20)
        .padding(.bottom, 112)
    }
}
