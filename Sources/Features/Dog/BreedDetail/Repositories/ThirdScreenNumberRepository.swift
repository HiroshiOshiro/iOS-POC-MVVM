import Foundation

/// ThirdScreen へ渡す番号を取得する Repository。
protocol ThirdScreenNumberRepository: Sendable {
    func fetchNumber() async throws -> Int
}

/// フェイクの API 呼び出し。1 秒待ってランダムな番号を返すだけのモック実装。
struct FakeThirdScreenNumberRepository: ThirdScreenNumberRepository {
    func fetchNumber() async throws -> Int {
        // 実際の API 通信の代わりに 1 秒スリープして遅延を再現する。
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return Int.random(in: 0..<1000)
    }
}
