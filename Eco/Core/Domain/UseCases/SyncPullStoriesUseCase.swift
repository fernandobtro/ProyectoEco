//
//  SyncPullStoriesUseCase.swift
//  Eco
//
//  Created by Fernando Buenrostro on 17/03/26.
//

import Foundation

protocol SyncPullStoriesUseCaseProtocol {
    func execute(since: Date?) async
}
