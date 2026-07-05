import SwiftUI

/// 犬種詳細画面の SwiftUI View。
/// ViewModel はコンストラクタ注入（nalexn 系 mvvm ブランチのパターン）。
/// ナビゲーションバー(タイトル / お気に入りボタン)はラッパ VC が UIKit で管理する。
@MainActor
struct BreedDetailView: View {

    @ObservedObject private(set) var viewModel: ViewModel

    var body: some View {
        content
    }

    @ViewBuilder private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            Divider()
            imagesSection
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.breed.displayName)
                .font(.title)
            if let subs = viewModel.breed.subBreedsDescription {
                Text("サブ犬種: \(subs)")
                    .foregroundColor(.secondary)
            } else {
                Text("サブ犬種なし")
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    @ViewBuilder private var imagesSection: some View {
        switch viewModel.imageURLs {
        case .notRequested:
            notRequestedView
        case .isLoading(let last):
            isLoadingView(last: last)
        case .loaded(let urls):
            grid(urls: urls)
        case .failed(let error):
            failedView(error)
        }
    }

    private var notRequestedView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear { viewModel.loadImages() }
    }

    @ViewBuilder
    private func isLoadingView(last: [URL]?) -> some View {
        if let last {
            grid(urls: last)
        } else {
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func failedView(_ error: Error) -> some View {
        VStack(spacing: 8) {
            Text("画像の取得に失敗しました")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }

    private func grid(urls: [URL]) -> some View {
        let columns = [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8),
        ]
        return ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(urls, id: \.self) { url in
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            Color(.tertiarySystemBackground)
                        default:
                            Color(.secondarySystemBackground)
                        }
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(16)
        }
    }
}
