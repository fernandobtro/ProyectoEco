//
//  SyncState.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 18/03/26.
//

import Foundation

/// Estado global de sincronización para feedback visual.
enum SyncState: Equatable {
    case idle
    case syncing
    case success
    case error(String)
}
