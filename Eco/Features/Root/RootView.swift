//
//  RootView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Post-auth shell: tabs, sync indicator, `MapRouter`, story creation sheet, profile/notifications, deep links.
//

import SwiftUI
import UserNotifications
import CoreLocation

/// Tab host for map, collection, planting (`MapRouter`), profile, and notifications, wires `AppRouter` and onboarding cards.
///
/// Narrative: `docs/EcoCorePipelines.md` — **Plant Story Pipeline** (`RootView` + `MapRouter`), also **Map Story Discovery**, **Collection**, **Story Detail**, **Cross-Cutting: Sync, Geofencing, Notifications**.
struct RootView: View {
    let container: any RootViewDependencyProviding

    // MARK: - Navigation State
    @State private var selectedTab: TabBar = .map
    @State private var showProfile = false
    @State private var showNotifications = false
    @State private var showNotificationsOnboarding = false
    @State private var showAlwaysLocationUpgrade = false
    @State private var mapViewModel: MapViewModel
    @State private var mapRouter: MapRouter
    @State private var collectionViewModel: CollectionViewModel
    @State private var syncStateService: SyncStateService

    // MARK: - Persistent Settings
    /// Whether the user has completed or dismissed the notifications onboarding prompt.
    @AppStorage("eco.hasSeenNotificationsOnboarding") private var hasSeenNotificationsOnboarding = false
    @AppStorage("eco.hasRequestedAlwaysLocationUpgrade") private var hasRequestedAlwaysLocationUpgrade = false

    /// Access to global router to handle deep links.
    private var appRouter: AppRouter { AppRouter.shared }

    // MARK: - Initializer
    init(container: any RootViewDependencyProviding) {
        self.container = container
        _mapViewModel = State(initialValue: container.makeMapViewModel())
        _mapRouter = State(initialValue: container.makeMapRouter())
        _collectionViewModel = State(initialValue: container.makeCollectionViewModel())
        _syncStateService = State(initialValue: container.makeSyncStateService())
    }

    var body: some View {
        @Bindable var router = mapRouter
        
        ZStack {
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack {
                HStack {
                    SyncIndicatorView(syncState: syncStateService)
                    Spacer()
                    TopFloatingBar { tappedItem in
                        switch tappedItem {
                        case .profile:
                            showProfile = true
                        case .notification:
                            showNotifications = true
                        }
                    }
                }
                
                Spacer()
                
                CustomTabBar(selectedTab: $selectedTab) {
                    mapRouter.navigateToCreateStory()
                }
            }
            // Keep chrome above tab content and tappable after sheets / system UI (e.g. screenshot flash).
            .zIndex(10)
            .allowsHitTesting(true)

            if showNotificationsOnboarding {
                NotificationsOnboardingView(
                    onAllow: {
                        Task {
                            let center = UNUserNotificationCenter.current()
                            _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
                            await MainActor.run {
                                hasSeenNotificationsOnboarding = true
                                withAnimation(.spring()) {
                                    showNotificationsOnboarding = false
                                }
                            }
                        }
                    },
                    onSkip: {
                        hasSeenNotificationsOnboarding = true
                        withAnimation(.spring()) {
                            showNotificationsOnboarding = false
                        }
                    }
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            if selectedTab == .map && showAlwaysLocationUpgrade {
                VStack {
                    Spacer()
                    AlwaysLocationUpgradeView(
                        onAllow: {
                            hasRequestedAlwaysLocationUpgrade = true
                            Task {
                                try? await container.makeLocationService().requestAlways()
                                await MainActor.run {
                                    withAnimation(.spring()) {
                                        showAlwaysLocationUpgrade = false
                                    }
                                }
                            }
                        },
                        onSkip: {
                            hasRequestedAlwaysLocationUpgrade = true
                            withAnimation(.spring()) {
                                showAlwaysLocationUpgrade = false
                            }
                        }
                    )
                    .padding(.bottom, 120)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .alert("Error de sincronización", isPresented: Binding(
            get: { if case .error = syncStateService.state { true } else { false } },
            set: { if !$0 { syncStateService.clearError() } }
        )) {
            Button("OK") { }
        } message: {
            if case .error(let msg) = syncStateService.state {
                Text(msg)
            }
        }
        .sheet(isPresented: $showProfile) {
            container.makeProfileView(
                onClose: {
                    showProfile = false
                }
            )
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsView(
                viewModel: container.makeNotificationsViewModel(),
                onItemTap: { _ in
                    selectedTab = .map
                    showNotifications = false
                }
            )
        }
        .sheet(
            item: $router.sheetDestination,
            onDismiss: {
                EcoKeyboard.dismiss()
                if mapRouter.consumeStoryReaderSheetDismissed() {
                    mapViewModel.recordMapReaderDismissed()
                }
                if let planted = mapRouter.consumeRecentPlanting() {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = .map
                    }
                    mapViewModel.queuePlantingAnimation(
                        coordinate: planted.coordinate,
                        storyId: planted.storyId
                    )
                }
                Task { await mapViewModel.onAppear() }
            },
            content: { destination in
                router.view(for: destination)
                    .id(destination.id)
            }
        )
        .sheet(
            item: Binding(
                get: { appRouter.activeStoryID.map { IdentifiableString(value: $0) } },
                set: { if $0 == nil { appRouter.dismissStoryDetail() } }
            ),
            onDismiss: { appRouter.dismissStoryDetail() },
            content: { item in
                NavigationStack {
                    StoryDetailFromDeepLinkView(
                        storyId: item.value,
                        resolveStory: { id in await container.resolveStoryIdForDeepLink(id) },
                        makeDetail: { uuid in
                            AnyView(
                                StoryDetailView(
                                    viewModel: container.makeStoryDetailViewModel(storyId: uuid),
                                    onDelete: nil
                                )
                            )
                        }
                    )
                }
            }
        )
        .onAppear {
            if let id = appRouter.consumePendingStoryID() {
                appRouter.handle(.storyDetail(id: id))
            }
            if appRouter.consumePendingOpenMap() {
                selectedTab = .map
            }
            if !hasSeenNotificationsOnboarding {
                showNotificationsOnboarding = true
            }
            evaluateAlwaysLocationUpgradePrompt()
        }
        .onChange(of: appRouter.openMapRequested) { _, requested in
            if requested {
                selectedTab = .map
                appRouter.clearOpenMapRequest()
            }
        }
        .onChange(of: selectedTab) { _, newValue in
            switch newValue {
            case .map:
                Task { await mapViewModel.onAppear() }
                evaluateAlwaysLocationUpgradePrompt()
            case .collection:
                Task { await collectionViewModel.onAppear() }
            }
        }
    }

    private func evaluateAlwaysLocationUpgradePrompt() {
        guard !hasRequestedAlwaysLocationUpgrade else {
            showAlwaysLocationUpgrade = false
            return
        }

        let status = CLLocationManager().authorizationStatus
        showAlwaysLocationUpgrade = (status == .authorizedWhenInUse)
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
                    makeDetailViewModel: { id in
                        container.makeStoryDetailViewModel(storyId: id)
                    },
                    onPlantFirstStory: {
                        selectedTab = .map
                        mapRouter.navigateToCreateStory()
                    },
                    onGoToMap: {
                        selectedTab = .map
                    }
                )
                    .toolbar(.hidden, for: .navigationBar)
            }
        }
    }
}

#if DEBUG
#Preview {
    RootView(container: PreviewRootViewDependencyContainer.shared)
}
#endif
