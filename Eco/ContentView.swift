//
//  ContentView.swift
//  Eco
//
//  Created by Fernando Buenrostro on 26/02/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // 1. Tomamos el "bloc de notas" de la App [cite: 2026-02-28]
    @Environment(\.modelContext) private var modelContext
    
    // 2. Vigilamos la base de datos automáticamente [cite: 2026-02-28]
    @Query private var savedEntities: [StoryEntity]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(savedEntities) { entity in
                    VStack(alignment: .leading) {
                        Text(entity.title).font(.headline)
                        Text(entity.content).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Eco: Mis Historias")
            .toolbar {
                Button("Plantar Eco") {
                    plantarEcoDePrueba()
                }
            }
        }
    }
    
    // 3. La lógica de conexión que construiste
    private func plantarEcoDePrueba() {
        Task {
            // Instanciamos la cadena de mando [cite: 2026-02-19]
            let dataSource = SwiftDataStoryDataSource(modelContext: modelContext)
            let repository = StoryRepository(storyLocalDataSource: dataSource)
            
            // Creamos una historia de Dominio (struct) [cite: 2026-02-19]
            let nuevaStory = Story(
                id: UUID(),
                title: "Eco en el Zócalo",
                content: "Aquí empezó una gran aventura en CDMX.",
                authorID: UUID(),
                latitude: 19.4326,
                longitude: -99.1332
            )
            
            do {
                // El Repositorio hace el Mapping y el DataSource guarda [cite: 2026-02-19]
                try await repository.save(story: nuevaStory)
                print("✅ ¡Eco guardado con éxito!")
            } catch {
                print("❌ Error al guardar: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
