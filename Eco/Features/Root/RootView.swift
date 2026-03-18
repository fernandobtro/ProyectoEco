//
//  RootView.swift
//  Eco
//
//  Created by Fernando Buenrostro on 15/03/26.
//

import SwiftUI

struct RootView: View {
    let container: AppDIContainer

    @State private var selectedTab: TabBar = .map
    @State private var showProfile = false
    @State private var mapViewModel: MapViewModel
    @State private var mapRouter: MapRouter
    @State private var collectionViewModel: CollectionViewModel

    init(container: AppDIContainer) {
        self.container = container
        _mapViewModel = State(initialValue: container.makeMapViewModel())
        _mapRouter = State(initialValue: container.makeMapRouter())
        _collectionViewModel = State(initialValue: container.makeCollectionViewModel())
    }

    var body: some View {
        @Bindable var router = mapRouter
        
        ZStack {
            // 1. Capa de navegación (Fondo)
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Opcional: Si quieres que el mapa cubra toda la pantalla detrás del notch
            // .ignoresSafeArea()
            
            // 2. Capa de tu UI Personalizada (Frente)
            VStack {
                // Barra superior empujada a la derecha
                HStack {
                    Spacer() // Esto empuja tu TopFloatingBar a la esquina
                    
                    TopFloatingBar { tappedItem in
                        switch tappedItem {
                        case .profile:
                            showProfile = true
                        case .notification:
                            print("Ir a notificaciones")
                        }
                    }
                }
                
                Spacer() // Separa la barra de arriba y la de abajo
                
                // Barra inferior
                CustomTabBar(selectedTab: $selectedTab) {
                    mapRouter.navigateToCreateStory()
                }
            }
        }
        .sheet(isPresented: $showProfile) {
            container.makeProfileView()
        }
        .sheet(item: $router.sheetDestination, onDismiss: {
            Task { await mapViewModel.onAppear() }
        }) { destination in
            router.view(for: destination)
        }
        .onChange(of: selectedTab) { _, newValue in
            if newValue == .map {
                Task { await mapViewModel.onAppear() }
            }
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .map:
            NavigationStack {
                MapView(viewModel: mapViewModel, router: mapRouter)
                    .toolbar(.hidden, for: .navigationBar)
            }
        case .collection:
            NavigationStack {
                CollectionView(
                    viewModel: collectionViewModel,
                    makeDetailView: { id in
                        StoryDetailView(
                            viewModel: container.makeStoryDetailViewModel(storyId: id)
                        )
                    }
                )
                    .toolbar(.hidden, for: .navigationBar)
            }
        }
    }
}

#Preview {
    RootView(container: AppDIContainer())
}
