//
//  SyncStoriesUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Entry point for syncing local stories with the backend.
//
//  Responsibilities:
//  - Run incremental sync or a full remote pull, then allow repositories and UI to refresh.
//

import Foundation

protocol SyncStoriesUseCase {
    // MARK: - Public API
    /// Incremental sync: push pending changes and pull remote updates without resetting the incremental sync cursor.
    func execute() async

    /// Full remote pull: syncs with a forced full download so incremental state resets. Use for cold starts or explicit refresh.
    func executeWithFullRemotePull() async
}

extension SyncStoriesUseCase {
    func executeWithFullRemotePull() async {
        await execute()
    }
}
