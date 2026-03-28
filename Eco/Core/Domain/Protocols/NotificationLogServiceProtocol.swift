//
//  NotificationLogServiceProtocol.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Contrato de dominio para guardar/leer el historial de notificaciones in-app.
//

import Foundation

protocol NotificationLogServiceProtocol {
    func log(_ item: NotificationItem)
    func fetchAll() -> [NotificationItem]
}
