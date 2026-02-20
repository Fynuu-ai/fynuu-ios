import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appState: AppState

    @State private var iconScale: CGFloat = 0.4
    @State private var iconOpacity: Double = 0
    @State private var nameOpacity: Double = 0
    @State private var nameOffset: CGFloat = 20
    @State private var glowRadius: CGFloat = 0
    @State private var ringScale: CGFloat = 0.7
    @State private var ringOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Soft radial glow
            RadialGradient(
                colors: [Color.green.opacity(0.15), Color.blue.opacity(0.08), Color.clear],
                center: .center, startRadius: 0, endRadius: 260
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                ZStack {
                    // Animated ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.green.opacity(0.6), Color.blue.opacity(0.6)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)

                    // App icon box
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(LinearGradient(
                            colors: [Color(red: 0.05, green: 0.12, blue: 0.05),
                                     Color(red: 0.02, green: 0.06, blue: 0.12)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 90, height: 90)
                        .overlay(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .stroke(
                                    LinearGradient(colors: [Color.green.opacity(0.7), Color.blue.opacity(0.5)],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: Color.green.opacity(0.3), radius: glowRadius)
                        .overlay(
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 38, weight: .medium))
                                .foregroundStyle(LinearGradient(
                                    colors: [.green, .blue],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ))
                        )
                        .scaleEffect(iconScale)
                        .opacity(iconOpacity)
                }

                // App name + accent line
                VStack(spacing: 8) {
                    Text("HybridChat")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    HStack(spacing: 4) {
                        Circle().fill(Color.green).frame(width: 5, height: 5)
                        Rectangle()
                            .fill(LinearGradient(colors: [.green, .blue],
                                                 startPoint: .leading, endPoint: .trailing))
                            .frame(width: 60, height: 1.5)
                        Circle().fill(Color.blue).frame(width: 5, height: 5)
                    }
                }
                .opacity(nameOpacity)
                .offset(y: nameOffset)
            }
        }
        .onAppear {
            animate()
            route()
        }
    }

    private func animate() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.1)) {
            iconScale = 1.0; iconOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.7).delay(0.3)) {
            ringScale = 1.1; ringOpacity = 1.0
        }
        withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
            glowRadius = 18
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.55)) {
            nameOpacity = 1.0; nameOffset = 0
        }
    }

    private func route() {
        Task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            appState.route = appState.hasCompletedOnboarding ? .homeChat : .setup(.googleSignIn)
        }
    }
}
