import SwiftUI

/// BreedDetail 機能のサービス層。
/// nalexn 系 mvvm ブランチでは Interactor ではなく Service と呼ぶ。
/// ViewModel から呼び出され、Repository を組み合わせて副作用を実行する。
protocol BreedDetailService: Sendable {
    @MainActor func loadImages(into images: Binding<Loadable<[URL]>>, breed: BreedItem)
    @MainActor func isFavorite(_ breed: BreedItem) -> Bool
    @MainActor @discardableResult
    func toggleFavorite(_ breed: BreedItem) -> Bool
    func observeFavoritesChanges(_ handler: @escaping @Sendable () -> Void) -> ObservationToken
}

struct DefaultBreedDetailService: BreedDetailService {
    private let imagesRepository: BreedImagesRepository
    private let favoritesRepository: FavoritesRepository

    init(imagesRepository: BreedImagesRepository,
         favoritesRepository: FavoritesRepository) {
        self.imagesRepository = imagesRepository
        self.favoritesRepository = favoritesRepository
    }

    @MainActor
    func loadImages(into images: Binding<Loadable<[URL]>>, breed: BreedItem) {
        images.wrappedValue = .isLoading(last: images.wrappedValue.value)
        Task { @MainActor in
            do {
                let urls = try await imagesRepository
                    .fetchImages(forBreed: breed.name, count: 6)
                images.wrappedValue = .loaded(urls)
            } catch {
                images.wrappedValue = .failed(error)
            }
        }
    }

    @MainActor
    func isFavorite(_ breed: BreedItem) -> Bool {
        favoritesRepository.isFavorite(breed.name)
    }

    @MainActor
    @discardableResult
    func toggleFavorite(_ breed: BreedItem) -> Bool {
        favoritesRepository.toggle(breed.name)
    }

    func observeFavoritesChanges(_ handler: @escaping @Sendable () -> Void) -> ObservationToken {
        favoritesRepository.observeChanges(handler)
    }
}
