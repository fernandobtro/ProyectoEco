//
//  AnimationTestView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 26/03/26.
//

import SwiftUI

struct PlantingAnimationOverlay: View {
    let onCompleted: () -> Void

    @State private var currentStage: AnimationStage = .none
    @State private var seedPosition: CGPoint = .zero
    @State private var seedRotation: Double = 0
    @State private var seedScale: CGFloat = 1.8
    @State private var seedShadow: CGFloat = 20
    @State private var plantScale: CGFloat = 0
    /// Landing point for seed and plant; derived from the overlay’s layout, not `UIScreen.main`.
    @State private var animationTargetPoint: CGPoint = .zero

    enum AnimationStage {
        case none, flying, growing
    }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ZStack {
                switch currentStage {
                case .flying:
                    Image("Semilla")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(seedRotation))
                        .scaleEffect(seedScale)
                        .shadow(color: .black.opacity(0.2), radius: seedShadow / 2, y: seedShadow)
                        .position(seedPosition)
                case .growing:
                    Image("Plantita")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .scaleEffect(plantScale, anchor: .bottom)
                        .position(animationTargetPoint)
                case .none:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                if size.width > 0, size.height > 0 {
                    startAnimation(containerSize: size)
                } else {
                    DispatchQueue.main.async {
                        startAnimation(containerSize: geometry.size)
                    }
                }
            }
        }
    }

    private func startAnimation(containerSize: CGSize) {
        guard currentStage == .none else { return }
        guard containerSize.width > 0, containerSize.height > 0 else { return }

        animationTargetPoint = CGPoint(
            x: containerSize.width / 2,
            y: containerSize.height / 2 - 50
        )
        seedPosition = CGPoint(
            x: containerSize.width / 2,
            y: containerSize.height + 50
        )
        seedRotation = 0
        seedScale = 1.8
        seedShadow = 20

        withAnimation(.none) {
            currentStage = .flying
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            withAnimation(.interpolatingSpring(stiffness: 45, damping: 15).speed(0.8)) {
                seedPosition = animationTargetPoint
                seedRotation = 360
                seedScale = 0.4
                seedShadow = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            currentStage = .growing
            plantScale = 0
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)) {
                plantScale = 1.0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.45) {
            onCompleted()
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        PlantingAnimationOverlay {}
    }
}
