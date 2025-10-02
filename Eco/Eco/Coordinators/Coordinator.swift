//
//  Coordinator.swift
//  Eco
//
//  Created by Fernando Buenrostro on 01/10/25.
//

import Foundation
import SwiftUI
import UIKit

protocol Coordinator: AnyObject {
    
    var childCoordinators: [Coordinator] { get set }
    
    var rootViewController: UINavigationController { get }
    
    func start()
    
    func finish(coordinator: Coordinator)
}

extension Coordinator {
    
    func finish(coordinator: Coordinator) {
        
        childCoordinators.removeAll(where: {$0 === coordinator})
        print("🗑️ Coordinator Eliminated: \(type(of: coordinator))")
    }
}

