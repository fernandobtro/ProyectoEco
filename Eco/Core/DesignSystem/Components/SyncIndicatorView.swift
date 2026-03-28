//
//  SyncIndicatorView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 18/03/26.
//

import SwiftUI

struct SyncIndicatorView: View {
    @Bindable var syncState: SyncStateService

    var body: some View {
        if syncState.state != .idle {
            HStack(spacing: 8) {
                icon
                Text(message)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(backgroundColor.opacity(0.95))
            .foregroundStyle(.white)
            .clipShape(Capsule())
        }
    }

    @ViewBuilder
    private var icon: some View {
        switch syncState.state {
        case .idle:
            EmptyView()
        case .syncing:
            ProgressView()
                .scaleEffect(0.8)
                .tint(.white)
        case .success:
            Image(systemName: "checkmark.circle.fill")
        case .error:
            Image(systemName: "exclamationmark.circle.fill")
        }
    }

    private var message: String {
        switch syncState.state {
        case .idle:
            ""
        case .syncing:
            "Sincronizando..."
        case .success:
            "Sincronizado"
        case .error(let text):
            text
        }
    }

    private var backgroundColor: Color {
        switch syncState.state {
        case .idle:
            .clear
        case .syncing:
            .orange
        case .success:
            Color.theme.accent
        case .error:
            .red
        }
    }
}

#Preview {
    let sync = SyncStateService()
    sync.setSyncing()
    return ZStack {
        Color.theme.primaryComponent.ignoresSafeArea()
        SyncIndicatorView(syncState: sync)
    }
}
