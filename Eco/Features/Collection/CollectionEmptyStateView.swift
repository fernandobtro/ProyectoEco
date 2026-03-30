//
//  CollectionEmptyStateView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Empty states for planted vs discovered, SF Symbol placeholders until final illustration assets.
//

import SwiftUI

/// Centered empty state with optional primary action (plant first story, go to map).
struct CollectionEmptyStateView: View {
    enum Kind {
        case plantedNoStories
        case discoveredNone
    }

    let kind: Kind
    var primaryActionTitle: String?
    var primaryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            illustration
                .padding(.top, 8)

            Text(title)
                .font(.poppins(.bold, size: 20))
                .foregroundStyle(Color.theme.accent)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            Text(subtitle)
                .font(.poppins(.regular, size: 16))
                .foregroundStyle(Color.theme.secondaryText.opacity(0.88))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            if let primaryActionTitle, let primaryAction {
                Button(action: primaryAction) {
                    Text(primaryActionTitle)
                        .font(.poppins(.semiBold, size: 16))
                        .foregroundStyle(Color.theme.primaryText)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Color.theme.accent))
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 12)
    }

    private var title: String {
        switch kind {
        case .plantedNoStories:
            "¿Aún no has plantado tu primer Eco?"
        case .discoveredNone:
            "Explora el mapa para descubrir historias ocultas"
        }
    }

    private var subtitle: String {
        switch kind {
        case .plantedNoStories:
            "¡El mundo necesita historias!"
        case .discoveredNone:
            "Sigue los Ecos del mapa para desbloquear nuevas historias."
        }
    }

    @ViewBuilder
    private var illustration: some View {
        switch kind {
        case .plantedNoStories:
            ZStack {
                Image(systemName: "circle.dashed")
                    .font(.system(size: 108, weight: .ultraLight))
                    .foregroundStyle(Color.theme.accent.opacity(0.28))
                VStack(spacing: 2) {
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 48, weight: .light))
                    Image(systemName: "leaf")
                        .font(.system(size: 22, weight: .light))
                }
                .foregroundStyle(Color.theme.accent)
            }
            .frame(height: 130)
        case .discoveredNone:
            ZStack {
                Image(systemName: "lock.open")
                    .font(.system(size: 58, weight: .light))
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 30, weight: .light))
                    .offset(x: 22, y: -26)
            }
            .foregroundStyle(Color.theme.accent)
            .frame(height: 130)
        }
    }
}
