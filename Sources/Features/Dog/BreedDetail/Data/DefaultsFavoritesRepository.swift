import Foundation

/// 既存の FavoritesStore（ObjC, NSUserDefaults ベース）をラップする実装。
final class DefaultsFavoritesRepository: FavoritesRepository, @unchecked Sendable {
    private let store: FavoritesStore
    private let notificationCenter: NotificationCenter

    init(store: FavoritesStore = .shared(),
         notificationCenter: NotificationCenter = .default) {
        self.store = store
        self.notificationCenter = notificationCenter
    }

    func isFavorite(_ breedName: String) -> Bool {
        store.isFavorite(breedName)
    }

    @discardableResult
    func toggle(_ breedName: String) -> Bool {
        store.toggleFavorite(breedName)
    }

    func observeChanges(_ handler: @escaping @Sendable () -> Void) -> ObservationToken {
        let observer = notificationCenter.addObserver(
            forName: .FavoritesStoreDidChange,
            object: nil,
            queue: .main
        ) { _ in handler() }
        let center = notificationCenter
        return ObservationToken { [weak observer] in
            if let observer { center.removeObserver(observer) }
        }
    }
}

private extension Notification.Name {
    /// FavoritesStoreDidChangeNotification（ObjC 側の extern 定数）を Swift 側で参照しやすくする。
    static let FavoritesStoreDidChange =
        Notification.Name(rawValue: "FavoritesStoreDidChangeNotification")
}
