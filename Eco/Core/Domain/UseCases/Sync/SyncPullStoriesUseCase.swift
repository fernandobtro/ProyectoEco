//
//  SyncPullStoriesUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//

import Foundation

protocol SyncPullStoriesUseCaseProtocol {
    func execute(since: Date?) async throws
    /// Borra la marca de último pull y vuelve a traer todo lo que devuelva el remoto (corrige huecos del sync incremental).
    func executeFullPullFromRemote() async throws
}
