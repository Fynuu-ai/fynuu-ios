//
//  ModelDownloadService.swift
//  fynuu
//
//  Created by Keetha Nikhil on 22/02/26.
//
import Foundation

@MainActor
final class ModelDownloadService: NSObject, ObservableObject {
    static let shared = ModelDownloadService()

    private let downloadURL = URL(string: "https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q6_k.gguf")!
    let modelFileName = "qwen2.5-0.5b-q6k.gguf"

    @Published var progress: Double = 0
    @Published var isDownloading = false
    @Published var error: String? = nil
    @Published var downloadedMB: Double = 0
    @Published var totalMB: Double = 0

    private var downloadTask: URLSessionDownloadTask?
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 7200
        // Allow high throughput
        config.httpMaximumConnectionsPerHost = 6
        config.networkServiceType = .responsiveData
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    var localModelURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(modelFileName)
    }

    var isModelDownloaded: Bool {
        FileManager.default.fileExists(atPath: localModelURL.path)
    }

    func startDownload() {
        guard !isModelDownloaded, !isDownloading else { return }
        isDownloading = true
        error = nil
        progress = 0
        downloadedMB = 0
        totalMB = 0

        var request = URLRequest(url: downloadURL)
        request.setValue("HybridChat-iOS", forHTTPHeaderField: "User-Agent")

        downloadTask = session.downloadTask(with: request)
        downloadTask?.resume()
    }

    func cancel() {
        downloadTask?.cancel()
        isDownloading = false
    }
}

// MARK: - URLSessionDownloadDelegate

extension ModelDownloadService: URLSessionDownloadDelegate {

    nonisolated func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        do {
            let dest = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(modelFileName)

            if FileManager.default.fileExists(atPath: dest.path) {
                try FileManager.default.removeItem(at: dest)
            }
            try FileManager.default.moveItem(at: location, to: dest)

            DispatchQueue.main.async {
                self.progress = 1.0
                self.isDownloading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.error = "Failed to save model: \(error.localizedDescription)"
                self.isDownloading = false
            }
        }
    }

    nonisolated func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        let downloaded = Double(totalBytesWritten) / 1_048_576
        let total = Double(totalBytesExpectedToWrite) / 1_048_576
        let pct = totalBytesExpectedToWrite > 0
            ? Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            : 0

        DispatchQueue.main.async {
            self.downloadedMB = downloaded
            self.totalMB = total
            self.progress = pct
        }
    }

    nonisolated func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        guard let error else { return }
        // Ignore cancellation
        let nsErr = error as NSError
        guard nsErr.code != NSURLErrorCancelled else { return }

        DispatchQueue.main.async {
            self.error = error.localizedDescription
            self.isDownloading = false
        }
    }
}
