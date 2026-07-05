import Foundation

/// 非同期取得値の状態を 1 つの enum で表現する型。
/// nalexn/clean-architecture-swiftui の Loadable<T> を踏襲。
enum Loadable<T> {
    case notRequested
    case isLoading(last: T?)
    case loaded(T)
    case failed(Error)

    var value: T? {
        switch self {
        case let .loaded(value): return value
        case let .isLoading(last): return last
        case .notRequested, .failed: return nil
        }
    }

    var error: Error? {
        if case let .failed(error) = self { return error }
        return nil
    }
}

extension Loadable: Sendable where T: Sendable {}
