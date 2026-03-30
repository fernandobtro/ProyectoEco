//
//  SyncStatus.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Local sync state persisted on story entities (pending vs synced).
//

import Foundation

/// Local sync state for a story row vs the backend.
enum SyncStatus: String, Codable {
    case synced
    case pendingCreate
    case pendingUpdate
    case pendingDelete
}
