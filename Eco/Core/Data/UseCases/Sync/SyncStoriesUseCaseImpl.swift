//
//  SyncStoriesUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: UI-facing sync entry: run worker, then notify story subscribers.
//

import Foundation

/// Runs ``SyncWorker`` and calls `notifyStoriesUpdated()` on the story repository so map and lists can refresh.
///
/// Narrative: `docs/EcoCorePipelines.md` — **Cross-Cutting: Sync, Geofencing, Notifications**.
final class SyncStoriesUseCaseImpl: SyncStoriesUseCase {

    // MARK: - Dependencies
    private let worker: SyncWorkerProtocol
    private let storyRepository: StoryRepositoryProtocol

    // MARK: - Init
    init(worker: SyncWorkerProtocol, storyRepository: StoryRepositoryProtocol) {
        self.worker = worker
        self.storyRepository = storyRepository
    }

    // MARK: - Public API
    /// Runs incremental sync, then notifies story subscribers so map and lists can reload.
    func execute() async {
        await worker.sync(forceFullPull: false)
        storyRepository.notifyStoriesUpdated()
    }

    /// Runs a full remote pull, then notifies subscribers. Resets incremental sync bookkeeping inside the worker pipeline.
    func executeWithFullRemotePull() async {
        await worker.sync(forceFullPull: true)
        storyRepository.notifyStoriesUpdated()
    }
}
