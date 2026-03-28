//
//  SyncStatus.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//

import Foundation

/// Estado de sincronización de una historia con el backend.
enum SyncStatus: String {
    case synced
    case pendingCreate
    case pendingUpdate
    case pendingDelete
}
