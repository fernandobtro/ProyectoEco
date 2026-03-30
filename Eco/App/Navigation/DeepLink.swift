//
//  DeepLink.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Serializable navigation targets from notifications, URLs, and `AppRouter` (`storyDetail`, `openMap`).
//

import Foundation

/// Parsed handoff consumed by ``AppRouter`` and `RootView` sheets.
enum DeepLink {
    case storyDetail(id: String)
    case openMap
}
