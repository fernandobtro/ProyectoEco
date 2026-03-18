//
//  SyncStoriesUseCaseImpl.swift
//  Eco
//
//  Created by Cursor on 17/03/26.
//

import Foundation

final class SyncStoriesUseCaseImpl: SyncStoriesUseCase {
    private let worker: SyncWorkerProtocol

    init(worker: SyncWorkerProtocol) {
        self.worker = worker
    }

    func execute() async {
        await worker.sync()
    }
}

