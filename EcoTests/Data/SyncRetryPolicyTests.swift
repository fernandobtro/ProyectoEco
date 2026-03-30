//
//  SyncRetryPolicyTests.swift
//  EcoTests
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 27/03/26.
//
//  Purpose: Unit tests for sync retry classification (`isRetryableSyncError`) and backoff helper.
//
//  Responsibilities:
//  - Lock in behaviour for transient vs permanent errors without touching the network.
//

import Foundation
import XCTest
@testable import Eco

final class SyncRetryPolicyTests: XCTestCase {

    func testIsRetryable_URLErrorTimedOut_isRetryable() {
        let error = URLError(.timedOut)
        XCTAssertTrue(isRetryableSyncError(error))
    }

    func testIsRetryable_FirestorePermissionDenied_isNotRetryable() {
        let error = NSError(
            domain: "FIRFirestoreErrorDomain",
            code: 7,
            userInfo: [NSLocalizedDescriptionKey: "permission denied"]
        )
        XCTAssertFalse(isRetryableSyncError(error))
    }

    func testIsRetryable_FirestoreUnavailable_isRetryable() {
        let error = NSError(
            domain: "FIRFirestoreErrorDomain",
            code: 14,
            userInfo: [NSLocalizedDescriptionKey: "unavailable"]
        )
        XCTAssertTrue(isRetryableSyncError(error))
    }

    func testIsRetryable_wrappedUnderlyingURLError_isRetryable() {
        let underlying = URLError(.notConnectedToInternet)
        let wrapped = NSError(
            domain: "SomeWrapper",
            code: 1,
            userInfo: [NSUnderlyingErrorKey: underlying]
        )
        XCTAssertTrue(isRetryableSyncError(wrapped))
    }

    func testRetryWithBackoff_succeedsOnFirstAttempt() async throws {
        let policy = SyncRetryPolicy(maxRetries: 2, baseDelay: 0, maxDelay: 0)
        let value = try await retryWithBackoff(policy: policy, operation: "test") {
            42
        }
        XCTAssertEqual(value, 42)
    }

    func testRetryWithBackoff_nonRetryableErrorThrowsImmediately() async throws {
        let policy = SyncRetryPolicy(maxRetries: 5, baseDelay: 0, maxDelay: 0)
        let permanent = NSError(
            domain: "FIRFirestoreErrorDomain",
            code: 7,
            userInfo: [:]
        )
        do {
            _ = try await retryWithBackoff(policy: policy, operation: "perm") {
                throw permanent
            }
            XCTFail("Expected error")
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "FIRFirestoreErrorDomain")
            XCTAssertEqual(nsError.code, 7)
        }
    }
}
