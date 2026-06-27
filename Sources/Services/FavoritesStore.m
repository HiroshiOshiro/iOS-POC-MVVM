#import "FavoritesStore.h"

NSNotificationName const FavoritesStoreDidChangeNotification =
    @"FavoritesStoreDidChangeNotification";

static NSString *const kFavoritesDefaultsKey = @"favorite_breed_names";

@interface FavoritesStore ()
@property (nonatomic, strong) NSMutableArray<NSString *> *favorites;
@end

@implementation FavoritesStore

+ (instancetype)sharedStore {
    static FavoritesStore *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FavoritesStore alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSArray *saved =
            [[NSUserDefaults standardUserDefaults] arrayForKey:kFavoritesDefaultsKey];
        _favorites = saved ? [saved mutableCopy] : [NSMutableArray array];
    }
    return self;
}

- (NSArray<NSString *> *)favoriteBreedNames {
    return [self.favorites copy];
}

- (BOOL)isFavorite:(NSString *)breedName {
    return [self.favorites containsObject:breedName];
}

- (void)addFavorite:(NSString *)breedName {
    if (breedName.length == 0 || [self.favorites containsObject:breedName]) {
        return;
    }
    [self.favorites addObject:breedName];
    [self persistAndNotify];
}

- (void)removeFavorite:(NSString *)breedName {
    if (![self.favorites containsObject:breedName]) {
        return;
    }
    [self.favorites removeObject:breedName];
    [self persistAndNotify];
}

- (BOOL)toggleFavorite:(NSString *)breedName {
    if ([self isFavorite:breedName]) {
        [self removeFavorite:breedName];
        return NO;
    } else {
        [self addFavorite:breedName];
        return YES;
    }
}

#pragma mark - Private

- (void)persistAndNotify {
    [[NSUserDefaults standardUserDefaults] setObject:[self.favorites copy]
                                              forKey:kFavoritesDefaultsKey];
    [[NSNotificationCenter defaultCenter]
        postNotificationName:FavoritesStoreDidChangeNotification object:self];
}

@end
