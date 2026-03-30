//
//  SaveSessionNicknameUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Write the nickname to session storage and sync the Firebase-backed author profile.
//

import FirebaseAuth
import Foundation
import os

private let saveSessionNicknameLogger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "Eco",
    category: "SaveSessionNickname"
)

/// Write the nickname to session storage and sync the Firebase-backed author profile.
final class SaveSessionNicknameUseCaseImpl: SaveSessionNicknameUseCaseProtocol {

    // MARK: - Dependencies

    private let sessionRepository: SessionRepositoryProtocol
    private let authorProfileRepository: AuthorProfileRepositoryProtocol

    // MARK: - Init

    init(
        sessionRepository: SessionRepositoryProtocol,
        authorProfileRepository: AuthorProfileRepositoryProtocol
    ) {
        self.sessionRepository = sessionRepository
        self.authorProfileRepository = authorProfileRepository
    }

    // MARK: - Public API
    /// Persists the trimmed nickname locally first, then updates or creates the remote profile. Uses `Auth.auth().currentUser` when no profile exists yet.
    func execute(nickname: String) async {
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedNickname.isEmpty else {
            return
        }
        if let uid = try? sessionRepository.getCurrentUserId(),
           trimmedNickname == uid || trimmedNickname.caseInsensitiveCompare(uid) == .orderedSame {
            return
        }

        sessionRepository.saveNickname(trimmedNickname)

        // Remote is the source of truth: create a profile when missing for the signed-in user.
        do {
            if let currentProfile = try await authorProfileRepository.getCurrent() {
                let updated = AuthorProfile(
                    id: currentProfile.id,
                    email: currentProfile.email,
                    nickname: trimmedNickname,
                    createdAt: currentProfile.createdAt
                )
                try await authorProfileRepository.save(updated)
            } else if let user = Auth.auth().currentUser {
                let profile = AuthorProfile(
                    id: user.uid,
                    email: user.email ?? "",
                    nickname: trimmedNickname,
                    createdAt: Date()
                )
                try await authorProfileRepository.create(profile: profile)
            }
        } catch {
            // Policy: do not fail onboarding if remote persistence fails after local save.
            saveSessionNicknameLogger.error(
                "Remote sync failed after saving nickname: \(error.localizedDescription, privacy: .public)"
            )
        }
    }
}
