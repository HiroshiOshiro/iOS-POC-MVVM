import SwiftUI
import UIKit

/// ObjC 側からの呼び出しを維持するためのブリッジ。
/// UIHostingController を子として埋め込み、ナビゲーションバーは UIKit 側で管理する。
@objc(BreedDetailViewController)
final class BreedDetailViewController: UIViewController {

    private let host: UIHostingController<BreedDetailView>
    private let viewModel: BreedDetailView.ViewModel
    private let container: DIContainer
    private let item: BreedItem
    private var favoritesToken: ObservationToken?

    @objc init(breed: Breed) {
        let item = BreedItem(
            name: breed.name,
            displayName: breed.displayName,
            subBreedsDescription: breed.subBreedsDescription
        )
        let container = DIContainer(
            services: .init(
                breedDetail: DefaultBreedDetailService(
                    imagesRepository: DogAPIBreedImagesRepository(),
                    favoritesRepository: DefaultsFavoritesRepository(),
                    thirdScreenNumberRepository: FakeThirdScreenNumberRepository()
                )
            )
        )
        let viewModel = BreedDetailView.ViewModel(container: container, breed: item)
        self.item = item
        self.container = container
        self.viewModel = viewModel
        self.host = UIHostingController(
            rootView: BreedDetailView(viewModel: viewModel)
        )
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = item.displayName
        view.backgroundColor = .systemBackground
        embedHost()
        setupFavoriteButton()
        setupThirdScreenButton()
    }

    private func embedHost() {
        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        host.didMove(toParent: self)
    }

    private func setupFavoriteButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: nil,
            style: .plain,
            target: self,
            action: #selector(favoriteTapped)
        )
        refreshFavoriteButton()
        favoritesToken = container.services.breedDetail.observeFavoritesChanges { [weak self] in
            Task { @MainActor in self?.refreshFavoriteButton() }
        }
    }

    private func refreshFavoriteButton() {
        let isFav = container.services.breedDetail.isFavorite(item)
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: isFav ? "heart.fill" : "heart")
        navigationItem.rightBarButtonItem?.tintColor = isFav ? UIColor(resource: .favoriteRed) : nil
    }

    @objc private func favoriteTapped() {
        container.services.breedDetail.toggleFavorite(item)
    }

    // MARK: - ThirdScreen (ObjC) navigation

    /// Swift -> ObjC への画面遷移サンプル。ThirdScreen はブリッジングヘッダー経由で見えている ObjC クラス。
    private func setupThirdScreenButton() {
        // leftBarButtonItem を設定すると標準の戻るボタン(-> BreedList)が上書きされて消えてしまうため、
        // leftItemsSupplementBackButton = true で戻るボタンと併置する。
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: String(localized: "breed_detail.go_to_third_screen"),
            style: .plain,
            target: self,
            action: #selector(goToThirdScreenTapped)
        )
    }

    @objc private func goToThirdScreenTapped() {
        // フェイク API 呼び出し中はローディング UI を出し、ボタンを無効化する。
        setThirdScreenLoading(true)
        Task { @MainActor in
            defer { setThirdScreenLoading(false) }
            do {
                // 1 秒待ってランダムな番号を返すフェイク API。
                let number = try await container.services.breedDetail.fetchThirdScreenNumber()
                let thirdScreen = ThirdScreen(randomNumber: number)
                navigationController?.pushViewController(thirdScreen, animated: true)
            } catch {
                // フェイク API は失敗しない想定。実 API 化した場合はここでエラー表示する。
            }
        }
    }

    // MARK: - Loading UI

    /// 画面全体を覆う半透明のローディングオーバーレイ。
    private lazy var loadingOverlay: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        overlay.translatesAutoresizingMaskIntoConstraints = false

        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        overlay.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
        ])
        return overlay
    }()

    private func setThirdScreenLoading(_ isLoading: Bool) {
        navigationItem.leftBarButtonItem?.isEnabled = !isLoading
        if isLoading {
            view.addSubview(loadingOverlay)
            NSLayoutConstraint.activate([
                loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
                loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
        } else {
            loadingOverlay.removeFromSuperview()
        }
    }
}
