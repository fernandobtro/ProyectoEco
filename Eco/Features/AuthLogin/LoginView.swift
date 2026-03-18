//
//  LoginView.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @Bindable var viewModel: LoginViewModel
    let onRegisterTap: () -> Void
    
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
            
            Button("Login") {
                viewModel.login()
            }
            
            Button("Crear cuenta") {
                onRegisterTap()
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
