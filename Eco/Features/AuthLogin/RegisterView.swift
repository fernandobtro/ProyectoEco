//
//  RegisterView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import SwiftUI

struct RegisterView: View {
    @Bindable var viewModel: RegisterViewModel
    let onLoginTap: () -> Void

    var body: some View {
        
        ZStack {
            Color.theme.accent
                .ignoresSafeArea()
                .onTapGesture {
                    EcoKeyboard.dismiss()
                }
            VStack {
                Circle()
                    .fill(Color.theme.primaryText)
                    .frame(width: 450, height: 450)
                    .offset(y: -250)
                    .overlay(
                        Image("EcoLogoLightBack")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .offset(y: -90)
                    )
                Spacer()
            }
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Spacer().frame(height: 100)

                    Text("Regístrate")
                        .font(.poppins(.bold, size: 26))
                        .foregroundStyle(Color.theme.primaryText)
                    VStack(spacing: 16) {
                        EcoTextField(
                            "Correo Electrónico",
                            text: $viewModel.email,
                            textInputAutocapitalization: .never,
                            keyboardType: .emailAddress,
                            textContentType: .emailAddress
                        )
                        EcoSecureField("Contraseña", text: $viewModel.password)

                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.theme.primaryText))
                        }

                        Button("Crear cuenta") {
                            viewModel.register()
                        }
                        .buttonStyle(EcoButtonStyle(backgroundColor: Color.theme.primaryComponent))
                        .padding(.top, 10)

                        Button("Ya tengo cuenta") {
                            onLoginTap()
                        }
                        .buttonStyle(EcoButtonStyle(backgroundColor: Color.theme.primaryComponent))

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundStyle(.red)
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 40)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

private struct MockRegisterUseCase: RegisterUseCaseProtocol {
    func execute(email: String, password: String) async throws -> String {
        UUID().uuidString
    }
}

private struct MockCreateAuthorProfileUseCase: CreateAuthorProfileUseCase {
    func execute(profile: AuthorProfile) async throws { }
}

#Preview {
    let viewModel = RegisterViewModel(
        registerUseCase: MockRegisterUseCase(),
        createAuthorProfileUseCase: MockCreateAuthorProfileUseCase()
    )
    RegisterView(viewModel: viewModel, onLoginTap: {})
}
