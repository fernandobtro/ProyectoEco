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
    
    enum State: Equatable {
        case checking
        case unauthenticated
        case needsNickname
        case authenticated(String) // UID
        
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
                // Verificamos si ya existe el pseudónimo en el repositorio local
                // Nota: Aquí podrías necesitar añadir un método al UseCase o usar el repositorio directamente
                if let _ = self.getCurrentSessionUseCase.getNickname() {
                    self.state = .authenticated(uid)
                } else {
                    // Si está logueado pero no tiene nombre, lo mandamos a la Página 5
                    self.state = .needsNickname
                }
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
