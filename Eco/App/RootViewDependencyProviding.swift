//
//  RootViewDependencyProviding.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Factory surface for ``RootView`` (map, collection, profile, notifications, deep-link detail).
//

import Foundation
import SwiftUI

/// Implemented by `AppDIContainer` and `PreviewRootViewDependencyContainer` so `RootView` stays testable and preview-friendly.
@MainActor
protocol RootViewDependencyProviding: AnyObject {

    // MARK: - Factories
    /// Map tab ViewModel (discovery, location, sync hooks).
    func makeMapViewModel() -> MapViewModel

    /// Map navigation helper (story creation factory, detail VM factory, author lookups).
    func makeMapRouter() -> MapRouter

    /// Collection tab ViewModel (planted vs discovered lists).
    func makeCollectionViewModel() -> CollectionViewModel

    /// Shared sync status for global UI (for example a sync indicator).
    func makeSyncStateService() -> SyncStateService

    /// Profile tab, `onClose` is used when the profile is presented as a sheet.
    func makeProfileView(onClose: (() -> Void)?) -> ProfileView

    /// Notifications list ViewModel.
    func makeNotificationsViewModel() -> NotificationsViewModel

    /// Location service used where the root flow needs GPS (not only the map VM).
    func makeLocationService() -> LocationServiceProtocol

    /// Story detail VM for a pushed or linked story id.
    func makeStoryDetailViewModel(storyId: UUID) -> StoryDetailViewModel

    /// Resolves a story id string from a deep link into a `UUID`, or `nil` when invalid.
    func resolveStoryIdForDeepLink(_ storyId: String) async -> UUID?
}

/// Production wiring lives in `AppDIContainer` (see `MARK: ViewModel Factories` there).
extension AppDIContainer: RootViewDependencyProviding {}
