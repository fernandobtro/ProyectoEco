//
//  ProfileView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import SwiftUI

struct ProfileView: View {
    @Bindable var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    var onClose: (() -> Void)?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.theme.accent
                .ignoresSafeArea()
                .onTapGesture {
                    EcoKeyboard.dismiss()
                }

            ScrollView {
                VStack(spacing: 28) {
                    profileHeader

                    if viewModel.isLoading {
                        ProgressView()
                            .tint(Color.theme.primaryText)
                            .padding(.top, 24)
                    } else if let profile = viewModel.profile {
                        identityForm(profile: profile)
                    } else if let error = viewModel.errorMessage, viewModel.profile == nil {
                        Text(error)
                            .font(.poppins(.regular, size: 15))
                            .foregroundStyle(Color.theme.profileDestructive)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Spacer(minLength: 24)

                    Button {
                        viewModel.logout()
                        onClose?()
                        dismiss()
                    } label: {
                        Text("Cerrar sesión")
                            .font(.poppins(.semiBold, size: 16))
                            .foregroundStyle(Color.theme.profileDestructive)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)
                .padding(.top, 56)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .overlay(alignment: .topTrailing) {
            closeButton
                .padding(.top, 16)
                .padding(.trailing, 16)
        }
        .task { viewModel.loadProfile() }
        .onChange(of: viewModel.editableNickname) { _, _ in
            viewModel.clearFormError()
        }
    }

    private var closeButton: some View {
        Button {
            onClose?()
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.theme.primaryText)
                .frame(width: 36, height: 36)
                .background(Circle().stroke(Color.theme.primaryText.opacity(0.5), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Cerrar")
    }

    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.theme.primaryText.opacity(0.85), lineWidth: 1.5)
                    .frame(width: 88, height: 88)
                Image(systemName: "person")
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(Color.theme.primaryText)
            }

            Text("Mi Perfil")
                .font(.poppins(.bold, size: 24))
                .foregroundStyle(Color.theme.primaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private func identityForm(profile: AuthorProfile) -> some View {
        let nicknameInvalid = viewModel.errorMessage != nil

        return VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Dirección de email")
                    .font(.poppins(.medium, size: 13))
                    .foregroundStyle(Color.theme.primaryText.opacity(0.85))

                Text(profile.email)
                    .font(.poppins(.regular, size: 16))
                    .foregroundStyle(Color.theme.primaryText.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.theme.profileFieldSurface)
                    )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Apodo / Nombre de autor")
                    .font(.poppins(.medium, size: 13))
                    .foregroundStyle(Color.theme.primaryText.opacity(0.85))

                TextField("", text: $viewModel.editableNickname, prompt: Text("Tu apodo").foregroundStyle(Color.theme.primaryText.opacity(0.35)))
                    .font(.poppins(.regular, size: 16))
                    .foregroundStyle(Color.theme.primaryText)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.theme.profileFieldSurface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(
                                nicknameInvalid ? Color.theme.profileDestructive : Color.theme.primaryText.opacity(0.45),
                                lineWidth: nicknameInvalid ? 1.5 : 1
                            )
                    )
            }

            if let msg = viewModel.errorMessage, !msg.isEmpty {
                Text(msg)
                    .font(.poppins(.regular, size: 13))
                    .foregroundStyle(Color.theme.profileDestructive)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }

            Button {
                viewModel.saveProfile()
            } label: {
                HStack(spacing: 10) {
                    if viewModel.isSaving {
                        ProgressView()
                            .tint(Color.theme.accent)
                    }
                    Text(viewModel.isSaving ? "Guardando..." : "Guardar cambios")
                        .font(.poppins(.semiBold, size: 16))
                }
                .foregroundStyle(Color.theme.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Capsule().fill(Color.theme.primaryText))
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isSaving)
            .opacity(viewModel.isSaving ? 0.85 : 1)
            .padding(.top, 8)
        }
    }
}

private struct MockLogoutUseCaseForPreview: LogoutUseCaseProtocol {
    func execute() throws { }
}

private struct MockGetAuthorProfileUseCaseForPreview: GetAuthorProfileUseCase {
    func execute() async throws -> AuthorProfile? {
        AuthorProfile(
            id: "mock-uid",
            email: "juan.perez@email.com",
            nickname: "JuanP",
            createdAt: Date()
        )
    }
}

private struct MockSaveAuthorProfileUseCaseForPreview: SaveAuthorProfileUseCase {
    func execute(_ profile: AuthorProfile) async throws { }
}

private struct MockGetCurrentSessionUseCaseForPreview: GetCurrentSessionUseCaseProtocol {
    func execute() -> String? { "mock-uid" }
    func getNickname() -> String? { "PreviewUser" }
}

#Preview {
    ProfileView(
        viewModel: ProfileViewModel(
            logoutUseCase: MockLogoutUseCaseForPreview(),
            getAuthorProfileUseCase: MockGetAuthorProfileUseCaseForPreview(),
            saveAuthorProfileUseCase: MockSaveAuthorProfileUseCaseForPreview(),
            getCurrentSessionUseCase: MockGetCurrentSessionUseCaseForPreview()
        ),
        onClose: {}
    )
}
