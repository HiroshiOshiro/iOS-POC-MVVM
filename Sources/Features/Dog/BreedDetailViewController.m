#import "BreedDetailViewController.h"
#import "BreedDetailViewModel.h"
#import "ImageLoader.h"

#pragma mark - Image Cell

@interface DogImageCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, copy) NSString *representedURL;
@end

@implementation DogImageCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor secondarySystemBackgroundColor];
        _imageView.layer.cornerRadius = 8;
        _imageView.autoresizingMask =
            UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_imageView];
    }
    return self;
}
- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.representedURL = nil;
}
@end

#pragma mark - Header

@interface DogDetailHeaderView : UICollectionReusableView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@end

@implementation DogDetailHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _subtitleLabel.textColor = [UIColor secondaryLabelColor];
        _subtitleLabel.numberOfLines = 0;
        _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;

        [self addSubview:_titleLabel];
        [self addSubview:_subtitleLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:12],
            [_titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_subtitleLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:6],
            [_subtitleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_subtitleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_subtitleLabel.bottomAnchor constraintLessThanOrEqualToAnchor:self.bottomAnchor constant:-8],
        ]];
    }
    return self;
}
@end

#pragma mark - View Controller

static NSString *const kImageCellID = @"DogImageCell";
static NSString *const kHeaderID = @"DogDetailHeaderView";

@interface BreedDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) BreedDetailViewModel *viewModel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIBarButtonItem *favoriteButton;
@end

@implementation BreedDetailViewController

- (instancetype)initWithBreed:(Breed *)breed {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _viewModel = [[BreedDetailViewModel alloc] initWithBreed:breed];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.viewModel.title;
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupCollectionView];
    [self setupSpinner];
    [self setupFavoriteButton];
    [self bindViewModel];
    [self.viewModel loadImages];
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 8;
    layout.minimumLineSpacing = 8;
    layout.sectionInset = UIEdgeInsetsMake(8, 16, 16, 16);

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                             collectionViewLayout:layout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.backgroundColor = [UIColor systemBackgroundColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[DogImageCell class]
            forCellWithReuseIdentifier:kImageCellID];
    [self.collectionView registerClass:[DogDetailHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kHeaderID];

    [self.view addSubview:self.collectionView];
    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    ]];
}

- (void)setupSpinner {
    self.spinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.spinner.hidesWhenStopped = YES;
    self.spinner.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.spinner];
    [NSLayoutConstraint activateConstraints:@[
        [self.spinner.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.spinner.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    ]];
}

- (void)setupFavoriteButton {
    self.favoriteButton =
        [[UIBarButtonItem alloc] initWithImage:nil
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(favoriteTapped)];
    self.navigationItem.rightBarButtonItem = self.favoriteButton;
    [self updateFavoriteButton];
}

- (void)bindViewModel {
    __weak typeof(self) weakSelf = self;
    self.viewModel.onStateChange = ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return; }
        if (self.viewModel.isLoading) {
            [self.spinner startAnimating];
        } else {
            [self.spinner stopAnimating];
        }
        [self updateFavoriteButton];
        [self.collectionView reloadData];
    };
}

- (void)updateFavoriteButton {
    BOOL isFav = [self.viewModel isFavorite];
    NSString *symbol = isFav ? @"heart.fill" : @"heart";
    self.favoriteButton.image = [UIImage systemImageNamed:symbol];
    self.favoriteButton.tintColor =
        isFav ? [UIColor systemRedColor] : nil;
}

- (void)favoriteTapped {
    [self.viewModel toggleFavorite];
    // 状態は通知経由で onStateChange に反映される
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.viewModel.imageURLs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DogImageCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:kImageCellID
                                                  forIndexPath:indexPath];
    NSString *urlString = self.viewModel.imageURLs[indexPath.item];
    cell.representedURL = urlString;
    [[ImageLoader sharedLoader] loadImageURL:urlString
                                  completion:^(UIImage *image) {
        // セルが別の URL に再利用されていないか確認
        if ([cell.representedURL isEqualToString:urlString]) {
            cell.imageView.image = image;
        }
    }];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    DogDetailHeaderView *header =
        [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                           withReuseIdentifier:kHeaderID
                                                  forIndexPath:indexPath];
    header.titleLabel.text = self.viewModel.breed.displayName;
    NSString *subs = self.viewModel.breed.subBreedsDescription;
    header.subtitleLabel.text =
        subs ? [NSString stringWithFormat:@"サブ犬種: %@", subs] : @"サブ犬種なし";
    return header;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat available = collectionView.bounds.size.width - 16 * 2 - 8;
    CGFloat side = floor(available / 2.0);
    return CGSizeMake(side, side);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.bounds.size.width, 90);
}

@end
