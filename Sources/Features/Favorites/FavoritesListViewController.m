#import "FavoritesListViewController.h"
#import "FavoritesListViewModel.h"
#import "BreedCell.h"
#import "iOS_POC_MVVM-Swift.h"

@interface FavoritesListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) FavoritesListViewModel *viewModel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation FavoritesListViewController

- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _viewModel = [[FavoritesListViewModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"お気に入り";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupTableView];
    [self setupEmptyLabel];
    [self setupSpinner];
    [self bindViewModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel load];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 64;
    [self.tableView registerClass:[BreedCell class]
           forCellReuseIdentifier:BreedCellReuseIdentifier];
    [self.view addSubview:self.tableView];
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    ]];
}

- (void)setupEmptyLabel {
    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.text = @"お気に入りはまだありません。\nDog タブの ♡ で追加できます。";
    self.emptyLabel.numberOfLines = 0;
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.textColor = [UIColor secondaryLabelColor];
    self.emptyLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.emptyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.emptyLabel.hidden = YES;
    [self.view addSubview:self.emptyLabel];
    [NSLayoutConstraint activateConstraints:@[
        [self.emptyLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.emptyLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.emptyLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:32],
        [self.emptyLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-32],
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
        BOOL empty = (!self.viewModel.isLoading && self.viewModel.favorites.count == 0);
        self.emptyLabel.hidden = !empty;
        [self.tableView reloadData];
    };
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.favorites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BreedCell *cell = [tableView
        dequeueReusableCellWithIdentifier:BreedCellReuseIdentifier
                             forIndexPath:indexPath];
    Breed *breed = [self.viewModel breedAtIndex:indexPath.row];
    [cell configureWithBreed:breed isFavorite:YES];
    NSInteger row = indexPath.row;
    __weak typeof(self) weakSelf = self;
    cell.onFavoriteTapped = ^{
        [weakSelf.viewModel removeFavoriteAtIndex:row];
    };
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Breed *breed = [self.viewModel breedAtIndex:indexPath.row];
    BreedDetailViewController *detail =
        [[BreedDetailViewController alloc] initWithBreed:breed];
    [self.navigationController pushViewController:detail animated:YES];
}

// スワイプ削除もサポート
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    UIContextualAction *delete =
        [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                title:@"削除"
                                              handler:^(UIContextualAction *action,
                                                        UIView *sourceView,
                                                        void (^completionHandler)(BOOL)) {
        [weakSelf.viewModel removeFavoriteAtIndex:indexPath.row];
        completionHandler(YES);
    }];
    return [UISwipeActionsConfiguration configurationWithActions:@[delete]];
}

@end
