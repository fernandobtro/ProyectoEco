//
//  StoryCreationView.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import SwiftUI
import MapKit
import CoreLocation

struct StoryCreationView: View {
    @Bindable var viewModel: StoryCreationViewModel
    @Environment(\.dismiss) var dismiss
    
    // Control de la cámara del mapa
    @State private var mapPosition: MapCameraPosition = .automatic
    
    // Control del teclado
    @FocusState private var isInputActive: Bool

    var body: some View {
        ZStack {
            // 1. El Lienzo (Fondo)
            Color.theme.accent
                .ignoresSafeArea()
                // Si tocas el fondo, se cierra el teclado
                .onTapGesture {
                    isInputActive = false
                }
            
            // 2. El Esqueleto
            VStack(spacing: 24) {
                
                // Botón de cerrar superior derecho
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.theme.primaryText.opacity(0.8))
                    }
                }
                
                // Título
                Text("¿Qué historia vive aquí?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.theme.primaryText)
                    .multilineTextAlignment(.center)
                
                // 3. Mapa Circular con Radio
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
                    // Desactiva el teclado si tocas el mapa
                    .onTapGesture {
                        isInputActive = false
                    }
                } else {
                    Circle()
                        .fill(Color.theme.primaryText.opacity(0.1))
                        .frame(width: 180, height: 180)
                        .overlay(ProgressView().tint(Color.theme.primaryText))
                }
                
                // 4. Caja de Texto Unificada
                VStack(spacing: 0) {
                    // Título de la historia
                    TextField("",
                              text: $viewModel.title,
                              prompt: Text("Título de tu eco").foregroundColor(Color.theme.primaryText.opacity(0.6)))
                        .font(.headline)
                        .foregroundStyle(Color.theme.primaryText)
                        .padding()
                        .focused($isInputActive) // Conectamos al FocusState
                    
                    // Línea divisoria
                    Rectangle()
                        .fill(Color.theme.primaryText.opacity(0.2))
                        .frame(height: 1)
                        .padding(.horizontal, 16)
                    
                    // Contenido
                    TextEditor(text: $viewModel.content)
                        .scrollContentBackground(.hidden)
                        .foregroundStyle(Color.theme.primaryText)
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                        .focused($isInputActive) // Conectamos al FocusState
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
                
                Spacer(minLength: 0)
                
                // 5. Botón de Acción
                Button(action: {
                    Task {
                        isInputActive = false // Oculta el teclado al plantar
                        await viewModel.plantStory()
                        if viewModel.error == nil { dismiss() }
                    }
                }) {
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
                .disabled(viewModel.content.isEmpty || viewModel.title.isEmpty || viewModel.isPlanting)
                .opacity((viewModel.content.isEmpty || viewModel.title.isEmpty) ? 0.6 : 1.0)
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        // Agregamos la barra "Listo" encima del teclado
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Listo") {
                    isInputActive = false
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
}

// MARK: - Preview

#Preview {
    struct MockPlantStoryUseCase: PlantStoryUseCaseProtocol {
        func execute(title: String, content: String, latitude: Double, longitude: Double) async throws { }
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
