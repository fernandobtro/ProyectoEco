//
//  EcoApp.swift
//  Eco
//
//  Created by Fernando Buenrostro on 26/02/26.
//

import SwiftUI
import SwiftData

@main
struct EcoApp: App {
    @State private var container = AppDIContainer()

    var body: some Scene {
        WindowGroup {
            MapView(viewModel: container.makeMapViewModel(), router: container.makeMapRouter())
                .modelContainer(container.modelContainer)
        }
    }
}
