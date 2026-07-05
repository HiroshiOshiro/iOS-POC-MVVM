import Foundation

/// 既存の DogAPIService（ObjC）をラップする BreedImagesRepository の実装。
final class DogAPIBreedImagesRepository: BreedImagesRepository, @unchecked Sendable {
    private let service: DogAPIService

    init(service: DogAPIService = .shared()) {
        self.service = service
    }

    func fetchImages(forBreed name: String, count: Int) async throws -> [URL] {
        try await withCheckedThrowingContinuation { continuation in
            service.fetchImages(forBreed: name, count: UInt(count)) { urlStrings, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let urls = (urlStrings ?? []).compactMap { URL(string: $0) }
                continuation.resume(returning: urls)
            }
        }
    }
}
