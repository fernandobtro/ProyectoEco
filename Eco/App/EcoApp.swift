//
//  EcoApp.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: App entry: Firebase, notification delegate - `AppRouter`, `AuthGateView`, Google Sign-In URLs.
//

import FirebaseCore
import GoogleSignIn
import SwiftData
import SwiftUI
import UserNotifications

/// Configures Firebase on launch and bridges push/local notification taps into ``AppRouter``.
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    // MARK: - UIApplicationDelegate

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }

        return true
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        handleNotificationPayload(userInfo, isLaunch: true)
        completionHandler(.noData)
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        handleNotificationPayload(userInfo, isLaunch: false)
        completionHandler()
    }
}

// MARK: - Notification Payload
/// If the app was closed (`isLaunch`), queues the next step on `AppRouter`, if it’s already running, navigates right away.
private func handleNotificationPayload(_ payload: [AnyHashable: Any], isLaunch: Bool) {
    if let storyId = extractStoryId(from: payload) {
        Task { @MainActor in
            if isLaunch {
                AppRouter.shared.setPendingStoryID(storyId)
            } else {
                AppRouter.shared.handle(.storyDetail(id: storyId))
            }
        }
    } else if extractDeepLinkMap(from: payload) {
        Task { @MainActor in
            if isLaunch {
                AppRouter.shared.setPendingOpenMap(true)
            } else {
                AppRouter.shared.handle(.openMap)
            }
        }
    }
}

private func extractStoryId(from payload: [AnyHashable: Any]) -> String? {
    if let id = payload["storyId"] as? String { return id }
    if let data = payload["data"] as? [AnyHashable: Any],
       let id = data["storyId"] as? String { return id }
    return nil
}

private func extractDeepLinkMap(from payload: [AnyHashable: Any]) -> Bool {
    if let deepLink = payload["deepLink"] as? String, deepLink == "map" { return true }
    if let data = payload["data"] as? [AnyHashable: Any],
       let deepLink = data["deepLink"] as? String, deepLink == "map" { return true }
    return false
}

// MARK: - App Entry
/// Application entry point, composition and factories live in ``AppDIContainer``.
///
/// Firebase, notifications, and URL handling are outlined in `docs/EcoCorePipelines.md` (auth and cross-cutting sections).
@main
struct EcoApp: App {
    @State private var container = AppDIContainer()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            AuthGateView(container: container, viewModel: container.makeAuthGateViewModel())
                .onOpenURL { url in
                    _ = GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
