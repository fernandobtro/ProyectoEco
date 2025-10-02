//
//  ApplicationCoordinator.swift
//  Eco
//
//  Created by Fernando Buenrostro on 01/10/25.
//

import Foundation
import UIKit
import SwiftUI

class ApplicationCoordinator: Coordinator {
    var rootViewController: UINavigationController
    
    var childCoordinators = [Coordinator]()
    
    private var window: UIWindow?
    
    init(window: UIWindow){
        self.window = window
        self.rootViewController = UINavigationController()
    }
    
    func start() {
        print("🚀 Application started")
    }
}


