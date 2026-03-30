//
//  TopFloatingBar.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Floating header strip with profile / notifications actions (Eco chrome).
//

import Foundation
import SwiftUI

/// Rounded leading capsule with icon buttons, used over map/collection chrome.
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
        .padding(.leading, 20)
        .padding(.trailing, 16)
        .padding(.vertical, 12)
        .background {
            // Flat trailing edge, rounded leading corners
            UnevenRoundedRectangle(topLeadingRadius: 35, bottomLeadingRadius: 35)
                .fill(Color.theme.accent)
                .shadow(color: .black.opacity(0.15), radius: 8, x: -2, y: 4)
        }
        // Top inset only, trailing edge aligns flush with the screen
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
