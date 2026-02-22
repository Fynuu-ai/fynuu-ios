//
//  ModelDownloadView.swift
//  fynuu
//
//  Created by Keetha Nikhil on 21/02/26.
//

import SwiftUI

struct ModelDownloadView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var service = ModelDownloadService.shared

    private var fileSizeLabel: String { "~400 MB" }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 100, height: 100)
                    Image(systemName: "brain")
                        .font(.system(size: 46, weight: .thin))
                        .foregroundStyle(LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                }

                Spacer().frame(height: 32)

                VStack(spacing: 10) {
                    Text("Download AI Model")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Qwen 2.5 · 0.5B · 6-bit")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Capsule())

                    Text("This model runs fully on-device.\nYour conversations stay private.")
                        .font(.subheadline)
                        .foregroundColor(Color(white: 0.45))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 4)
                }

                Spacer().frame(height: 52)

                // Progress area
                if service.isDownloading {
                    VStack(spacing: 12) {
                        // Progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(white: 0.15))
                                    .frame(height: 8)

                                RoundedRectangle(cornerRadius: 6)
                                    .fill(LinearGradient(
                                        colors: [.green, .blue],
                                        startPoint: .leading, endPoint: .trailing
                                    ))
                                    .frame(width: geo.size.width * service.progress, height: 8)
                                    .animation(.easeInOut(duration: 0.3), value: service.progress)
                            }
                        }
                        .frame(height: 8)
                        .padding(.horizontal, 32)

                        HStack {
                            Text("\(Int(service.progress * 100))%")
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(.green)
                            Spacer()
                            if service.totalMB > 0 {
                                Text(String(format: "%.0f / %.0f MB", service.downloadedMB, service.totalMB))
                                    .font(.caption)
                                    .foregroundColor(Color(white: 0.4))
                            }
                        }
                        .padding(.horizontal, 32)
                    }
                }

                // Error
                if let err = service.error {
                    Text(err)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                }

                Spacer()

                // Button
                Button {
                    if service.isModelDownloaded {
                        finish()
                    } else {
                        service.startDownload()
                    }
                } label: {
                    HStack(spacing: 10) {
                        if service.isDownloading {
                            ProgressView().tint(.black).scaleEffect(0.85)
                            Text("Downloading...")
                        } else if service.isModelDownloaded {
                            Image(systemName: "checkmark")
                            Text("Continue")
                        } else {
                            Image(systemName: "arrow.down.circle")
                            Text("Download · \(fileSizeLabel)")
                        }
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        service.isDownloading
                        ? LinearGradient(colors: [Color(white: 0.3), Color(white: 0.3)],
                                         startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(colors: [.green, .blue],
                                         startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(service.isDownloading)
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
        // Auto-advance when download completes
        .onChange(of: service.progress) { _, newValue in
            if newValue >= 1.0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    finish()
                }
            }
        }
    }

    private func finish() {
        appState.hasCompletedOnboarding = true
        appState.route = .homeChat
    }
}
