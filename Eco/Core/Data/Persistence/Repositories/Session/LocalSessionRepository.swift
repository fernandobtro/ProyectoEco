//
//  LocalSessionRepository.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//  Purpose: Local persistence of user session metadata and profile settings using UserDefaults.
//
//  Responsibilities:
//  - Provide scoped storage for user-specific settings (like nicknames) using UID-based keys.
//  - Handle seamless migration from legacy global keys to user-scoped identifiers.
//  - Bridge AuthRepository state with local preferences for the active session.
//

import Foundation

class LocalSessionRepository: SessionRepositoryProtocol {
    private let defaults = UserDefaults.standard
    private let legacyNicknameKey = "current_eco_nickname"
    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    // MARK: Public API
    /// Retrieves the unique identifier for the currently authenticated user.
    /// - Returns: The Firebase UID as a `String`.
    /// - Throws: `AuthError.noAuthenticatedUser` if the user isn't signed in.
    func getCurrentUserId() throws -> String {
        guard let uid = authRepository.currentUserId(), !uid.isEmpty else {
            throw AuthError.noAuthenticatedUser
        }
        return uid
    }
    
    /// Persists a nickname locally, automatically scoping it to the current user's UID.
    /// - Note: This method also clean up any legacy global nickname keys to maintain store integrity.
    /// - Parameter name: The new nickname to save.
    func saveNickname(_ name: String) {
        if let uid = authRepository.currentUserId(), !uid.isEmpty {
            defaults.set(name, forKey: nicknameKey(for: uid))
            defaults.removeObject(forKey: legacyNicknameKey)
        } else {
            defaults.set(name, forKey: legacyNicknameKey)
        }
    }
    
    /// Fetches the nickname for the active session.
    /// Attempts to find a UID-scoped nickname. If not found, it checks for a legacy key and performs a just in time migration to the scoped key.
    /// - Returns: The user's nickname, or `nil` if name has been set.
    func getNickname() -> String? {
        if let uid = authRepository.currentUserId(), !uid.isEmpty {
            if let scoped = defaults.string(forKey: nicknameKey(for: uid)) {
                return scoped
            }
            // Migración suave desde llave legacy de versiones anteriores.
            if let legacy = defaults.string(forKey: legacyNicknameKey) {
                defaults.set(legacy, forKey: nicknameKey(for: uid))
                defaults.removeObject(forKey: legacyNicknameKey)
                return legacy
            }
            return nil
        }
        return defaults.string(forKey: legacyNicknameKey)
    }
    
    // MARK: - Private Helpers
    /// Generates a unique UserDefaults key by appending the user's UID.
    /// - Parameter uid: the unique identifier of the user.
    /// - Returns: A formatted string key: `current_eco_nickname_{uid}`.
    private func nicknameKey(for uid: String) -> String {
        "current_eco_nickname_\(uid)"
    }
}
