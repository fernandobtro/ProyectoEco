//
//  CollectionStoryCardRow.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Tarjeta Colección: título + extracto dentro del bloque crema; pie (fecha · ubicación) fuera y alineado a la izquierda.
//

import SwiftUI

struct CollectionStoryCardRow: View {
    let viewData: StoryViewData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewData.title)
                    .font(.poppins(.bold, size: 18))
                    .foregroundStyle(Color.theme.accent)
                    .multilineTextAlignment(.leading)

                Text(viewData.subtitle)
                    .font(.poppins(.regular, size: 15))
                    .foregroundStyle(Color.theme.secondaryText.opacity(0.92))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.theme.exploreCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            if let footnote = viewData.footnote, !footnote.isEmpty {
                Text(footnote)
                    .font(.poppins(.regular, size: 12))
                    .foregroundStyle(Color.theme.secondaryText.opacity(0.72))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
