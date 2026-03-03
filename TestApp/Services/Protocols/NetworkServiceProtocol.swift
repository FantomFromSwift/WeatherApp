protocol NetworkServiceProtocol {
    var isConnected: Bool { get }
    var connectionType: ConnectionType { get }
    var connectivityStream: AsyncStream<Bool> { get }
    
    func startMonitoring()
    func stopMonitoring()
}
