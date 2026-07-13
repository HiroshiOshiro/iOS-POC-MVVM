#import "BreedListViewController.h"
#import "BreedListViewModel.h"
#import "BreedCell.h"
#import "iOS_POC_MVVM-Swift.h"

@interface BreedListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) BreedListViewModel *viewModel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation BreedListViewController

- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _viewModel = [[BreedListViewModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"breed_list.title", nil);
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupTableView];
    [self setupSpinner];
    [self bindViewModel];
    [self.viewModel loadBreeds];
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

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self
                action:@selector(handleRefresh)
      forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = refresh;

    [self.view addSubview:self.tableView];
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
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
            [self.tableView.refreshControl endRefreshing];
        }
        if (self.viewModel.errorMessage) {
            [self showError:self.viewModel.errorMessage];
        }
        [self.tableView reloadData];
    };
}

- (void)handleRefresh {
    [self.viewModel loadBreeds];
}

- (void)showError:(NSString *)message {
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"common.error", nil)
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"common.ok", nil)
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.breeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BreedCell *cell = [tableView
        dequeueReusableCellWithIdentifier:BreedCellReuseIdentifier
                             forIndexPath:indexPath];
    Breed *breed = [self.viewModel breedAtIndex:indexPath.row];
    BOOL isFav = [self.viewModel isFavoriteAtIndex:indexPath.row];
    [cell configureWithBreed:breed isFavorite:isFav];

    NSInteger row = indexPath.row;
    __weak typeof(self) weakSelf = self;
    cell.onFavoriteTapped = ^{
        [weakSelf.viewModel toggleFavoriteAtIndex:row];
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

@end
