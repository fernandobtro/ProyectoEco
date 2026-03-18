//
//  ProfileViewModel.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation
import Observation

@Observable
final class ProfileViewModel {

    private let logoutUseCase: LogoutUseCaseProtocol
    private let getAuthorProfileUseCase: GetAuthorProfileUseCase
    private let saveAuthorProfileUseCase: SaveAuthorProfileUseCase

    var profile: AuthorProfile?
    var editableNickname: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    init(
        logoutUseCase: LogoutUseCaseProtocol,
        getAuthorProfileUseCase: GetAuthorProfileUseCase,
        saveAuthorProfileUseCase: SaveAuthorProfileUseCase
    ) {
        self.logoutUseCase = logoutUseCase
        self.getAuthorProfileUseCase = getAuthorProfileUseCase
        self.saveAuthorProfileUseCase = saveAuthorProfileUseCase
    }

    func logout() {
        try? logoutUseCase.execute()
    }

    func loadProfile() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let loaded = try await getAuthorProfileUseCase.execute()
                profile = loaded
                editableNickname = loaded?.nickname ?? ""
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    func saveProfile() {
        guard var current = profile else { return }
        current = AuthorProfile(
            id: current.id,
            email: current.email,
            nickname: editableNickname,
            createdAt: current.createdAt
        )

        Task {
            do {
                try await saveAuthorProfileUseCase.execute(current)
                profile = current
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
