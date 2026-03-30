//
//  OnboardingNicknameView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Post-auth step to choose a display nickname before entering the app.
//

import Foundation
import SwiftUI

/// Single-field nickname capture, calls `onFinish` with the trimmed value.
struct OnboardingNicknameView: View {
    @State private var nickname: String = ""
    var onFinish: (String) -> Void
    
    var body: some View {
        ZStack {
            Color.theme.primaryComponent
                .ignoresSafeArea()
                .onTapGesture {
                    EcoKeyboard.dismiss()
                }

            ScrollView {
                VStack(spacing: 40) {
                    Text("¿Cómo te llaman\n por aquí?")
                        .font(.poppins(.bold, size: 32))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.theme.accent)

                    TextField(
                        "",
                        text: $nickname,
                        prompt: Text("Tu nombre o apodo...")
                            .foregroundStyle(Color.theme.secondaryText.opacity(0.6))
                    )
                        .font(.poppins(.medium, size: 18))
                        .padding()
                        .foregroundStyle(Color.theme.secondaryText)
                        .background(Color.white.opacity(0.95))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal, 40)

                    Button("Entrar al mapa") {
                        EcoKeyboard.dismiss()
                        onFinish(nickname)
                    }
                    .buttonStyle(EcoButtonStyle(backgroundColor: Color.theme.accent, isEnabled: !nickname.isEmpty))
                    .disabled(nickname.isEmpty)
                    .padding(.horizontal, 40)

                    Spacer(minLength: 80)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

#Preview {
    OnboardingNicknameView { _ in }
}
