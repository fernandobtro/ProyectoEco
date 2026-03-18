//
//  SplashView.swift
//  Eco
//
//  Created by Fernando Buenrostro on 17/03/26.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            // Fondo usando el accent de tu ColorTheme
            Color.theme.accent
                .ignoresSafeArea()

            VStack(spacing: 28) {
                // Logo desde tus Assets
                Image("EcoLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)
                Image("EcoTypo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)

                // Texto con el eslogan
                Text("La ciudad tiene memoria.")
                    // Referencia explícita a Font para ayudar al compilador
                    .font(Font.poppins(.regular, size: 18))
                    .foregroundStyle(Color.primaryText)
            }
            .padding(.bottom, 190)
        }
    }
}

#Preview {
    SplashView()
}
