import Foundation

/// 犬種の画像 URL を取得する Repository。
protocol BreedImagesRepository: Sendable {
    func fetchImages(forBreed name: String, count: Int) async throws -> [URL]
}
