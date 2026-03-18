//
//  CustomTabBar.swift
//  Eco
//
//  Created by Fernando Buenrostro on 15/03/26.
//

import Foundation
import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: TabBar
    var onPlusButtonTap: () -> Void
    
    // Propiedades para la animación de la cápsula (del archivo 1)
    @Namespace private var animation
    @State private var tabLocation: CGRect = .zero
    
    var body: some View {
        ZStack(alignment: .top) {
            // 1. Fondo de la barra (el contenedor oscuro)
            RoundedRectangle(cornerRadius: 35)
                .fill(Color.theme.accent) // Tu AccentColor de Assets
                .frame(height: 70)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
            
            // 2. Botones de navegación
            HStack(spacing: 0) {
                tabButton(for: .map)
                
                // Espacio transparente para que los botones no choquen con el "+"
                Color.clear.frame(width: 70)

                tabButton(for: .collection)
            }
            .padding(.horizontal, 35)
            .frame(height: 70)
            // Define el espacio de coordenadas para que matchedGeometry sepa dónde moverse
            .coordinateSpace(.named("TABBARVIEW"))
            
            // 3. Botón flotante central
            plusButton
        }
        // Animación suave para los cambios de estado (incluyendo la aparición del texto)
        .animation(.smooth(duration: 0.3, extraBounce: 0), value: selectedTab)
    }
    
    // MARK: - Componentes
    
    private var plusButton: some View {
        Button(action: onPlusButtonTap) {
            ZStack {
                Circle()
                    .fill(Color.theme.primaryComponent) // Tu color verde claro
                    .frame(width: 62, height: 62)
                    .shadow(color: Color.theme.primaryComponent.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.accent)
            }
        }
        // Posicionamiento arriba de la barra
        .offset(y: -28)
    }
    
    private func tabButton(for tab: TabBar) -> some View {
        Button {
            selectedTab = tab
        } label: {
            HStack(spacing: 8) {
                Image(systemName: tab.rawValue)
                    .font(.system(size: 20))
                
                            }
           
            .foregroundStyle(selectedTab == tab ? Color.theme.accent : .primaryComponent)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .contentShape(.rect)
            .background {
                if selectedTab == tab {
                    // La cápsula que "viaja" entre botones
                    Capsule()
                        .fill(Color.theme.primaryComponent)
                        .onGeometryChange(for: CGRect.self, of: {
                            $0.frame(in: .named("TABBARVIEW"))
                        }, action: { newValue in
                            tabLocation = newValue
                        })
                        .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var tab: TabBar = .map
        var body: some View {
            ZStack(alignment: .bottom) {
                Color.gray.opacity(0.2).ignoresSafeArea()
                
                CustomTabBar(selectedTab: $tab) {
                    print("Plus tapped")
                }
            }
        }
    }
    return PreviewWrapper()
}
