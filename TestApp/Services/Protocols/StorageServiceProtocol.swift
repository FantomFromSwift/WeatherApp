import Foundation
import SwiftData

protocol StorageServiceProtocol {
    func saveNote(text: String, timestamp: Date, weather: WeatherData?, localityName: String?) async throws
    func delete<Object: PersistentModel>(_ object: Object) async throws
    func fetch<Object: PersistentModel>(_ type: Object.Type, where predicate: Predicate<Object>) async throws -> [Object]
    func fetchAll<Object: PersistentModel>(_ type: Object.Type) async throws -> [Object]
}
