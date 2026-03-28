//
//  TopFloatingBar.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation
import SwiftUI

struct TopFloatingBar: View {
    var onButtonTap: (FloatingBar) -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(FloatingBar.allCases, id: \.self) { item in
                Button {
                    onButtonTap(item)
                } label: {
                    Image(systemName: item.rawValue)
                        .font(.system(size: item == .profile ? 24 : 20, weight: .medium))
                        .foregroundStyle(Color.theme.primaryComponent)
                }
            }
        }
        .padding(.leading, 20) // Espacio interno izquierdo
        .padding(.trailing, 16) // Espacio interno derecho
        .padding(.vertical, 12)
        .background {
            // Figura plana de la derecha y redonda de la izquierda
            UnevenRoundedRectangle(topLeadingRadius: 35, bottomLeadingRadius: 35)
                .fill(Color.theme.accent)
                .shadow(color: .black.opacity(0.15), radius: 8, x: -2, y: 4)
        }
        // Solo dejamos padding arriba, a la derecha queda en 0 para pegar al borde
        .padding(.top, 16)
    }
}

#Preview {
    ZStack {
        Color.theme.primaryComponent.ignoresSafeArea()
        VStack {
            HStack {
                Spacer()
                TopFloatingBar { _ in }
            }
            Spacer()
        }
    }
}
