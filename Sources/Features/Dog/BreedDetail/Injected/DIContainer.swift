import Foundation

/// nalexn 系 mvvm ブランチ風の DIContainer。
/// ViewModel のコンストラクタに直接渡されてサービスへアクセスするためのコンテナ。
struct DIContainer: Sendable {
    let services: Services

    struct Services: Sendable {
        let breedDetail: BreedDetailService
    }
}
