#import <Foundation/Foundation.h>
#import "Breed.h"

NS_ASSUME_NONNULL_BEGIN

/// お気に入り一覧画面の ViewModel。
@interface FavoritesListViewModel : NSObject

/// お気に入りに登録された犬種一覧。
@property (nonatomic, copy, readonly) NSArray<Breed *> *favorites;

@property (nonatomic, assign, readonly) BOOL isLoading;
@property (nonatomic, copy, readonly, nullable) NSString *errorMessage;

@property (nonatomic, copy, nullable) void (^onStateChange)(void);

/// お気に入り一覧を読み込む（全犬種を取得し、お気に入り名で絞り込む）。
- (void)load;

- (Breed *)breedAtIndex:(NSUInteger)index;

/// index のお気に入りを解除する。
- (void)removeFavoriteAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
