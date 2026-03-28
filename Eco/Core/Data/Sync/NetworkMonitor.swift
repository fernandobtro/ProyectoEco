//
//  NetworkMonitor.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 18/03/26.
//

import Foundation
import Network

/// Monitorea la conectividad de red para disparar sync cuando vuelve a estar disponible.
protocol NetworkMonitorProtocol {
    var isConnected: Bool { get }
    func startMonitoring(onStatusChange: @escaping (Bool) -> Void)
    func stopMonitoring()
}

final class NetworkMonitor: NetworkMonitorProtocol {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "eco.networkmonitor")
    private var statusHandler: ((Bool) -> Void)?

    var isConnected: Bool {
        monitor.currentPath.status == .satisfied
    }

    func startMonitoring(onStatusChange: @escaping (Bool) -> Void) {
        statusHandler = onStatusChange
        monitor.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            DispatchQueue.main.async {
                self?.statusHandler?(connected)
            }
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
        statusHandler = nil
    }
}
