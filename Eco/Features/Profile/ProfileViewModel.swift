//
//  ProfileViewModel.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Load/save ``AuthorProfile`` for the current session and expose logout.
//

import Foundation
import Observation

/// Bridges ``GetAuthorProfileUseCase``, ``SaveAuthorProfileUseCase``, and ``LogoutUseCaseProtocol`` to the profile UI.
///
/// Narrative: `docs/EcoCorePipelines.md` — **Email Login Pipeline** (session and author profile).
@MainActor
@Observable
final class ProfileViewModel {

    private let logoutUseCase: LogoutUseCaseProtocol
    private let getAuthorProfileUseCase: GetAuthorProfileUseCase
    private let saveAuthorProfileUseCase: SaveAuthorProfileUseCase
    private let getCurrentSessionUseCase: GetCurrentSessionUseCaseProtocol

    var profile: AuthorProfile?
    var editableNickname: String = ""
    /// True while the initial profile fetch is in progress.
    var isLoading: Bool = false
    /// True while saving nickname/profile changes.
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
                print("[ProfileVM] loadProfile loaded=\(loaded != nil)")
                #endif
                if let loadedProfile = loaded {
                    profile = loadedProfile
                    if let safe = EcoAuthorDisplayFormatting.displayNickname(loadedProfile.nickname, authorFirebaseUid: loadedProfile.id) {
                        editableNickname = safe
                    } else {
                        editableNickname = getCurrentSessionUseCase.getNickname() ?? ""
                    }
                } else if profile == nil {
                    // No remote profile yet: seed from session, keep existing in-memory profile if we already had one.
                    editableNickname = getCurrentSessionUseCase.getNickname() ?? ""
                }
            } catch {
                #if DEBUG
                print("[ProfileVM] loadProfile error=\(error.localizedDescription)")
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
