//
//  NotificationsView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Registro local de avisos; estética panel (mismo fondo que Perfil), lista con divisores crema.
//

import SwiftUI

struct NotificationsView: View {
    @Bindable var viewModel: NotificationsViewModel
    let onItemTap: (NotificationViewData) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.theme.accent
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                headerView
                    .padding(.horizontal, 24)
                    .padding(.top, 56)
                    .padding(.bottom, 8)

                if viewModel.rows.isEmpty {
                    emptyState
                } else {
                    notificationList
                }
            }

            closeButton
                .padding(.top, 16)
                .padding(.trailing, 16)
        }
        .onAppear { viewModel.load() }
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.theme.primaryText)
                .frame(width: 36, height: 36)
                .background(Circle().stroke(Color.theme.primaryText.opacity(0.5), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Cerrar")
    }

    private var headerView: some View {
        Text("Notificaciones")
            .font(.poppins(.bold, size: 26))
            .foregroundStyle(Color.theme.primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var notificationList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(viewModel.rows.enumerated()), id: \.element.id) { index, row in
                    VStack(spacing: 0) {
                        Button {
                            onItemTap(row)
                        } label: {
                            notificationRow(for: row)
                        }
                        .buttonStyle(.plain)

                        if index < viewModel.rows.count - 1 {
                            Rectangle()
                                .fill(Color.theme.primaryText.opacity(0.22))
                                .frame(height: 1)
                        }
                    }
                }
            }
            .padding(.bottom, 32)
        }
    }

    private func notificationRow(for row: NotificationViewData) -> some View {
        HStack(alignment: .center, spacing: 14) {
            notificationTypeIcon(systemName: row.iconSystemName)

            Text(row.title)
                .font(.poppins(.regular, size: 16))
                .foregroundStyle(Color.theme.primaryText)
                .lineLimit(1)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(row.dateText)
                .font(.poppins(.regular, size: 12))
                .foregroundStyle(Color.theme.primaryText.opacity(0.55))
                .layoutPriority(1)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.theme.primaryText.opacity(0.7))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }

    private func notificationTypeIcon(systemName: String) -> some View {
        ZStack {
            Circle()
                .stroke(Color.theme.primaryText.opacity(0.55), lineWidth: 1)
                .frame(width: 42, height: 42)
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(Color.theme.primaryText)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 24)
            Image(systemName: "bell.slash")
                .font(.system(size: 64, weight: .ultraLight))
                .foregroundStyle(Color.theme.primaryText.opacity(0.9))

            Text("Tu historial de avisos está limpio")
                .font(.poppins(.bold, size: 20))
                .foregroundStyle(Color.theme.primaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text("Sigue explorando el mapa para encontrar historias.")
                .font(.poppins(.regular, size: 16))
                .foregroundStyle(Color.theme.primaryText.opacity(0.78))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
            Spacer(minLength: 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct MockNotificationLogServiceForPreview: NotificationLogServiceProtocol {
    func log(_ item: NotificationItem) { }

    func fetchAll() -> [NotificationItem] {
        [
            NotificationItem(
                id: UUID(),
                date: Date().addingTimeInterval(-60 * 5),
                type: .proximityGrouped,
                storyId: nil,
                storyTitle: nil,
                count: 1
            ),
            NotificationItem(
                id: UUID(),
                date: Date().addingTimeInterval(-60 * 90),
                type: .storyUnlocked,
                storyId: UUID().uuidString,
                storyTitle: "La casa abandonada",
                count: nil
            )
        ]
    }
}

#Preview("Con avisos") {
    NotificationsView(
        viewModel: NotificationsViewModel(logService: MockNotificationLogServiceForPreview()),
        onItemTap: { _ in }
    )
}

private final class EmptyNotificationLogForPreview: NotificationLogServiceProtocol {
    func log(_ item: NotificationItem) { }
    func fetchAll() -> [NotificationItem] { [] }
}

#Preview("Vacío") {
    NotificationsView(
        viewModel: NotificationsViewModel(logService: EmptyNotificationLogForPreview()),
        onItemTap: { _ in }
    )
}
