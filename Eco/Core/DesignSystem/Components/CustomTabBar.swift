//
//  CustomTabBar.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 15/03/26.
//

import Foundation
import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: TabBar
    var onPlusButtonTap: () -> Void
    
    @Namespace private var animation
    @State private var tabLocation: CGRect = .zero
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 0) {
                tabCustomButton(for: .map)
                tabCustomButton(for: .collection)
            }
            .padding(.horizontal, 10)
            .frame(height: 70)
            .background {
                RoundedRectangle(cornerRadius: 35)
                    .fill(Color.theme.accent)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            }
            .coordinateSpace(name: "TABBARVIEW")
            
            customButton
        }
        .padding(.horizontal, 20)
    }
    
    private var customButton: some View {
        Button(action: onPlusButtonTap) {
            ZStack {
                Circle()
                    .fill(Color.theme.accent)
                    .frame(width: 72, height: 72)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)

                Image("PlusButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42, height: 42)
            }
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
    
    private func tabCustomButton(for tab: TabBar) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: tab.rawValue)
                    .font(.system(size: 20))
                    .scaleEffect(selectedTab == tab ? 1.2 : 1.0)
            }
            .foregroundStyle(selectedTab == tab ? Color.theme.exploreBackground : .white.opacity(0.72))
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .contentShape(.rect)
            .background {
                if selectedTab == tab {
                    Capsule()
                        .fill(Color.white.opacity(0.22))
                        .onGeometryChange(for: CGRect.self, of: { proxy in
                            proxy.frame(in: .named("TABBARVIEW"))
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
