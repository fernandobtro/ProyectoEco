//
//  EditStoryView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//

import CoreLocation
import SwiftUI

private enum EditStoryFocusedField: Hashable {
    case title
    case content
}

/// Misma estética que `StoryCreationView`, sin mapa.
struct EditStoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: StoryDetailViewModel

    @State private var title: String = ""
    @State private var content: String = ""
    @FocusState private var focusedField: EditStoryFocusedField?

    var body: some View {
        ZStack {
            Color.theme.accent
                .ignoresSafeArea()
                .onTapGesture {
                    focusedField = nil
                    EcoKeyboard.dismiss()
                }

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.theme.primaryText.opacity(0.8))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 24) {
                            Text("Editar Eco")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.theme.primaryText)
                                .multilineTextAlignment(.center)

                            storyInputBlock

                            if let error = viewModel.updateError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 8)
                            }

                            saveButton
                                .padding(.top, 8)

                            Spacer(minLength: 120)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: focusedField) { _, new in
                        guard let new else { return }
                        let scrollId: String
                        let anchor: UnitPoint
                        switch new {
                        case .title:
                            scrollId = "editTitleField"
                            anchor = UnitPoint(x: 0.5, y: 0.2)
                        case .content:
                            scrollId = "editContentField"
                            anchor = UnitPoint(x: 0.5, y: 0.28)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                            withAnimation(.easeInOut(duration: 0.32)) {
                                proxy.scrollTo(scrollId, anchor: anchor)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            syncFieldsFromViewModel()
            focusedField = .title
        }
        .onChange(of: viewModel.state) { _, _ in
            syncFieldsFromViewModel()
        }
    }

    private func syncFieldsFromViewModel() {
        if let story = viewModel.story {
            title = story.title
            content = story.content
        }
    }

    private var storyInputBlock: some View {
        VStack(spacing: 0) {
            TextField(
                "",
                text: $title,
                prompt: Text("Título de tu eco").foregroundColor(Color.theme.primaryText.opacity(0.6))
            )
            .font(.headline)
            .foregroundStyle(Color.theme.primaryText)
            .padding()
            .focused($focusedField, equals: .title)
            .id("editTitleField")

            Rectangle()
                .fill(Color.theme.primaryText.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, 16)

            TextEditor(text: $content)
                .scrollContentBackground(.hidden)
                .foregroundStyle(Color.theme.primaryText)
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .frame(minHeight: 160)
                .focused($focusedField, equals: .content)
                .id("editContentField")
                .overlay(alignment: .topLeading) {
                    if content.isEmpty {
                        Text("Escribe aquí tu historia...")
                            .foregroundStyle(Color.theme.primaryText.opacity(0.5))
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .allowsHitTesting(false)
                    }
                }
        }
        .background {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.theme.primaryText.opacity(0.5), lineWidth: 1)
                .background(Color.theme.primaryText.opacity(0.05).cornerRadius(16))
        }
    }

    private var saveButton: some View {
        Button(action: {
            Task {
                focusedField = nil
                EcoKeyboard.dismiss()
                await viewModel.updateStory(title: title, content: content)
                if viewModel.updateError == nil {
                    dismiss()
                }
            }
        }) {
            if viewModel.isUpdating {
                ProgressView()
                    .tint(Color.theme.accent)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Capsule().fill(Color.theme.primaryComponent.opacity(0.5)))
            } else {
                Text("Guardar cambios")
                    .font(.headline)
                    .foregroundStyle(Color.theme.accent)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Capsule().fill(Color.theme.primaryComponent))
            }
        }
        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isUpdating)
        .opacity(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
    }
}

private struct MockGetStoryDetailUseCaseForEditPreview: GetStoryDetailUseCaseProtocol {
    let story: Story
    func execute(id: UUID) async throws -> Story? { story }
}

private struct MockGetLocationUseCaseForEditPreview: GetCurrentLocationForPlantingUseCaseProtocol {
    func requestLocation() async -> CLLocationCoordinate2D? { nil }
}

private struct MockUpdateStoryUseCaseForEditPreview: UpdateStoryUseCaseProtocol {
    func execute(_ story: Story) async throws { }
}

private struct MockDeleteStoryUseCaseForEditPreview: DeleteStoryUseCaseProtocol {
    func execute(storyId: UUID) async throws { }
}

private struct MockSyncStoriesUseCaseForEditPreview: SyncStoriesUseCase {
    func execute() async { }
}

private struct MockSessionRepositoryForEditPreview: SessionRepositoryProtocol {
    func getCurrentUserId() throws -> String { "mock-uid" }
    func getNickname() -> String? { "Mock" }
    func saveNickname(_ name: String) { }
}

#Preview {
    let sample = Story(
        id: UUID(),
        title: "Eco editable",
        content: "Contenido inicial",
        authorID: "mock-uid",
        latitude: 19.4326,
        longitude: -99.1332,
        isSynced: true,
        updatedAt: Date()
    )
    let vm = StoryDetailViewModel(
        storyId: sample.id,
        getStoryDetailUseCase: MockGetStoryDetailUseCaseForEditPreview(story: sample),
        getLocationUseCase: MockGetLocationUseCaseForEditPreview(),
        updateStoryUseCase: MockUpdateStoryUseCaseForEditPreview(),
        deleteStoryUseCase: MockDeleteStoryUseCaseForEditPreview(),
        syncStoriesUseCase: MockSyncStoriesUseCaseForEditPreview(),
        sessionRepository: MockSessionRepositoryForEditPreview()
    )
    return EditStoryView(viewModel: vm)
}
