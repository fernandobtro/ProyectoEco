//
//  TabBar.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 15/03/26.
//

import Foundation

enum TabBar: String, CaseIterable {
    case map = "map.fill"
    /// Sin adornos tipo «sparkle» de otros símbolos del sistema.
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
