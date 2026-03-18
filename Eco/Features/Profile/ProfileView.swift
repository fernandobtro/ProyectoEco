//
//  ProfileView.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import SwiftUI

struct ProfileView: View {
    @Bindable var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if let profile = viewModel.profile {
                    Text("Email: \(profile.email)")
                    TextField("Nickname", text: $viewModel.editableNickname)
                        .textFieldStyle(.roundedBorder)
                    Button("Guardar cambios") {
                        viewModel.saveProfile()
                    }
                    .buttonStyle(.bordered)
                } else if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                }

                Spacer()
                Button("Logout") {
                    viewModel.logout()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                Spacer()
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                viewModel.loadProfile()
            }
        }
    }
}
