//
//  Story.swift
//  Eco
//
//  Created by Fernando Buenrostro on 27/02/26.
//

import Foundation

struct Story: Identifiable, Equatable {
    let id: UUID
    let title: String
    let content: String
    let authorID: UUID
    let latitude: Double
    let longitude: Double
}
