//
//  SyncConflictResolver.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 18/03/26.
//

import Foundation

/// Acción resultante de resolver un conflicto entre local y remoto.
enum StorySyncAction {
    case insert(StoryEntity)
    case updateLocal(StoryEntity)
    case keepLocal
    case deleteLocal
}

/// Resuelve conflictos last-write-wins entre historias locales y remotas.
enum SyncConflictResolver {

    /// Resuelve el conflicto entre una entidad local (opcional) y un DTO remoto.
    /// - Regla: pendingDelete SIEMPRE gana (intención final del usuario).
    /// - Regla: mayor updatedAt gana.
    static func resolve(
        local: StoryEntity?,
        remote: RemoteStoryDTO
    ) -> StorySyncAction {
        // Remoto eliminado
        if remote.deletedAt != nil {
            guard let local else { return .keepLocal }
            // pendingCreate: nunca llegó al server, local es fuente de verdad
            if SyncStatus(rawValue: local.syncStatus) == .pendingCreate {
                return .keepLocal
            }
            return .deleteLocal
        }

        guard let local else {
            return .insert(StoryRemoteMapper.toEntity(remote, existing: nil))
        }

        // 🔴 Caso crítico: delete gana siempre
        if SyncStatus(rawValue: local.syncStatus) == .pendingDelete {
            return .keepLocal
        }

        // 🟢 Remote gana
        if remote.updatedAt > local.updatedAt {
            let entity = StoryRemoteMapper.toEntity(remote, existing: local)
            return .updateLocal(entity)
        }

        // 🔵 Local gana
        return .keepLocal
    }
}
