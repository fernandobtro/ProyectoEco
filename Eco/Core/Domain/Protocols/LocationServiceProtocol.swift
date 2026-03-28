//
//  LocationServiceProtocols.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 27/02/26.
//

import Combine
import CoreLocation
import Foundation

// MARK: - Location Service Protocol

protocol LocationServiceProtocol {
    var delegate: LocationServiceDelegate? { get set }
    
    /// Flujo reactivo que emite la ubicación actual para múltiples interesados (replay del último valor para nuevos suscriptores)
    var locationPublisher: AnyPublisher<CLLocationCoordinate2D?, Never> { get }

    /// Última coordenada del GPS (`nil` hasta el primer `didUpdateLocations`).
    var lastKnownCoordinate: CLLocationCoordinate2D? { get }
    
    var storiesUpdatePublisher: AnyPublisher<Void, Never> { get }
    
    /// El "Interruptor" para apagar el radar a voluntad
    var isMonitoringEnabled: Bool { get }
    
    /// Solicita permisos de "Cuando se use la app"
    func requestWhenInUse() async throws
    
    /// Solicita permisos de "Siempre" para que funcione en segundo plano
    func requestAlways() async throws
    
    /// Inicia la vigilancia de las historias cercanas (Geofencing)
    func startMonitoring(stories: [Story])
    
    /// Apaga todo el consumo de GPS y deja de vigilar (Ahorro de batería/datos)
    func stopMonitoring()
    
    /// Petición única de ubicación para el autor que quiere plantar un Eco
    func requestSingleLocation()
}

// MARK: - Location Service Delegate

protocol LocationServiceDelegate: AnyObject {
    /// Se detona cuando el usuario entra en el radio de 50m de un Eco
    func didEnterStoryRegion(id: UUID)
    
    /// Proporciona la ubicación exacta para plantar historias o actualizar el mapa
    func didUpdateLocation(latitude: Double, longitude: Double)
    
    func didFailWithError(_ error: Error)
}
