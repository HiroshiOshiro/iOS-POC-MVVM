#import "BreedListViewModel.h"
#import "DogAPIService.h"
#import "FavoritesStore.h"

@interface BreedListViewModel ()
@property (nonatomic, copy) NSArray<Breed *> *breeds;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, copy, nullable) NSString *errorMessage;
@end

@implementation BreedListViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _breeds = @[];
        // お気に入りの変化に追従して再描画する
        [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(favoritesDidChange)
                   name:FavoritesStoreDidChangeNotification
                 object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadBreeds {
    if (self.isLoading) {
        return;
    }
    self.isLoading = YES;
    self.errorMessage = nil;
    [self notifyStateChange];

    __weak typeof(self) weakSelf = self;
    [[DogAPIService sharedService] fetchBreedsWithCompletion:
        ^(NSArray<Breed *> *breeds, NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return; }
        self.isLoading = NO;
        if (error) {
            self.errorMessage = error.localizedDescription;
        } else {
            self.breeds = breeds ?: @[];
            self.errorMessage = nil;
        }
        [self notifyStateChange];
    }];
}

- (Breed *)breedAtIndex:(NSUInteger)index {
    return self.breeds[index];
}

- (BOOL)isFavoriteAtIndex:(NSUInteger)index {
    return [[FavoritesStore sharedStore] isFavorite:[self breedAtIndex:index].name];
}

- (void)toggleFavoriteAtIndex:(NSUInteger)index {
    [[FavoritesStore sharedStore] toggleFavorite:[self breedAtIndex:index].name];
    // 変更は通知経由で onStateChange へ伝わる
}

#pragma mark - Private

- (void)favoritesDidChange {
    [self notifyStateChange];
}

- (void)notifyStateChange {
    if (self.onStateChange) {
        self.onStateChange();
    }
}

@end
