import Foundation

/// 詳細画面で扱う犬種ドメインエンティティ。Presentation 層が依存する純粋な値オブジェクト。
struct BreedItem: Equatable {
    let name: String
    let displayName: String
    let subBreedsDescription: String?
}
