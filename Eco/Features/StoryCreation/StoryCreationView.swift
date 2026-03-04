//
//  StoryCreationView.swift
//  Eco
//
//  Created by Fernando Buenrostro on 03/03/26.
//

import Foundation
import SwiftUI

struct StoryCreationView: View {
    @ObservedObject var viewModel: StoryCreationViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("¿Qué historias viven aquí?")) {
                    TextField("Título del Eco", text: $viewModel.title)
                    
                    TextEditor(text: $viewModel.content)
                        .frame(minHeight: 150)
                        .overlay(Text(viewModel.content.isEmpty ? "Escribe aquí tu historia..." : "")
                            .foregroundStyle(.gray)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                            .allowsHitTesting(false),
                                 alignment: .topLeading)
                }
                Section {
                    Button(action: {
                        Task {
                            await viewModel.plantStory()
                            if viewModel.error == nil { dismiss() }
                        }
                    }) {
                        if viewModel.isPlanting {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text("Plantar historia")
                                .bold()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(viewModel.title.isEmpty || viewModel.content.isEmpty)
                }
                
                Section(header: Text("Ubicación detectada")) {
                    Text(viewModel.locationDisplayString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Nuevo Eco")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .alert("¡Ups!", isPresented: .init(get: { viewModel.error != nil }, set: { _ in viewModel.error = nil } )) {
                Button("Entendido", role: .cancel) { }
            } message: {
                Text(viewModel.error ?? "")
            }
        }
    }
}
