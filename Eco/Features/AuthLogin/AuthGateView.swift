//
//  AuthGateView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Root auth gate: splash, sign-in flows, nickname onboarding, main app shell.
//

import Foundation
import SwiftUI

/// Auth sequence context: `docs/EcoCorePipelines.md` — **Email Login Pipeline** (and related onboarding).
struct AuthGateView: View {
    
    // MARK: - Dependencies
    
    let container: AppDIContainer
    @Bindable var viewModel: AuthGateViewModel
    @Environment(\.scenePhase) private var scenePhase
    
    // MARK: - Internal Flow State
    
    @State private var flowStep: UnauthStep = .welcome
    @State private var isRegistering = true
    @State private var socialAuthViewModel: SocialAuthViewModel?
    @State private var showLocationOnboarding = false
    
    // MARK: - Persistence and Policy
    
    @AppStorage("eco.hasSeenLocationOnboarding") private var hasSeenLocationOnboarding = false
    @AppStorage("eco.lastBackgroundAt") private var lastBackgroundAt: Double = 0
    private let inactivityTimeoutSeconds: TimeInterval = 60 * 30

    enum UnauthStep { case welcome, social, emailAuth }

    var body: some View {
        Group {
            switch viewModel.state {
            case .checking:
                SplashView()
                
            case .unauthenticated:
                switch flowStep {
                    
                case .welcome:
                    WelcomeView(
                        onRegisterSelected: {
                            isRegistering = true
                            ensureSocialAuthViewModel()
                            flowStep = .social
                        },
                        onLoginSelected: {
                            isRegistering = false
                            ensureSocialAuthViewModel()
                            flowStep = .social
                        }
                    )
                case .social:
                    Group {
                        if let social = socialAuthViewModel {
                            SocialRegisterView(
                                viewModel: social,
                                onEmailTap: { flowStep = .emailAuth },
                                onLoginTap: {
                                    isRegistering = false
                                    flowStep = .emailAuth
                                }
                            )
                        } else {
                            ProgressView()
                                .onAppear { ensureSocialAuthViewModel() }
                        }
                    }
                case .emailAuth:
                    Group {
                        if let social = socialAuthViewModel {
                            if isRegistering {
                                RegisterView(viewModel: container.makeRegisterViewModel(), onLoginTap: { isRegistering = false })
                            } else {
                                LoginView(
                                    viewModel: container.makeLoginViewModel(),
                                    socialViewModel: social,
                                    onRegisterTap: { isRegistering = true }
                                )
                            }
                        } else {
                            ProgressView()
                                .onAppear { ensureSocialAuthViewModel() }
                        }
                    }
                }

            case .needsNickname:
                OnboardingNicknameView { name in
                    viewModel.completeNicknameOnboarding(with: name)
                }

            case .authenticated:
                ZStack {
                    RootView(container: container)
                        .syncOnReconnect { await container.triggerSync() }

                    if showLocationOnboarding {
                        LocationOnboardingView {
                            Task {
                                try? await container.makeLocationService().requestWhenInUse()
                                hasSeenLocationOnboarding = true
                                await MainActor.run {
                                    withAnimation(.spring()) {
                                        showLocationOnboarding = false
                                    }
                                }
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
            }
        }
        .animation(.spring(), value: viewModel.state)
        .animation(.spring(), value: flowStep)
        
        // MARK: - Lifecycle Observers
        
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .inactive, .background:
                lastBackgroundAt = Date().timeIntervalSince1970
            case .active:
                guard case .authenticated = viewModel.state else { return }
                guard lastBackgroundAt > 0 else { return }
                let elapsed = Date().timeIntervalSince1970 - lastBackgroundAt
                if elapsed >= inactivityTimeoutSeconds {
                    viewModel.logoutByInactivity()
                }
            @unknown default:
                break
            }
        }
        .task {
            if case .authenticated = viewModel.state,
               !hasSeenLocationOnboarding {
                showLocationOnboarding = true
            }
        }
    }

    // MARK: - Private Helpers
    
    /// Creates ``SocialAuthViewModel`` on first entry into the unauthenticated flow (avoids constructing it during splash).
    private func ensureSocialAuthViewModel() {
        if socialAuthViewModel == nil {
            socialAuthViewModel = container.makeSocialAuthViewModel()
        }
    }
}

// MARK: - Preview
#Preview {
    let container = AppDIContainer()
    let viewModel = container.makeAuthGateViewModel()
    AuthGateView(container: container, viewModel: viewModel)
}
