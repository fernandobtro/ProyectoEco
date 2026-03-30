//
//  SyncStateService.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 18/03/26.
//
//  Purpose: Observable sync lifecycle for global indicators.
//

import Foundation
import Observation

/// Observable sync lifecycle for global indicators.
@MainActor
@Observable
final class SyncStateService {
    var state: SyncState = .idle

    func setSyncing() {
        state = .syncing
    }

    func setSuccess() {
        state = .success
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            if case .success = state { state = .idle }
        }
    }

    func setError(_ message: String) {
        state = .error(message)
    }

    func clearError() {
        if case .error = state {
            state = .idle
        }
    }

    func setIdle() {
        state = .idle
    }
}
