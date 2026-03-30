//
//  TrackUserProgressOnStoryEntryUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 03/03/26.
//
//  Purpose: Domain use case contract `TrackUserProgressOnStoryEntryUseCase` for Features - Data wiring.
//

import Foundation

/// Domain use case contract `TrackUserProgressOnStoryEntryUseCase` for Features - Data wiring.
protocol TrackUserProgressOnStoryEntryUseCaseProtocol {
    func execute(storyId: UUID) async
}
