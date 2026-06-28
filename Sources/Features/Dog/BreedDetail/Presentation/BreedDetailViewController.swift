import UIKit

/// 犬種詳細画面。Dog タブ・お気に入りタブの双方から使用する（ObjC からも参照される）。
@objc(BreedDetailViewController)
final class BreedDetailViewController: UIViewController {

    private static let imageCellID = "DogImageCell"
    private static let headerID = "DogDetailHeaderView"

    private let viewModel: BreedDetailViewModel
    private var collectionView: UICollectionView!
    private var spinner: UIActivityIndicatorView!
    private var favoriteButton: UIBarButtonItem!

    // MARK: - Init

    @objc init(breed: Breed) {
        let item = BreedItem(
            name: breed.name,
            displayName: breed.displayName,
            subBreedsDescription: breed.subBreedsDescription
        )
        self.viewModel = BreedDetailViewModel(
            breed: item,
            fetchImagesUseCase: DefaultFetchBreedImagesUseCase(
                repository: DogAPIBreedImagesRepository()
            ),
            favoritesUseCase: DefaultFavoritesUseCase(
                repository: DefaultsFavoritesRepository()
            )
        )
        super.init(nibName: nil, bundle: nil)
    }

    /// Designated init から派生（テスト・DI 用途）。
    init(viewModel: BreedDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        view.backgroundColor = .systemBackground
        setupCollectionView()
        setupSpinner()
        setupFavoriteButton()
        bindViewModel()
        viewModel.loadImages()
    }

    // MARK: - Setup

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DogImageCell.self,
                                forCellWithReuseIdentifier: Self.imageCellID)
        collectionView.register(
            DogDetailHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: Self.headerID
        )

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func setupSpinner() {
        spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setupFavoriteButton() {
        favoriteButton = UIBarButtonItem(
            image: nil,
            style: .plain,
            target: self,
            action: #selector(favoriteTapped)
        )
        navigationItem.rightBarButtonItem = favoriteButton
        updateFavoriteButton()
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] in
            guard let self else { return }
            if self.viewModel.isLoading {
                self.spinner.startAnimating()
            } else {
                self.spinner.stopAnimating()
            }
            self.updateFavoriteButton()
            self.collectionView.reloadData()
        }
    }

    private func updateFavoriteButton() {
        let isFav = viewModel.isFavorite()
        let symbol = isFav ? "heart.fill" : "heart"
        favoriteButton.image = UIImage(systemName: symbol)
        favoriteButton.tintColor = isFav ? .systemRed : nil
    }

    @objc private func favoriteTapped() {
        viewModel.toggleFavorite()
    }
}

// MARK: - UICollectionViewDataSource

extension BreedDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.imageURLs.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Self.imageCellID,
            for: indexPath
        ) as! DogImageCell
        let url = viewModel.imageURLs[indexPath.item]
        let urlString = url.absoluteString
        cell.representedURL = urlString
        ImageLoader.shared().loadImageURL(urlString) { [weak cell] image in
            // セルが別の URL に再利用されていないかを確認
            guard let cell, cell.representedURL == urlString else { return }
            cell.imageView.image = image
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: Self.headerID,
            for: indexPath
        ) as! DogDetailHeaderView
        header.titleLabel.text = viewModel.breed.displayName
        if let subs = viewModel.breed.subBreedsDescription {
            header.subtitleLabel.text = "サブ犬種: \(subs)"
        } else {
            header.subtitleLabel.text = "サブ犬種なし"
        }
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension BreedDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let available = collectionView.bounds.width - 16 * 2 - 8
        let side = floor(available / 2.0)
        return CGSize(width: side, height: side)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 90)
    }
}

// MARK: - Image Cell

private final class DogImageCell: UICollectionViewCell {
    let imageView = UIImageView()
    var representedURL: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.frame = contentView.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = 8
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        representedURL = nil
    }
}

// MARK: - Header

private final class DogDetailHeaderView: UICollectionReusableView {
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.font = .preferredFont(forTextStyle: .body)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
}
