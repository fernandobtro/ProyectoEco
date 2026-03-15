//
//  GetCurrentLocationForPlantingUseCaseImpl.swift
//  Eco
//

import Combine
import CoreLocation
import Foundation

final class GetCurrentLocationForPlantingUseCaseImpl: GetCurrentLocationForPlantingUseCaseProtocol {
    private let locationService: LocationServiceProtocol

    init(locationService: LocationServiceProtocol) {
        self.locationService = locationService
    }

    func requestLocation() async -> CLLocationCoordinate2D? {
        await withCheckedContinuation { continuation in
            let lock = NSLock()
            var resumed = false
            func resumeOnce(with value: CLLocationCoordinate2D?) {
                lock.lock()
                defer { lock.unlock() }
                guard !resumed else { return }
                resumed = true
                continuation.resume(returning: value)
            }

            let sub = locationService.locationPublisher
                .compactMap { $0 }
                .first()
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { _ in resumeOnce(with: nil) },
                    receiveValue: { coord in resumeOnce(with: coord) }
                )
            locationService.requestSingleLocation()

            Task {
                try? await Task.sleep(nanoseconds: 15_000_000_000)
                resumeOnce(with: nil)
                sub.cancel()
            }
        }
    }
}
