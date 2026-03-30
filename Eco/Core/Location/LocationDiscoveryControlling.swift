//
//  LocationDiscoveryControlling.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 03/03/26.
//
//  Purpose: Starts GPS-driven discovery and requests permission without exposing the concrete location service.
//

import Foundation

/// Hides the location service while letting the map stack start discovery and ask for authorization.
protocol LocationDiscoveryControlling: AnyObject {
    func startDiscovery()
    func requestPermission() async
}
