//
//  SyncRetryPolicy.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 18/03/26.
//

import Foundation

/// Política de reintentos para operaciones de sync.
struct SyncRetryPolicy {
    let maxRetries: Int
    let baseDelay: TimeInterval
    let maxDelay: TimeInterval

    static let `default` = SyncRetryPolicy(
        maxRetries: 3,
        baseDelay: 1.0,
        maxDelay: 30.0
    )
}

/// Errores que NO deben reintentarse (permanentes).
private func isPermanentSyncError(_ error: Error) -> Bool {
    let nsError = error as NSError
    // Firebase Firestore: permission denied, unauthenticated, invalid argument
    if nsError.domain == "FIRFirestoreErrorDomain" {
        switch nsError.code {
        case 7, 16, 3:  // PERMISSION_DENIED, UNAUTHENTICATED, INVALID_ARGUMENT
            return true
        default:
            break
        }
    }
    // Errores envueltos
    if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? Error {
        return isPermanentSyncError(underlying)
    }
    return false
}

/// Determina si un error es reintentable (red, timeout) vs permanente (validación, auth).
func isRetryableSyncError(_ error: Error) -> Bool {
    guard !isPermanentSyncError(error) else { return false }

    if let urlError = error as? URLError {
        switch urlError.code {
        case .timedOut, .cannotConnectToHost, .networkConnectionLost,
             .notConnectedToInternet, .internationalRoamingOff,
             .dataNotAllowed:
            return true
        default:
            return false
        }
    }
    let nsError = error as NSError
    // Firebase Firestore UNAVAILABLE (14) = servicio temporalmente no disponible
    if nsError.domain == "FIRFirestoreErrorDomain" && nsError.code == 14 {
        return true
    }
    if nsError.domain == NSURLErrorDomain {
        return true
    }
    // Errores envueltos (Firebase puede envolver URLError)
    if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? Error {
        return isRetryableSyncError(underlying)
    }
    return false
}

/// Ejecuta una operación con reintentos y exponential backoff.
func retryWithBackoff<T>(
    policy: SyncRetryPolicy = .default,
    operation: String,
    body: () async throws -> T
) async throws -> T {
    var lastError: Error?
    for attempt in 0...policy.maxRetries {
        do {
            return try await body()
        } catch {
            lastError = error
            guard attempt < policy.maxRetries, isRetryableSyncError(error) else {
                throw error
            }
            let delay = min(
                policy.baseDelay * pow(2.0, Double(attempt)),
                policy.maxDelay
            )
            print("🔄 [SYNC RETRY] \(operation) attempt \(attempt + 1)/\(policy.maxRetries + 1) failed, retry in \(String(format: "%.1f", delay))s: \(error.localizedDescription)")
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
    }
    throw lastError ?? NSError(domain: "SyncRetry", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
}
