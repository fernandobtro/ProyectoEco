//
//  SplashView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {

            Color.theme.accent
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Image("EcoLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)
                Image("EcoTypo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)

                Text("La ciudad tiene memoria.")
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
