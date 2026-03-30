//
//  EcoRelativeDateFormatting.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Relative date copy pinned to `es_MX` regardless of system language (product choice).
//

import Foundation

/// Named relative date strings (today/yesterday-style wording) using a fixed `es_MX` locale.
enum EcoRelativeDateFormatting {
    private static let locale = Locale(identifier: "es_MX")

    static func relativeNamedString(for date: Date, relativeTo reference: Date = .init()) -> String {
        date.formatted(.relative(presentation: .named).locale(Self.locale))
    }
}
