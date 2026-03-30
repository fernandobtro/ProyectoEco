//
//  AppleSignInHelper.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Bridges `ASAuthorizationController` to async/await and supplies hashed nonces for Sign in with Apple.
//

import AuthenticationServices
import CryptoKit
import Foundation
import UIKit

/// Coordinator for Sign in with Apple: nonce generation, `ASAuthorizationController` presentation, and delegate bridge to one async call.
///
/// Used by ``SocialAuthViewModel``. Auth context: `docs/EcoCorePipelines.md` — **Email Login Pipeline** (social providers).
final class AppleSignInHelper: NSObject {
    
    // MARK: - Types
    
    /// Encapsulates the necessary data received from Apple to complete a Firebase login.
    struct AppleSignInResult {
        let identityToken: Data
        let nonce: String
        let fullName: PersonNameComponents?
    }
    
    // MARK: - Properties
    private var continuation: CheckedContinuation<AppleSignInResult, Error>?
    private var currentNonce: String?

    // MARK: - Public API
    
    /// Presents the Apple ID sheet and resumes when the delegate completes.
    ///
    /// - Returns: An ``AppleSignInResult`` containing the identity token and raw nonce.
    /// - Throws: ``AuthError`` if the user cancels or credentials are invalid.
    ///
    /// - Note: Suspends until the delegate resumes this call via `continuation`.
    func signIn() async throws -> AppleSignInResult {
        let nonce = randomNonceString()
        currentNonce = nonce
        let hashedNonce = sha256(nonce)

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = hashedNonce

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self

        // MARK: - Async-Await Bridge
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            controller.performRequests()
        }
    }

    // MARK: - Security Helpers
    
    /// Generates a secure random string for use as a nonce.
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Nonce generation failed: \(errorCode)")
        }
        return randomBytes.map { String(format: "%02x", $0) }.joined()
    }

    /// Hashes the input string using SHA256 algorithm
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleSignInHelper: ASAuthorizationControllerDelegate {
    
    /// Resumes ``signIn()`` with a validated identity token and nonce.
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = appleIDCredential.identityToken,
              let nonce = currentNonce else {
            // MARK: - Malformed Credentials
            continuation?.resume(throwing: AuthError.invalidCredentials)
            continuation = nil
            currentNonce = nil
            return
        }

        let result = AppleSignInResult(
            identityToken: identityToken,
            nonce: nonce,
            fullName: appleIDCredential.fullName
        )
        
        // MARK: - Sign-In Success
        continuation?.resume(returning: result)
        continuation = nil
        currentNonce = nil
    }

    /// Handles authentication errors, including user cancellations.
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        let authError = (error as NSError).code == ASAuthorizationError.canceled.rawValue
            ? AuthError.invalidCredentials
            : AuthError.map(error)
        continuation?.resume(throwing: authError)
        cleanup()
    }
}

// MARK: - Presentation Context

extension AppleSignInHelper: ASAuthorizationControllerPresentationContextProviding {
    
    /// Provides the UI window anchor where the Apple ID dialog should be presented.
    /// - Returns: The currently active "Key Window" to ensure the modal appears on top.
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        if let keyWindow = windowScenes.flatMap(\.windows).first(where: { $0.isKeyWindow }) {
            return keyWindow
        }
        if let visible = windowScenes.flatMap(\.windows).first(where: { !$0.isHidden }) {
            return visible
        }
        guard let scene = windowScenes.first else {
            preconditionFailure("No UIWindowScene available for Sign in with Apple presentation anchor")
        }
        return UIWindow(windowScene: scene)
    }
}

// MARK: - Private Cleanup

extension AppleSignInHelper {
    /// Resets state to prevent memory leaks and double-resumption crashes.
    private func cleanup() {
        continuation = nil
        currentNonce = nil
    }
}
