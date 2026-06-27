#import "BreedCell.h"

NSString *const BreedCellReuseIdentifier = @"BreedCell";

@interface BreedCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIButton *favoriteButton;
@end

@implementation BreedCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.subtitleLabel.textColor = [UIColor secondaryLabelColor];
    self.subtitleLabel.numberOfLines = 2;
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.favoriteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.favoriteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.favoriteButton addTarget:self
                            action:@selector(favoriteButtonTapped)
                  forControlEvents:UIControlEventTouchUpInside];
    // タップ領域を確保
    [self.favoriteButton.widthAnchor constraintEqualToConstant:44].active = YES;

    UIStackView *textStack = [[UIStackView alloc]
        initWithArrangedSubviews:@[self.titleLabel, self.subtitleLabel]];
    textStack.axis = UILayoutConstraintAxisVertical;
    textStack.spacing = 2;
    textStack.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView addSubview:textStack];
    [self.contentView addSubview:self.favoriteButton];

    UILayoutGuide *margins = self.contentView.layoutMarginsGuide;
    [NSLayoutConstraint activateConstraints:@[
        [textStack.leadingAnchor constraintEqualToAnchor:margins.leadingAnchor],
        [textStack.topAnchor constraintEqualToAnchor:margins.topAnchor],
        [textStack.bottomAnchor constraintEqualToAnchor:margins.bottomAnchor],
        [textStack.trailingAnchor
            constraintEqualToAnchor:self.favoriteButton.leadingAnchor constant:-8],
        [self.favoriteButton.trailingAnchor
            constraintEqualToAnchor:margins.trailingAnchor],
        [self.favoriteButton.centerYAnchor
            constraintEqualToAnchor:self.contentView.centerYAnchor],
    ]];
}

- (void)configureWithBreed:(Breed *)breed isFavorite:(BOOL)isFavorite {
    self.titleLabel.text = breed.displayName;
    NSString *subText = breed.subBreedsDescription;
    self.subtitleLabel.text = subText ? subText : @"サブ犬種なし";
    [self updateFavoriteAppearance:isFavorite];
}

- (void)updateFavoriteAppearance:(BOOL)isFavorite {
    NSString *symbol = isFavorite ? @"heart.fill" : @"heart";
    [self.favoriteButton setImage:[UIImage systemImageNamed:symbol]
                         forState:UIControlStateNormal];
    self.favoriteButton.tintColor =
        isFavorite ? [UIColor systemRedColor] : [UIColor systemGrayColor];
}

- (void)favoriteButtonTapped {
    if (self.onFavoriteTapped) {
        self.onFavoriteTapped();
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.onFavoriteTapped = nil;
}

@end
