import Foundation

/// 犬種詳細画面の ViewModel。UIKit 非依存・MainActor 隔離でテスタブル。
@MainActor
final class BreedDetailViewModel {
    let breed: BreedItem

    private(set) var imageURLs: [URL] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    /// 状態変化時に呼ばれる（メインスレッド）。
    var onStateChange: (() -> Void)?

    private let fetchImagesUseCase: FetchBreedImagesUseCase
    private let favoritesUseCase: FavoritesUseCase
    private var favoritesToken: ObservationToken?
    private var loadTask: Task<Void, Never>?

    var title: String { breed.displayName }

    init(breed: BreedItem,
         fetchImagesUseCase: FetchBreedImagesUseCase,
         favoritesUseCase: FavoritesUseCase) {
        self.breed = breed
        self.fetchImagesUseCase = fetchImagesUseCase
        self.favoritesUseCase = favoritesUseCase
        self.favoritesToken = favoritesUseCase.observeChanges { [weak self] in
            MainActor.assumeIsolated { self?.notifyStateChange() }
        }
    }

    deinit {
        loadTask?.cancel()
    }

    func isFavorite() -> Bool {
        favoritesUseCase.isFavorite(breed.name)
    }

    func toggleFavorite() {
        favoritesUseCase.toggle(breed.name)
        // 状態は observeChanges 経由で onStateChange に反映される
    }

    func loadImages() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        notifyStateChange()

        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                let urls = try await self.fetchImagesUseCase
                    .execute(breedName: self.breed.name, count: 6)
                self.imageURLs = urls
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
            self.notifyStateChange()
        }
    }

    private func notifyStateChange() {
        onStateChange?()
    }
}
