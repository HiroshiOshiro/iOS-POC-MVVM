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
                    favoritesRepository: DefaultsFavoritesRepository()
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
        navigationItem.rightBarButtonItem?.tintColor = isFav ? .systemRed : nil
    }

    @objc private func favoriteTapped() {
        container.services.breedDetail.toggleFavorite(item)
    }
}
