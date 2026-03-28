//
//  CollectionSegmentedControl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Pestañas estilo diseño: activo en verde bosque + subrayado grueso; inactivo en gris.
//

import SwiftUI

struct CollectionSegmentedControl: View {
    @Binding var selection: CollectionTab

    var body: some View {
        HStack(spacing: 0) {
            tabButton(title: "Mis Ecos", tab: .planted)
            tabButton(title: "Descubiertos", tab: .discovered)
        }
        .padding(.horizontal, 20)
    }

    private func tabButton(title: String, tab: CollectionTab) -> some View {
        let isSelected = selection == tab
        return Button {
            selection = tab
        } label: {
            VStack(spacing: 8) {
                Text(title)
                    .font(.poppins(isSelected ? .semiBold : .medium, size: 15))
                    .foregroundStyle(isSelected ? Color.theme.accent : Color.theme.secondaryText.opacity(0.55))
                    .lineLimit(1)
                    .minimumScaleFactor(0.86)
                Rectangle()
                    .fill(isSelected ? Color.theme.accent : Color.clear)
                    .frame(height: isSelected ? 3 : 0)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
