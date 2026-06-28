import Foundation

protocol FavoritesUseCase: Sendable {
    func isFavorite(_ breedName: String) -> Bool
    @discardableResult
    func toggle(_ breedName: String) -> Bool
    func observeChanges(_ handler: @escaping @Sendable () -> Void) -> ObservationToken
}

struct DefaultFavoritesUseCase: FavoritesUseCase {
    private let repository: FavoritesRepository

    init(repository: FavoritesRepository) {
        self.repository = repository
    }

    func isFavorite(_ breedName: String) -> Bool {
        repository.isFavorite(breedName)
    }

    @discardableResult
    func toggle(_ breedName: String) -> Bool {
        repository.toggle(breedName)
    }

    func observeChanges(_ handler: @escaping @Sendable () -> Void) -> ObservationToken {
        repository.observeChanges(handler)
    }
}
