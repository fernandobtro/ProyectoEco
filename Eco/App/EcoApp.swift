//
//  EcoApp.swift
//  Eco
//
//  Created by Fernando Buenrostro on 26/02/26.
//

import FirebaseCore
import SwiftUI
import SwiftData

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct EcoApp: App {
    @State private var container = AppDIContainer()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            AuthGateView(container: container, viewModel: container.makeAuthGateViewModel())
        }
    }
}
