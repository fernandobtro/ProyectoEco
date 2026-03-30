//
//  SyncOnReconnectModifier.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 18/03/26.
//
//  Purpose: SwiftUI modifier to trigger sync when network returns.
//

import SwiftUI

/// Debounce window to avoid duplicate triggers (Wi‑Fi - cellular, flapping online).
private let reconnectDebounceMs: UInt64 = 500

/// Runs `onSync` when connectivity returns after an offline period.
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
    /// Invokes `onSync` when connectivity returns after being offline.
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
