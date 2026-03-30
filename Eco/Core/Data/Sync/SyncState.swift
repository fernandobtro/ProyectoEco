//
//  SyncState.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 18/03/26.
//
//  Purpose: Serializable sync phase for UI and services.
//

import Foundation

/// High-level sync phase for indicators and debounced UI.
enum SyncState: Equatable {
    case idle
    case syncing
    case success
    case error(String)
}
