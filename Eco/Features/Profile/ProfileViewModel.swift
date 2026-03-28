//
//  ProfileViewModel.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class ProfileViewModel {

    private let logoutUseCase: LogoutUseCaseProtocol
    private let getAuthorProfileUseCase: GetAuthorProfileUseCase
    private let saveAuthorProfileUseCase: SaveAuthorProfileUseCase
    private let getCurrentSessionUseCase: GetCurrentSessionUseCaseProtocol

    var profile: AuthorProfile?
    var editableNickname: String = ""
    /// Carga inicial del perfil.
    var isLoading: Bool = false
    /// Guardado del apodo en curso.
    var isSaving: Bool = false
    var errorMessage: String?
    private var isLoadInProgress = false

    init(
        logoutUseCase: LogoutUseCaseProtocol,
        getAuthorProfileUseCase: GetAuthorProfileUseCase,
        saveAuthorProfileUseCase: SaveAuthorProfileUseCase,
        getCurrentSessionUseCase: GetCurrentSessionUseCaseProtocol
    ) {
        self.logoutUseCase = logoutUseCase
        self.getAuthorProfileUseCase = getAuthorProfileUseCase
        self.saveAuthorProfileUseCase = saveAuthorProfileUseCase
        self.getCurrentSessionUseCase = getCurrentSessionUseCase
    }

    func logout() {
        try? logoutUseCase.execute()
    }

    func clearFormError() {
        errorMessage = nil
    }

    func loadProfile() {
        guard !isLoadInProgress else { return }
        isLoadInProgress = true
        isLoading = true
        errorMessage = nil

        Task {
            defer {
                isLoading = false
                isLoadInProgress = false
            }
            do {
                let loaded = try await getAuthorProfileUseCase.execute()
                #if DEBUG
                print("👤 [ProfileVM] loadProfile loaded=\(loaded != nil)")
                #endif
                if let p = loaded {
                    profile = p
                    if let safe = EcoAuthorDisplayFormatting.displayNickname(p.nickname, authorFirebaseUid: p.id) {
                        editableNickname = safe
                    } else {
                        editableNickname = getCurrentSessionUseCase.getNickname() ?? ""
                    }
                } else if profile == nil {
                    // Si nunca tuvimos perfil, dejamos estado vacío; si ya había uno, no lo pisamos.
                    editableNickname = getCurrentSessionUseCase.getNickname() ?? ""
                }
            } catch {
                #if DEBUG
                print("👤 [ProfileVM] loadProfile error=\(error.localizedDescription)")
                #endif
                errorMessage = error.localizedDescription
            }
        }
    }

    func saveProfile() {
        guard var current = profile else { return }
        errorMessage = nil
        isSaving = true

        current = AuthorProfile(
            id: current.id,
            email: current.email,
            nickname: editableNickname.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: current.createdAt
        )

        Task {
            do {
                try await saveAuthorProfileUseCase.execute(current)
                profile = current
                editableNickname = current.nickname
            } catch {
                errorMessage = error.localizedDescription
            }
            isSaving = false
        }
    }
}
