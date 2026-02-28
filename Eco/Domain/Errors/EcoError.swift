//
//  EcoError.swift
//  Eco
//
//  Created by Fernando Buenrostro on 28/02/26.
//

import Foundation

enum EcoError: Error, LocalizedError {
    
    // Ubicación
    case locationPermissionDenied
    case locationServicesDisabled
    
    // Persistencia
    case storageFailed
    case storyNotFound
    
    // Identidad/Seguridad
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
