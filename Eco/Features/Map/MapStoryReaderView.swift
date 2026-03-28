//
//  MapStoryReaderView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Lector minimal desde el mapa: título, apodo, texto justificado en accent, fondo crema.
//

import SwiftUI
import UIKit

struct MapStoryReaderView: View {
    @Bindable var viewModel: StoryDetailViewModel
    private let authorProfileByIdUseCase: GetAuthorProfileByIdUseCaseProtocol

    /// `nil` = aún no resuelto o sin `authorId` (no mostramos línea). Tras fetch: apodo o «Autor desconocido».
    @State private var resolvedAuthorLine: String?

    init(
        viewModel: StoryDetailViewModel,
        authorProfileByIdUseCase: GetAuthorProfileByIdUseCaseProtocol
    ) {
        self.viewModel = viewModel
        self.authorProfileByIdUseCase = authorProfileByIdUseCase
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Cargando Eco...")
                    .tint(Color.theme.accent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .error(let message):
                Text(message)
                    .font(.poppins(.regular, size: 15))
                    .foregroundStyle(Color.theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded(let story):
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(story.title)
                            .font(.poppins(.bold, size: 22))
                            .foregroundStyle(Color.theme.accent)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if let authorLine = resolvedAuthorLine {
                            Text(authorLine)
                                .font(.poppins(.medium, size: 14))
                                .foregroundStyle(Color.theme.secondaryText.opacity(0.9))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        if viewModel.isUnlocked {
                            JustifiedStoryBody(
                                text: story.content,
                                textColor: UIColor(named: "AccentColor") ?? .systemGreen
                            )
                            .frame(minHeight: 120)
                        } else {
                            Text("Acércate a este lugar para leer el Eco completo.")
                                .font(.poppins(.regular, size: 15))
                                .foregroundStyle(Color.theme.secondaryText)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(viewModel.distanceText)
                                .font(.poppins(.medium, size: 13))
                                .foregroundStyle(Color.theme.accent.opacity(0.85))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.exploreBackground.ignoresSafeArea())
        .task {
            #if DEBUG
            print("🗺️ [MapStoryReaderView] task storyId=\(viewModel.storyId.uuidString)")
            #endif
            await viewModel.loadDetail()
            await loadAuthorNickname(for: viewModel.story?.authorID)
        }
    }

    private func loadAuthorNickname(for authorId: String?) async {
        guard let authorId else {
            await MainActor.run { resolvedAuthorLine = nil }
            return
        }
        do {
            let profile = try await authorProfileByIdUseCase.execute(authorId: authorId)
            await MainActor.run {
                if let safe = EcoAuthorDisplayFormatting.displayNickname(profile?.nickname, authorFirebaseUid: authorId) {
                    resolvedAuthorLine = safe
                } else {
                    resolvedAuthorLine = "Autor desconocido"
                }
            }
        } catch {
            await MainActor.run { resolvedAuthorLine = "Autor desconocido" }
        }
    }
}

// MARK: - Texto justificado (UIKit)

private struct JustifiedStoryBody: UIViewRepresentable {
    let text: String
    let textColor: UIColor

    func makeUIView(context: Context) -> UITextView {
        let textview = UITextView()
        textview.isEditable = false
        textview.isScrollEnabled = false
        textview.backgroundColor = .clear
        textview.textContainerInset = .zero
        textview.textContainer.lineFragmentPadding = 0
        textview.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textview
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .justified
        paragraph.lineBreakMode = .byWordWrapping
        let font = UIFont(name: "Poppins-Regular", size: 16) ?? .systemFont(ofSize: 16, weight: .regular)
        uiView.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: textColor,
                .paragraphStyle: paragraph
            ]
        )
    }
}
