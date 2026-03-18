//
//  AuthGateView.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation
import SwiftUI

struct AuthGateView: View {
    let container: AppDIContainer
    @Bindable var viewModel: AuthGateViewModel
    @State private var isRegistering = false
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .checking:
                ProgressView("Checking session...")
            case .authenticated:
                RootView(container: container)
            case .unauthenticated:
                if isRegistering {
                    RegisterView(
                        viewModel: container.makeRegisterViewModel(),
                        onLoginTap: { isRegistering = false }
                    )
                } else {
                    LoginView(
                        viewModel: container.makeLoginViewModel(),
                        onRegisterTap: { isRegistering = true }
                    )
                }
            }
        }
    }
}
