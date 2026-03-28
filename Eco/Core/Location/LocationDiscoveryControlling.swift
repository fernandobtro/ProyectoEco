//
//  LocationDiscoveryControlling.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 03/03/26.
//

import Foundation

/// Permite iniciar el descubrimiento por ubicación y pedir permisos sin exponer el servicio de localización.
protocol LocationDiscoveryControlling: AnyObject {
    func startDiscovery()
    func requestPermission() async
}
