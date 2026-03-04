//
//  LocationService.swift
//  Eco
//
//  Created by Fernando Buenrostro on 03/03/26.
//

import Combine
import CoreLocation
import Foundation

class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    
    weak var delegate: LocationServiceDelegate?
    
    private let locationSubject = CurrentValueSubject<CLLocationCoordinate2D?, Never>(nil)
    var locationPublisher: AnyPublisher<CLLocationCoordinate2D?, Never> {
        locationSubject.eraseToAnyPublisher()
    }
    
    var isMonitoringEnabled: Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        // In the future the accuracy should be configurable depending on the app mode (exploration vs planting a story)
    }
    
    func requestPermission() async throws {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startMonitoring(stories: [Story]) {
        locationManager.startUpdatingLocation()
    }
    
    func stopMonitoring() {
        locationManager.stopUpdatingLocation()
    }
    
    func requestSingleLocation() {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        delegate?.didUpdateLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        locationSubject.send(location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        delegate?.didFailWithError(error)
    }
}
