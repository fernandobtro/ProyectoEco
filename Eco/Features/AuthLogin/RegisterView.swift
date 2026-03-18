//
//  RegisterView.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import SwiftUI

struct RegisterView: View {
    @Bindable var viewModel: RegisterViewModel
    let onLoginTap: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)

            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)

            if viewModel.isLoading {
                ProgressView()
            }

            Button("Crear cuenta") {
                viewModel.register()
            }

            Button("Ya tengo cuenta") {
                onLoginTap()
            }
            .font(.footnote)

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
            }
        }
        .padding()
    }
}
