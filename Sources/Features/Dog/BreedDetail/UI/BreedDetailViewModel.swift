import SwiftUI

/// nalexn 系 mvvm ブランチ風に、View の nested type として ViewModel を定義する。
extension BreedDetailView {
    @MainActor
    final class ViewModel: ObservableObject {

        // State
        let breed: BreedItem
        @Published var imageURLs: Loadable<[URL]> = .notRequested

        // Misc
        let container: DIContainer

        init(container: DIContainer, breed: BreedItem) {
            self.container = container
            self.breed = breed
        }

        // MARK: - Side Effects

        func loadImages() {
            let binding = Binding<Loadable<[URL]>>(
                get: { [weak self] in self?.imageURLs ?? .notRequested },
                set: { [weak self] in self?.imageURLs = $0 }
            )
            container.services.breedDetail.loadImages(into: binding, breed: breed)
        }
    }
}
