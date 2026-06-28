import Foundation

/// お気に入りの読み書きと変更通知を担当するリポジトリ（Domain）。
protocol FavoritesRepository: Sendable {
    func isFavorite(_ breedName: String) -> Bool
    @discardableResult
    func toggle(_ breedName: String) -> Bool
    /// 変更通知を購読する。返却された ObservationToken を保持している間だけ有効。
    func observeChanges(_ handler: @escaping @Sendable () -> Void) -> ObservationToken
}

/// 購読解除を deinit に紐づけるためのトークン。
final class ObservationToken: @unchecked Sendable {
    private let unsubscribe: () -> Void
    init(unsubscribe: @escaping () -> Void) { self.unsubscribe = unsubscribe }
    deinit { unsubscribe() }
}
