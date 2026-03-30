//
//  StoryDetailFromDeepLinkView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Resolves a string story id from deep links/notifications to a local UUID, then presents ``StoryDetailView`` (sync/retry when missing).
//

import SwiftUI

/// Entry from `AppRouter` / notifications: resolve id, then show detail or a not-found state.
///
/// Narrative: `docs/EcoCorePipelines.md` — **Story Detail (Read / Unlock / Edit / Delete) Pipeline** (notification/deep link).
struct StoryDetailFromDeepLinkView: View {
    let storyId: String
    private let resolveStory: (String) async -> UUID?
    private let makeDetail: (UUID) -> AnyView

    @Environment(\.dismiss) private var dismiss
    @State private var resolvedUUID: UUID?
    @State private var isResolving = true

    init(storyId: String, container: AppDIContainer) {
        self.storyId = storyId
        self.resolveStory = { id in
            await container.resolveStoryIdForDeepLink(id)
        }
        self.makeDetail = { id in
            AnyView(
                StoryDetailView(
                    viewModel: container.makeStoryDetailViewModel(storyId: id),
                    onDelete: nil
                )
            )
        }
    }

    init(
        storyId: String,
        resolveStory: @escaping (String) async -> UUID?,
        makeDetail: @escaping (UUID) -> AnyView
    ) {
        self.storyId = storyId
        self.resolveStory = resolveStory
        self.makeDetail = makeDetail
    }

    var body: some View {
        Group {
            if isResolving {
                ProgressView("Cargando Eco...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let uuid = resolvedUUID {
                makeDetail(uuid)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No se encontró la historia")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Button("Cerrar") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Detalle del Eco")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cerrar") {
                    dismiss()
                }
            }
        }
        .task {
            resolvedUUID = await resolveStory(storyId)
            isResolving = false
        }
    }
}

#Preview {
    NavigationStack {
        StoryDetailFromDeepLinkView(
            storyId: UUID().uuidString,
            resolveStory: { _ in UUID() },
            makeDetail: { id in
                AnyView(
                    Text("Mock detalle para \(id.uuidString.prefix(8))")
                        .padding()
                )
            }
        )
    }
}
