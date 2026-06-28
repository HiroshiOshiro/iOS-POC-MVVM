import Foundation

protocol FetchBreedImagesUseCase: Sendable {
    func execute(breedName: String, count: Int) async throws -> [URL]
}

struct DefaultFetchBreedImagesUseCase: FetchBreedImagesUseCase {
    private let repository: BreedImagesRepository

    init(repository: BreedImagesRepository) {
        self.repository = repository
    }

    func execute(breedName: String, count: Int) async throws -> [URL] {
        try await repository.fetchImages(forBreed: breedName, count: count)
    }
}
