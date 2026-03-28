//
//  EcoRelativeDateFormatting.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Fechas relativas fijas a español (México) para no depender del idioma del sistema.
//

import Foundation

enum EcoRelativeDateFormatting {
    private static let locale = Locale(identifier: "es_MX")

    static func relativeNamedString(for date: Date, relativeTo reference: Date = .init()) -> String {
        date.formatted(.relative(presentation: .named).locale(Self.locale))
    }
}
