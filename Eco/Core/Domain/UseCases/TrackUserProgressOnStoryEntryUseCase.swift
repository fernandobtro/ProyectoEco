//
//  TrackUserProgressOnStoryEntryUseCase.swift
//  Eco
//
//  Created by Fernando Buenrostro on 03/03/26.
//

import Foundation

protocol TrackUserProgressOnStoryEntryUseCaseProtocol {
    func execute(storyId: UUID) async
}
