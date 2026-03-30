//
//  SyncPullStoriesUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Domain use case contract `SyncPullStoriesUseCase` for Features - Data wiring.
//

import Foundation

/// Domain use case contract `SyncPullStoriesUseCase` for Features - Data wiring.
protocol SyncPullStoriesUseCaseProtocol {
    func execute(since: Date?) async throws
    /// Clears incremental cursor and re-downloads all remote rows (fixes gaps after incremental sync).
    func executeFullPullFromRemote() async throws
}
