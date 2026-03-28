//
//  AuthorDisplayFormatting.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Evita mostrar el UID de Firebase (u otros identificadores técnicos) donde el usuario espera un apodo.
//

import Foundation

enum EcoAuthorDisplayFormatting {

    /// Apodo listo para UI, o `nil` si el valor guardado es vacío, coincide con el UID del autor, o no debe mostrarse.
    static func displayNickname(_ raw: String?, authorFirebaseUid: String) -> String? {
        let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmed.isEmpty else { return nil }
        if trimmed == authorFirebaseUid { return nil }
        if trimmed.caseInsensitiveCompare(authorFirebaseUid) == .orderedSame { return nil }
        return trimmed
    }
}
