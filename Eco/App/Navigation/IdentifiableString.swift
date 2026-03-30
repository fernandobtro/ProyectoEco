//
//  IdentifiableString.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Wraps a `String` with a stable `UUID` so SwiftUI can drive `.sheet(item:)`.
//

import Foundation

/// One-off identifiable payload for sheet presentation by value.
struct IdentifiableString: Identifiable {
    let id = UUID()
    let value: String
}
