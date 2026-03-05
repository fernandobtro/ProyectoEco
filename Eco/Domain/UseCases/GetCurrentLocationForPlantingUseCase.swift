//
//  GetCurrentLocationForPlantingUseCase.swift
//  Eco
//
//  Created by Fernando Buenrostro on 03/03/26.
//

import Combine
import CoreLocation
import Foundation

protocol GetCurrentLocationForPlantingUseCaseProtocol {
    var locationPublisher: AnyPublisher<CLLocationCoordinate2D?, Never> { get }
    func requestLocation()
}
