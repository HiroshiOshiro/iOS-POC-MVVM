#import <Foundation/Foundation.h>
#import "Breed.h"

NS_ASSUME_NONNULL_BEGIN

/// お気に入りが変化したときに通知される通知名。
extern NSNotificationName const FavoritesStoreDidChangeNotification;

/// お気に入り犬種を NSUserDefaults に永続化するストア。
@interface FavoritesStore : NSObject

+ (instancetype)sharedStore;

/// お気に入り犬種名の配列（追加順）。
@property (nonatomic, copy, readonly) NSArray<NSString *> *favoriteBreedNames;

- (BOOL)isFavorite:(NSString *)breedName;
- (void)addFavorite:(NSString *)breedName;
- (void)removeFavorite:(NSString *)breedName;

/// 追加されていれば削除、なければ追加する。結果（お気に入り状態）を返す。
- (BOOL)toggleFavorite:(NSString *)breedName;

@end

NS_ASSUME_NONNULL_END
