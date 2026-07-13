#import "SettingsViewController.h"
#import "SettingsViewModel.h"

@interface SettingsViewController () <UITextFieldDelegate>
@property (nonatomic, strong) SettingsViewModel *viewModel;

// ログインフォーム
@property (nonatomic, strong) UIStackView *loginStack;
@property (nonatomic, strong) UITextField *emailField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

// プロフィール表示
@property (nonatomic, strong) UIStackView *profileStack;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *idLabel;
@property (nonatomic, strong) UILabel *emailLabel;
@property (nonatomic, strong) UILabel *tokenLabel;
@property (nonatomic, strong) UIButton *logoutButton;
@end

@implementation SettingsViewController

- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _viewModel = [[SettingsViewModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"settings.title", nil);
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupLoginForm];
    [self setupProfileView];
    [self bindViewModel];
    [self render];

    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

#pragma mark - Setup

- (UITextField *)makeFieldWithPlaceholder:(NSString *)placeholder {
    UITextField *field = [[UITextField alloc] init];
    field.placeholder = placeholder;
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.delegate = self;
    field.translatesAutoresizingMaskIntoConstraints = NO;
    [field.heightAnchor constraintEqualToConstant:44].active = YES;
    return field;
}

- (void)setupLoginForm {
    UILabel *heading = [[UILabel alloc] init];
    heading.text = NSLocalizedString(@"settings.login", nil);
    heading.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];

    self.emailField =
        [self makeFieldWithPlaceholder:NSLocalizedString(@"settings.email", nil)];
    self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailField.textContentType = UITextContentTypeUsername;

    self.passwordField =
        [self makeFieldWithPlaceholder:NSLocalizedString(@"settings.password", nil)];
    self.passwordField.secureTextEntry = YES;
    self.passwordField.textContentType = UITextContentTypePassword;

    self.errorLabel = [[UILabel alloc] init];
    self.errorLabel.textColor = [UIColor systemRedColor];
    self.errorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    self.errorLabel.numberOfLines = 0;
    self.errorLabel.hidden = YES;

    self.loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIButtonConfiguration *config = [UIButtonConfiguration filledButtonConfiguration];
    config.title = NSLocalizedString(@"settings.login", nil);
    self.loginButton.configuration = config;
    [self.loginButton addTarget:self
                         action:@selector(loginTapped)
               forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton.heightAnchor constraintEqualToConstant:48].active = YES;

    self.spinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.spinner.hidesWhenStopped = YES;

    UILabel *hint = [[UILabel alloc] init];
    hint.text = NSLocalizedString(@"settings.mock_hint", nil);
    hint.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    hint.textColor = [UIColor secondaryLabelColor];
    hint.numberOfLines = 0;

    self.loginStack = [[UIStackView alloc] initWithArrangedSubviews:@[
        heading, self.emailField, self.passwordField,
        self.errorLabel, self.loginButton, self.spinner, hint
    ]];
    self.loginStack.axis = UILayoutConstraintAxisVertical;
    self.loginStack.spacing = 14;
    self.loginStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.loginStack];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.loginStack.topAnchor constraintEqualToAnchor:safe.topAnchor constant:32],
        [self.loginStack.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:24],
        [self.loginStack.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-24],
    ]];
}

- (UILabel *)makeProfileLabelWithStyle:(UIFontTextStyle)style {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont preferredFontForTextStyle:style];
    label.numberOfLines = 0;
    return label;
}

- (void)setupProfileView {
    UIImageView *avatar = [[UIImageView alloc]
        initWithImage:[UIImage systemImageNamed:@"person.crop.circle.fill"]];
    avatar.tintColor = [UIColor systemBlueColor];
    avatar.contentMode = UIViewContentModeScaleAspectFit;
    [avatar.heightAnchor constraintEqualToConstant:80].active = YES;

    self.nameLabel = [self makeProfileLabelWithStyle:UIFontTextStyleTitle2];
    self.idLabel = [self makeProfileLabelWithStyle:UIFontTextStyleSubheadline];
    self.idLabel.textColor = [UIColor secondaryLabelColor];
    self.emailLabel = [self makeProfileLabelWithStyle:UIFontTextStyleBody];
    self.tokenLabel = [self makeProfileLabelWithStyle:UIFontTextStyleFootnote];
    self.tokenLabel.textColor = [UIColor secondaryLabelColor];

    self.logoutButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIButtonConfiguration *config = [UIButtonConfiguration tintedButtonConfiguration];
    config.title = NSLocalizedString(@"settings.logout", nil);
    config.baseForegroundColor = [UIColor systemRedColor];
    self.logoutButton.configuration = config;
    [self.logoutButton addTarget:self
                          action:@selector(logoutTapped)
                forControlEvents:UIControlEventTouchUpInside];
    [self.logoutButton.heightAnchor constraintEqualToConstant:48].active = YES;

    self.profileStack = [[UIStackView alloc] initWithArrangedSubviews:@[
        avatar, self.nameLabel, self.idLabel, self.emailLabel,
        self.tokenLabel, self.logoutButton
    ]];
    self.profileStack.axis = UILayoutConstraintAxisVertical;
    self.profileStack.spacing = 12;
    self.profileStack.alignment = UIStackViewAlignmentLeading;
    self.profileStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.profileStack];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.profileStack.topAnchor constraintEqualToAnchor:safe.topAnchor constant:32],
        [self.profileStack.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:24],
        [self.profileStack.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-24],
    ]];
}

- (void)bindViewModel {
    __weak typeof(self) weakSelf = self;
    self.viewModel.onStateChange = ^{
        [weakSelf render];
    };
}

#pragma mark - Render

- (void)render {
    BOOL loggedIn = [self.viewModel isLoggedIn];
    self.loginStack.hidden = loggedIn;
    self.profileStack.hidden = !loggedIn;

    if (self.viewModel.isLoading) {
        [self.spinner startAnimating];
        self.loginButton.enabled = NO;
    } else {
        [self.spinner stopAnimating];
        self.loginButton.enabled = YES;
    }

    self.errorLabel.text = self.viewModel.errorMessage;
    self.errorLabel.hidden = (self.viewModel.errorMessage == nil);

    User *user = self.viewModel.currentUser;
    if (user) {
        self.nameLabel.text = user.displayName;
        self.idLabel.text =
            [NSString stringWithFormat:NSLocalizedString(@"settings.id_format", nil), user.userId];
        self.emailLabel.text =
            [NSString stringWithFormat:NSLocalizedString(@"settings.email_format", nil), user.email];
        self.tokenLabel.text =
            [NSString stringWithFormat:NSLocalizedString(@"settings.token_format", nil), user.token];
    }
}

#pragma mark - Actions

- (void)loginTapped {
    [self dismissKeyboard];
    [self.viewModel loginWithEmail:self.emailField.text ?: @""
                          password:self.passwordField.text ?: @""];
}

- (void)logoutTapped {
    self.emailField.text = @"";
    self.passwordField.text = @"";
    [self.viewModel logout];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    } else {
        [self loginTapped];
    }
    return YES;
}

@end
