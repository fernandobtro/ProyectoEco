//
//  XCTestCase+AsyncThrows.swift
//  EcoTests
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 26/03/26.
//
//  Purpose: Small XCTest helpers for async/await and throwing expectations.
//
//  Responsibilities:
//  - Provide awaitable wrappers that map failures to XCTFail with file/line.
//

import XCTest

extension XCTestCase {

    /// Runs an async closure and fails the test if it throws; returns the value on success.
    @discardableResult
    func awaitAssertNoThrow<T>(
        file: StaticString = #filePath,
        line: UInt = #line,
        _ body: () async throws -> T
    ) async -> T? {
        do {
            return try await body()
        } catch {
            XCTFail("Expected no throw, got: \(error)", file: file, line: line)
            return nil
        }
    }

    /// Runs an async closure and fails the test if it does not throw.
    func awaitAssertThrows(
        file: StaticString = #filePath,
        line: UInt = #line,
        _ body: () async throws -> Void
    ) async {
        do {
            try await body()
            XCTFail("Expected thrown error", file: file, line: line)
        } catch {
            // Expected path
        }
    }
}
