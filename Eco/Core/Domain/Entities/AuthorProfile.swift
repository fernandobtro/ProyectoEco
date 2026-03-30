//
//  AuthorProfile.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Domain entity `AuthorProfile` (pure model, no framework UI).
//

import Foundation

/// Domain entity `AuthorProfile` (pure model, no framework UI).
struct AuthorProfile: Equatable {
    let id: String
    let email: String
    let nickname: String
    let createdAt: Date
    
}
