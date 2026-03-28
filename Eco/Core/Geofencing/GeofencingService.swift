//
//  GeofencingService.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Capa Infra/Presentation: geofencing local para notificaciones por proximidad.
//  Notificaciones agrupadas + anti-spam (dedupe, rate limit).
//

import CoreLocation
import Foundation
import Observation

@Observable
final class GeofencingService: NSObject {
    private let locationManager = CLLocationManager()
    private let localNotificationService: LocalNotificationServiceProtocol
    private var pendingStoryIDs: Set<String> = []
    /// Metadatos de las historias monitorizadas (para título en la notificación y tap → lector).
    private var monitoredStoriesById: [String: Story] = [:]
    private var flushTask: Task<Void, Never>?
    /// Agrupa entradas casi simultáneas sin añadir demora perceptible al “momento mágico”.
    private let debounceSeconds: TimeInterval = 2
    private let maxRegions = 20
    /// iOS suele ser poco fiable por debajo de ~100 m; equilibrio entre precisión y que el evento llegue.
    private let regionRadius: CLLocationDistance = 100

    init(localNotificationService: LocalNotificationServiceProtocol) {
        self.localNotificationService = localNotificationService
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }

    /// Configura regiones para las historias más cercanas (iOS limita ~20).
    /// Llamar después de sync cuando ya hay datos frescos.
    func startMonitoring(stories: [Story]) {
        locationManager.monitoredRegions.forEach {
            locationManager.stopMonitoring(for: $0)
        }

        let monitored = Array(stories.prefix(maxRegions))
        monitoredStoriesById = Dictionary(uniqueKeysWithValues: monitored.map { ($0.id.uuidString, $0) })

        for story in monitored {
            let center = CLLocationCoordinate2D(
                latitude: story.latitude,
                longitude: story.longitude
            )
            let region = CLCircularRegion(
                center: center,
                radius: regionRadius,
                identifier: story.id.uuidString
            )
            region.notifyOnEntry = true
            region.notifyOnExit = false
            locationManager.startMonitoring(for: region)
        }
    }

    private func onEnterRegion(_ storyId: String) {
        pendingStoryIDs.insert(storyId)
        scheduleFlush()
    }

    private func scheduleFlush() {
        guard flushTask == nil else { return }
        flushTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64((self?.debounceSeconds ?? 5) * 1_000_000_000))
            await self?.flush()
            self?.flushTask = nil
        }
    }

    private func flush() async {
        let ids = Array(pendingStoryIDs)
        pendingStoryIDs.removeAll()
        flushTask = nil

        let eligible = NotificationPolicy.filterEligible(storyIds: ids)
        guard !eligible.isEmpty else { return }
        guard NotificationPolicy.canSendNow() else { return }

        NotificationPolicy.recordNotification(storyIds: eligible)

        if eligible.count == 1, let onlyId = eligible.first, let story = monitoredStoriesById[onlyId] {
            await localNotificationService.scheduleProximityNotification(
                storyId: onlyId,
                storyTitle: story.title
            )
        } else {
            await localNotificationService.scheduleGroupedProximityNotification(count: eligible.count)
        }
    }
}

extension GeofencingService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        onEnterRegion(region.identifier)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Política de errores: por ahora silencioso
    }
}
