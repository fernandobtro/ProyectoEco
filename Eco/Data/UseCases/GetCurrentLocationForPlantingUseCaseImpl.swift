//
//  GetCurrentLocationForPlantingUseCaseImpl.swift
//  Eco
//
//  Created by Fernando Buenrostro on 03/03/26.
//

import Combine
import CoreLocation
import Foundation

final class GetCurrentLocationForPlantingUseCaseImpl: GetCurrentLocationForPlantingUseCaseProtocol {
    private let locationService: LocationServiceProtocol

    init(locationService: LocationServiceProtocol) {
        self.locationService = locationService
    }

    var locationPublisher: AnyPublisher<CLLocationCoordinate2D?, Never> {
        locationService.locationPublisher
    }

    func requestLocation() {
        locationService.requestSingleLocation()
    }
}
