//
//  CollectionView.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation
import SwiftUI

struct CollectionView: View {
    @Bindable var viewModel: CollectionViewModel
    let makeDetailView: (UUID) -> StoryDetailView
    
    var body: some View {
        VStack {
            Picker("Tipo", selection: $viewModel.selectedSegment) {
                Text("Mis Ecos").tag(CollectionTab.planted)
                Text("Descubrimientos").tag(CollectionTab.discovered)
            }
            .pickerStyle(.segmented)
            .padding()

            Group {
                switch viewModel.state {
                case .idle, .loading:
                    ProgressView("Cargando...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .error(let message):
                    Text(message)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .loaded:
                    listContent
                }
            }
        }
        .navigationTitle("Colección")
        .task {
            await viewModel.onAppear()
        }
        .navigationDestination(for: UUID.self) { id in
            makeDetailView(id)
        }
    }
    
    @ViewBuilder
    private var listContent: some View {
        switch viewModel.selectedSegment {
        case .planted:
            if viewModel.plantedStories.isEmpty {
                Text("Aún no has plantado ningún Eco.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.plantedStories) { story in
                        NavigationLink(value: story.id) {
                            row(for: story)
                        }
                    }
                    .onDelete { offsets in
                        Task {
                            await viewModel.deletePlantedStories(at: offsets)
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.refresh()
                }
            }
        case .discovered:
            if viewModel.discoveredStories.isEmpty {
                Text("Todavía no has descubierto ningún Eco.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.discoveredStories) { story in
                    NavigationLink(value: story.id) {
                        row(for: story)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
    }

    private func row(for story: Story) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(story.isSynced ? Color.theme.accent : Color.orange)
                    .frame(width: 10, height: 10)

                if !story.isSynced {
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                        .frame(width: 14, height: 14)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(story.title)
                    .font(.headline)
                Text(story.content)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
