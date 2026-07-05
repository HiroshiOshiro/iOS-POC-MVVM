import Foundation
import os

/// dog.ceo API から犬種の画像 URL を取得する Repository。
/// ObjC の DogAPIService を経由せず、URLSession + async/await で直接実装する。
final class DogAPIBreedImagesRepository: BreedImagesRepository, @unchecked Sendable {

    private let session: URLSession
    private let baseURL: URL
    private let logger = Logger(subsystem: "com.poc.iOS-POC-MVVM", category: "DogAPI")

    init(session: URLSession = .shared,
         baseURL: URL = URL(string: "https://dog.ceo/api")!) {
        self.session = session
        self.baseURL = baseURL
    }

    func fetchImages(forBreed name: String, count: Int) async throws -> [URL] {
        // https://dog.ceo/api/breed/{breed}/images/random/{count}
        let url = baseURL
            .appendingPathComponent("breed")
            .appendingPathComponent(name)
            .appendingPathComponent("images")
            .appendingPathComponent("random")
            .appendingPathComponent(String(count))

        logger.info("➡️ REQUEST GET \(url.absoluteString, privacy: .public)")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            logger.error("❌ REQUEST FAILED \(url.absoluteString, privacy: .public) — \(error.localizedDescription, privacy: .public)")
            throw error
        }

        guard let http = response as? HTTPURLResponse else {
            logger.error("❌ RESPONSE not HTTPURLResponse")
            throw DogAPIError.invalidResponse
        }

        let body = String(data: data, encoding: .utf8) ?? "<non-utf8 \(data.count) bytes>"
        logger.info("⬅️ RESPONSE \(http.statusCode, privacy: .public) \(url.absoluteString, privacy: .public)\n\(body, privacy: .public)")

        guard (200..<300).contains(http.statusCode) else {
            throw DogAPIError.httpStatus(http.statusCode)
        }

        let decoded: BreedImagesResponse
        do {
            decoded = try JSONDecoder().decode(BreedImagesResponse.self, from: data)
        } catch {
            logger.error("❌ DECODING FAILED — \(error.localizedDescription, privacy: .public)")
            throw DogAPIError.decoding(error)
        }

        guard decoded.status == "success" else {
            throw DogAPIError.apiFailure(status: decoded.status)
        }

        let urls = decoded.message.compactMap { URL(string: $0) }
        logger.info("✅ PARSED \(urls.count, privacy: .public) image URL(s)")
        return urls
    }
}

// MARK: - Response

/// `{ "message": [urlString...], "status": "success" }`
private struct BreedImagesResponse: Decodable {
    let message: [String]
    let status: String
}

// MARK: - Error

enum DogAPIError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)
    case decoding(Error)
    case apiFailure(status: String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "サーバーからの応答が不正です"
        case .httpStatus(let code):
            return "通信に失敗しました（HTTP \(code)）"
        case .decoding:
            return "レスポンスの解析に失敗しました"
        case .apiFailure(let status):
            return "API がエラーを返しました（status: \(status)）"
        }
    }
}
