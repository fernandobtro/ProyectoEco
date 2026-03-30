//
//  EcoError.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 28/02/26.
//
//  Purpose: Shared error surface (`EcoError`) for domain and data layers.
//

import Foundation

/// Shared error surface (`EcoError`) for domain and data layers.
enum EcoError: Error, LocalizedError {
    
    // Location
    case locationPermissionDenied
    case locationServicesDisabled
    
    // Persistence
    case storageFailed
    case storyNotFound
    
    // Identity / security
    case unauthorizedAction
    
    // Networking
    case networkUnavailable
    case syncFailed
    
    var errorDescription: String? {
        switch self {
            
        case .locationPermissionDenied:
            return "Eco necesita tu ubicación 'Siempre' para avisarte de historias cercanas."
        case .locationServicesDisabled:
            return "Parece que el GPS está apagado. Préndelo para explorar."
        case .storageFailed:
            return "No pudimos guardar tu historia. Revisa el espacio en tu iPhone."
        case .storyNotFound:
            return "Esta historia ya no existe. Parece que su autor la ha borrado."
        case .unauthorizedAction:
            return "No tienes permiso para realizar esta acción."
        case .networkUnavailable:
            return "Sin conexión a internet. Tu Eco se sincronizará después."
        case .syncFailed:
            return "Hubo un problema al conectar con la nube."
        }
    }
}
