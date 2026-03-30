//
//  StoryPresentation.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: `StoryListRowView` vs `StoryCardView` share `StoryListRowCore` so list and explore stay aligned.
//

import SwiftUI

// MARK: - List Rows

/// Narrative: `docs/EcoCorePipelines.md` — **Collection (Planted / Discovered) Pipeline** (presentation).
struct StoryListRowView: View {
    let viewData: StoryViewData

    var body: some View {
        StoryListRowCore(viewData: viewData)
    }
}

// MARK: - Explore Cards

/// Card chrome for `ScrollView` / `LazyVStack` (map explore), does not inject navigation.
///
/// Narrative: `docs/EcoCorePipelines.md` — **Map Story Discovery Pipeline** (presentation).
struct StoryCardView: View {
    let viewData: StoryViewData

    var body: some View {
        StoryListRowCore(viewData: viewData)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.theme.exploreCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

// MARK: - Shared Layout

private struct StoryListRowCore: View {
    let viewData: StoryViewData

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(viewData.isSynced ? Color.theme.accent : Color.orange)
                    .frame(width: 10, height: 10)
                if !viewData.isSynced {
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                        .frame(width: 14, height: 14)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(viewData.title)
                        .font(.headline)
                    if viewData.showMineBadge {
                        Text("Tu Eco")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.theme.accent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.theme.accent.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                Text(viewData.subtitle)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundStyle(.secondary)
                if let footnote = viewData.footnote {
                    Text(footnote)
                        .font(.caption2)
                        .foregroundStyle(viewData.footnoteIncludesDistance ? .secondary : .tertiary)
                }
            }
        }
    }
}
