//
//  TabBar.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 15/03/26.
//
//  Purpose: Root tab identifiers, SF Symbol image names, and short tab titles.
//

import Foundation

/// Map vs collection tabs for ``RootView`` / ``CustomTabBar``.
enum TabBar: String, CaseIterable {
    case map = "map.fill"
    case collection = "books.vertical.fill"

    var title: String {
        switch self {
        case .map:
            "Mapa"
        case .collection:
            "Tu Eco"
        }
    }
}
