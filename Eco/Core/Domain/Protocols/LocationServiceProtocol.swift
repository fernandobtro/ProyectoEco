//
//  LocationServiceProtocols.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 27/02/26.
//
//  Purpose: Domain/service protocol `LocationServiceProtocol`.
//

import Combine
import CoreLocation
import Foundation

// MARK: - Location Service Protocol

/// Domain/service protocol `LocationServiceProtocol`.
protocol LocationServiceProtocol {
    var delegate: LocationServiceDelegate? { get set }
    
    /// Hot stream of coordinates, new subscribers receive the last known value immediately.
    var locationPublisher: AnyPublisher<CLLocationCoordinate2D?, Never> { get }

    /// Last fix from Core Location (`nil` until the first `didUpdateLocations`).
    var lastKnownCoordinate: CLLocationCoordinate2D? { get }
    
    var storiesUpdatePublisher: AnyPublisher<Void, Never> { get }
    
    /// Whether continuous location / geofencing monitoring is active.
    var isMonitoringEnabled: Bool { get }
    
    /// Requests “When In Use” authorization.
    func requestWhenInUse() async throws
    
    /// Requests “Always” authorization for background geofencing.
    func requestAlways() async throws
    
    /// Starts monitoring the given stories as regions (geofencing).
    func startMonitoring(stories: [Story])
    
    /// Stops GPS updates and region monitoring (battery / data saving).
    func stopMonitoring()
    
    /// One-shot location request for planting flow.
    func requestSingleLocation()
}

// MARK: - Location Service Delegate

protocol LocationServiceDelegate: AnyObject {
    /// Called when the user enters a monitored story region.
    func didEnterStoryRegion(id: UUID)
    
    /// Delivers a fresh coordinate for planting or map refresh.
    func didUpdateLocation(latitude: Double, longitude: Double)
    
    func didFailWithError(_ error: Error)
}
