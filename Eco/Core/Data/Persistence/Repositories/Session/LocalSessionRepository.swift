//
//  LocalSessionRepository.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

class LocalSessionRepository: SessionRepositoryProtocol {
    private let defaults = UserDefaults.standard
    private let userIdKey = "current_eco_user_id"
    
    func getCurrentUserId() -> UUID {
        if let savedIdString = defaults.string(forKey: userIdKey),
           let savedId = UUID(uuidString: savedIdString) {
            return savedId // ¡Ya existía! Lo devolvemos.
        } else {
            let newId = UUID()
            defaults.set(newId.uuidString, forKey: userIdKey)
            return newId
        }
    }
}
