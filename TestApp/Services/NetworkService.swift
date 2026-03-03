import Foundation
import Network

enum ConnectionType {
    case wifi
    case cellular
    case ethernet
    case unknown
    case none
}

@MainActor
class NetworkService: NetworkServiceProtocol {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    private var continuation: AsyncStream<Bool>.Continuation?
    private(set) var isConnected: Bool = false
    private(set) var connectionType: ConnectionType = .none

    var connectivityStream: AsyncStream<Bool> {
        AsyncStream { [weak self] continuation in
            Task { @MainActor in
                self?.setContinuation(continuation)
            }
        }
    }

    private func setContinuation(_ continuation: AsyncStream<Bool>.Continuation) {
        self.continuation = continuation
        continuation.yield(isConnected)
    }

    nonisolated func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                guard let self else { return }
                self.handlePathUpdate(path)
            }
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
        continuation?.finish()
    }

    private func handlePathUpdate(_ path: NWPath) {
        let newConnectionState = path.status == .satisfied
        isConnected = newConnectionState

        if !newConnectionState {
            connectionType = .none
        } else if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }

        continuation?.yield(isConnected)
    }
}

