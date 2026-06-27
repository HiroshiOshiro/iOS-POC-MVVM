#import "BreedDetailViewModel.h"
#import "DogAPIService.h"
#import "FavoritesStore.h"

@interface BreedDetailViewModel ()
@property (nonatomic, strong) Breed *breed;
@property (nonatomic, copy) NSArray<NSString *> *imageURLs;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, copy, nullable) NSString *errorMessage;
@end

@implementation BreedDetailViewModel

- (instancetype)initWithBreed:(Breed *)breed {
    self = [super init];
    if (self) {
        _breed = breed;
        _imageURLs = @[];
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

- (NSString *)title {
    return self.breed.displayName;
}

- (BOOL)isFavorite {
    return [[FavoritesStore sharedStore] isFavorite:self.breed.name];
}

- (void)toggleFavorite {
    [[FavoritesStore sharedStore] toggleFavorite:self.breed.name];
}

- (void)loadImages {
    if (self.isLoading) { return; }
    self.isLoading = YES;
    self.errorMessage = nil;
    [self notifyStateChange];

    __weak typeof(self) weakSelf = self;
    [[DogAPIService sharedService] fetchImagesForBreed:self.breed.name
                                                 count:6
                                            completion:
        ^(NSArray<NSString *> *imageURLs, NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return; }
        self.isLoading = NO;
        if (error) {
            self.errorMessage = error.localizedDescription;
        } else {
            self.imageURLs = imageURLs ?: @[];
        }
        [self notifyStateChange];
    }];
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
