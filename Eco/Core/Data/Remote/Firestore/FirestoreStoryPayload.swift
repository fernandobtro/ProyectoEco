//
//  FirestoreStoryPayload.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 26/03/26.
//

import Foundation

struct FirestoreStoryPayload: Sendable {
    let title: String
    let content: String
    let authorID: String
    let latitude: Double
    let longitude: Double
    let updatedAt: Date
    let remoteId: String?
}
