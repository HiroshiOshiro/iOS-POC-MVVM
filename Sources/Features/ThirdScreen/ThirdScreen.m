#import "ThirdScreen.h"

@interface ThirdScreen ()
@property (nonatomic, assign) NSInteger randomNumber;
@property (nonatomic, strong) UILabel *numberLabel;
@end

@implementation ThirdScreen

- (instancetype)initWithRandomNumber:(NSInteger)randomNumber {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _randomNumber = randomNumber;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"third_screen.title", nil);
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupViews];
}

- (void)setupViews {
    self.numberLabel = [[UILabel alloc] init];
    self.numberLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleLargeTitle];
    self.numberLabel.textAlignment = NSTextAlignmentCenter;
    self.numberLabel.text =
        [NSString stringWithFormat:NSLocalizedString(@"third_screen.received_number_format", nil),
                                    (long)self.randomNumber];
    self.numberLabel.translatesAutoresizingMaskIntoConstraints = NO;

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIButtonConfiguration *config = [UIButtonConfiguration filledButtonConfiguration];
    config.title = NSLocalizedString(@"third_screen.back", nil);
    backButton.configuration = config;
    [backButton addTarget:self
                    action:@selector(backTapped)
          forControlEvents:UIControlEventTouchUpInside];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:self.numberLabel];
    [self.view addSubview:backButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.numberLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.numberLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-40],

        [backButton.topAnchor constraintEqualToAnchor:self.numberLabel.bottomAnchor constant:24],
        [backButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
    ]];
}

- (void)backTapped {
    // 明示的な戻るボタン。UINavigationController の自動バックボタンでも同様に戻れる。
    [self.navigationController popViewControllerAnimated:YES];
}

@end
