//
//  IdentifiableString.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Binding helper.
//

import Foundation

struct IdentifiableString: Identifiable {
    let id = UUID()
    let value: String
}
