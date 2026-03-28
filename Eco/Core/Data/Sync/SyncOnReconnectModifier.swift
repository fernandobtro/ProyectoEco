//
//  SyncOnReconnectModifier.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 18/03/26.
//

import SwiftUI

/// Debounce en ms para evitar múltiples triggers (wifi↔cellular, online→online).
private let reconnectDebounceMs: UInt64 = 500

/// Modificador que dispara sync cuando la red vuelve a estar disponible.
struct SyncOnReconnectModifier: ViewModifier {
    let onSync: () async -> Void

    @State private var networkMonitor: NetworkMonitor?
    @State private var wasOffline = true
    @State private var reconnectTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .task {
                let monitor = NetworkMonitor()
                networkMonitor = monitor
                monitor.startMonitoring { isConnected in
                    if isConnected, wasOffline {
                        wasOffline = false
                        reconnectTask?.cancel()
                        reconnectTask = Task {
                            do {
                                try await Task.sleep(nanoseconds: reconnectDebounceMs * 1_000_000)
                            } catch {
                                return // Cancelled
                            }
                            await onSync()
                        }
                    } else if !isConnected {
                        wasOffline = true
                        reconnectTask?.cancel()
                    }
                }
            }
            .onDisappear {
                reconnectTask?.cancel()
                networkMonitor?.stopMonitoring()
            }
    }
}

extension View {
    /// Dispara `onSync` cuando la red pasa de offline a online.
    func syncOnReconnect(onSync: @escaping () async -> Void) -> some View {
        modifier(SyncOnReconnectModifier(onSync: onSync))
    }
}

#Preview {
    Text("Sync On Reconnect")
        .padding()
        .syncOnReconnect {
            // Preview mock
        }
}
