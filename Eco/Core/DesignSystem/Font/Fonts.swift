//
//  Fonts.swift
//  Eco
//
//  Created by Fernando Buenrostro on 17/03/26.
//

import Foundation
import SwiftUI

extension Font {
    enum PoppinsWeight: String {
        case regular = "Poppins-Regular"
        case medium = "Poppins-Medium"
        case semiBold = "Poppins-SemiBold"
        case bold = "Poppins-Bold"
    }
    
    static func poppins(_ weight: PoppinsWeight, size: CGFloat) -> Font {
        return .custom(weight.rawValue, size: size)
    }
}
