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
    var container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: StoryEntity.self, UserEntity.self)
        } catch {
            fatalError("No se pudo inicializar la base de datos: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
}
