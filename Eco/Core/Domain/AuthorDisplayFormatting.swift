//
//  AuthorDisplayFormatting.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Hides raw Firebase UIDs where the UI should show a human nickname.
//

import Foundation

/// Nickname sanitization for profile and reader surfaces.
enum EcoAuthorDisplayFormatting {

    /// Display-safe nickname, or `nil` when empty, equal to the author UID, or otherwise not showable.
    static func displayNickname(_ raw: String?, authorFirebaseUid: String) -> String? {
        let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmed.isEmpty else { return nil }
        if trimmed == authorFirebaseUid { return nil }
        if trimmed.caseInsensitiveCompare(authorFirebaseUid) == .orderedSame { return nil }
        return trimmed
    }
}
