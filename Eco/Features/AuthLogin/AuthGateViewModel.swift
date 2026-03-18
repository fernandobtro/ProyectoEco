//
//  AuthGateViewModel.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import FirebaseAuth
import Foundation
import Observation

@Observable
final class AuthGateViewModel {
    
    enum State {
        case checking
        case authenticated(String) // UID
        case unauthenticated
    }
    
    private let getCurrentSessionUseCase: GetCurrentSessionUseCaseProtocol
    private var listenerHandle: AuthStateDidChangeListenerHandle?
    
    var state: State = .checking
    
    init(getCurrentSessionUseCase: GetCurrentSessionUseCaseProtocol) {
        self.getCurrentSessionUseCase = getCurrentSessionUseCase
        observeAuthState()
    }
    
    private func observeAuthState() {
        listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            
            if let uid = user?.uid {
                self.state = .authenticated(uid)
            } else {
                self.state = .unauthenticated
            }
        }
    }
    
    deinit {
        if let handle = listenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    func checkSession() {
        if let uid = getCurrentSessionUseCase.execute() {
            state = .authenticated(uid)
        } else {
            state = .unauthenticated
        }
    }
}
