//
//  TabBar.swift
//  Eco
//
//  Created by Fernando Buenrostro on 15/03/26.
//

import Foundation

enum TabBar: String, CaseIterable {
    case map = "map.fill"
    case collection = "apple.meditate.square.stack.fill"
    
    var title: String {
        switch self {
        case .map:
            "Mapa"
        case .collection:
            "Colección"
        }
    }
}
