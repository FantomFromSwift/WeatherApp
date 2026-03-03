import Foundation
import SwiftData

final class StorageService: StorageServiceProtocol {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }

    func saveNote(text: String, timestamp: Date, weather: WeatherData?, localityName: String?) async throws {
        let weatherModel: WeatherDataModel?
        if let weather {
            let w = WeatherDataModel(from: weather)
            context.insert(w)
            weatherModel = w
        } else {
            weatherModel = nil
        }
        let note = Note(text: text, timestamp: timestamp, localityName: localityName, weather: weatherModel)
        context.insert(note)
        do {
            try context.save()
        } catch {
            throw StorageErrors.saveFailed(error.localizedDescription)
        }
    }
    
    func delete<Object>(_ object: Object) async throws where Object : PersistentModel {
        do {
            context.delete(object)
            try context.save()
        } catch {
            throw StorageErrors.deleteFailed(error.localizedDescription)
        }
    }
    
    func fetch<Object: PersistentModel>(_ type: Object.Type, where predicate: Predicate<Object>) async throws -> [Object] {
        do {
            let request = FetchDescriptor<Object>(predicate: predicate)
            return try context.fetch(request)
        } catch {
            throw StorageErrors.fetchFailed(error.localizedDescription)
        }
    }
    
    func fetchAll<Object: PersistentModel>(_ type: Object.Type) async throws -> [Object] {
        do {
            let request = FetchDescriptor<Object>()
            return try context.fetch(request)
        } catch {
            throw StorageErrors.fetchFailed(error.localizedDescription)
        }
    }
}
