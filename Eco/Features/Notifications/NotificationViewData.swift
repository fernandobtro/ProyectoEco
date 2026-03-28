//
//  NotificationViewData.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Datos listos para la lista de notificaciones (copy + icono + contexto de tap).
//

import Foundation

/// Contexto mínimo para navegación o acciones al pulsar una fila (sin exponer `NotificationItem` en la vista).
enum NotificationTapContext: Equatable {
    case proximityGrouped
    case storyUnlocked(storyId: String?, storyTitle: String?)
}

struct NotificationViewData: Identifiable, Equatable {
    let id: UUID
    let title: String
    let dateText: String
    let iconSystemName: String
    let tapContext: NotificationTapContext
}
