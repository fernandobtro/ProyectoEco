//
//  AuthGateViewModel.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Manages the global authentication state and coordinates identity synchronization.
//  Responsabilities:
//  - Listen to Firebase Auth state changes and evaluate session validity.
//  - Reconcile local vs remote nicknames to ensure a consistent user identity.
//  - Provide actions for onboarding completion and secure logouts.

import FirebaseAuth
import Foundation
import Observation

@Observable
final class AuthGateViewModel {
    
    // MARK: - Auth State Definition
    
    enum State: Equatable {
        case checking
        case unauthenticated
        case needsNickname
        case authenticated(String) // UID
    }
    
    // MARK: - Dependencies
    
    private let getCurrentSessionUseCase: GetCurrentSessionUseCaseProtocol
    private let getAuthorProfileUseCase: GetAuthorProfileUseCase
    private let saveSessionNicknameUseCase: SaveSessionNicknameUseCaseProtocol
    private let logoutUseCase: LogoutUseCaseProtocol
    
    /// Handle for the Firebase Auth listener to manage the lifecycle of the observer.
    private var listenerHandle: AuthStateDidChangeListenerHandle?
    
    // MARK: - Observable Properties
    var state: State = .checking
    
    // MARK: - Init
    
    init(
        getCurrentSessionUseCase: GetCurrentSessionUseCaseProtocol,
        getAuthorProfileUseCase: GetAuthorProfileUseCase,
        saveSessionNicknameUseCase: SaveSessionNicknameUseCaseProtocol,
        logoutUseCase: LogoutUseCaseProtocol
    ) {
        self.getCurrentSessionUseCase = getCurrentSessionUseCase
        self.getAuthorProfileUseCase = getAuthorProfileUseCase
        self.saveSessionNicknameUseCase = saveSessionNicknameUseCase
        self.logoutUseCase = logoutUseCase
        observeAuthState()
    }
    
    // MARK: - Lifecycle Management

    /// Registers a listener that triggers state evaluation when the Firebase session changes.
    private func observeAuthState() {
        listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            Task { await self.evaluateState(for: user) }
        }
    }
    
    /// Analyzes the current user and determines if the flow should proceed to the App, Onboarding, or Login.
    /// - Note: This method prioritizes remote profile data over local session data to mantain Firebase as the Source of Truth.
    private func evaluateState(for user: FirebaseAuth.User?) async {
        if let uid = user?.uid {
            let localNickname = getCurrentSessionUseCase.getNickname()
            let remoteNickname = try? await getAuthorProfileUseCase.execute()?.nickname

            // MARK: Identity Reconciliation Logic
            // Try to restore from Cloud (Remote)
            if let safeRemote = EcoAuthorDisplayFormatting.displayNickname(remoteNickname, authorFirebaseUid: uid) {
                await saveSessionNicknameUseCase.execute(nickname: safeRemote)
                await MainActor.run { state = .authenticated(uid) }
                return
            }
            
            // Fallback to Local Session
            if let safeLocal = EcoAuthorDisplayFormatting.displayNickname(localNickname, authorFirebaseUid: uid) {
                await saveSessionNicknameUseCase.execute(nickname: safeLocal)
                await MainActor.run { state = .authenticated(uid) }
                return
            }
            // Force Onboarding if no identity is found
            await MainActor.run { state = .needsNickname }
        } else {
            await MainActor.run { state = .unauthenticated }
        }
    }
    
    deinit {
        if let handle = listenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Public API
    
    /// Manual trigger to re-evaluate the current Firebase session.
    func checkSession() {
        let currentUser = Auth.auth().currentUser
        Task { await evaluateState(for: currentUser) }
    }

    /// Completes the nickname onboarding and refreshes the session state.
    func completeNicknameOnboarding(with nickname: String) {
        Task {
            await saveSessionNicknameUseCase.execute(nickname: nickname)
            await MainActor.run {
                self.checkSession()
            }
        }
    }

    /// Forces a logout when the app detects prolonged inactivity.
    func logoutByInactivity() {
        do {
            try logoutUseCase.execute()
            Task { @MainActor in state = .unauthenticated }
        } catch {
            Task { @MainActor in state = .unauthenticated }
        }
    }
}
