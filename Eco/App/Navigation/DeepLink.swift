//
//  DeepLink.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Represents a navigable destination triggered by external events (push notifications, deep links).
//

import Foundation

enum DeepLink {
    case storyDetail(id: String)
    case openMap
}
