#import "FavoritesListViewModel.h"
#import "DogAPIService.h"
#import "FavoritesStore.h"

@interface FavoritesListViewModel ()
@property (nonatomic, copy) NSArray<Breed *> *favorites;
@property (nonatomic, copy) NSArray<Breed *> *allBreeds;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, copy, nullable) NSString *errorMessage;
@end

@implementation FavoritesListViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _favorites = @[];
        _allBreeds = @[];
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

- (void)load {
    // 全犬種をすでに取得済みなら、絞り込みだけ行う
    if (self.allBreeds.count > 0) {
        [self rebuildFavorites];
        [self notifyStateChange];
        return;
    }
    if (self.isLoading) { return; }
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
            self.allBreeds = breeds ?: @[];
            [self rebuildFavorites];
        }
        [self notifyStateChange];
    }];
}

- (Breed *)breedAtIndex:(NSUInteger)index {
    return self.favorites[index];
}

- (void)removeFavoriteAtIndex:(NSUInteger)index {
    Breed *breed = [self breedAtIndex:index];
    [[FavoritesStore sharedStore] removeFavorite:breed.name];
    // 通知経由で rebuild される
}

#pragma mark - Private

- (void)rebuildFavorites {
    NSArray<NSString *> *favNames =
        [FavoritesStore sharedStore].favoriteBreedNames;
    NSMutableDictionary<NSString *, Breed *> *byName =
        [NSMutableDictionary dictionary];
    for (Breed *breed in self.allBreeds) {
        byName[breed.name] = breed;
    }
    NSMutableArray<Breed *> *result = [NSMutableArray array];
    for (NSString *name in favNames) {
        Breed *breed = byName[name];
        // 万一一覧に無い場合でも名前だけで生成して表示する
        if (!breed) {
            breed = [[Breed alloc] initWithName:name subBreeds:@[]];
        }
        [result addObject:breed];
    }
    self.favorites = result;
}

- (void)favoritesDidChange {
    [self rebuildFavorites];
    [self notifyStateChange];
}

- (void)notifyStateChange {
    if (self.onStateChange) {
        self.onStateChange();
    }
}

@end
