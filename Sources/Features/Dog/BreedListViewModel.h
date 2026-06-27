#import <Foundation/Foundation.h>
#import "Breed.h"

NS_ASSUME_NONNULL_BEGIN

/// 犬種一覧画面の ViewModel。
@interface BreedListViewModel : NSObject

/// 表示中の犬種一覧。
@property (nonatomic, copy, readonly) NSArray<Breed *> *breeds;

/// ローディング中かどうか。
@property (nonatomic, assign, readonly) BOOL isLoading;

/// 直近のエラーメッセージ（無ければ nil）。
@property (nonatomic, copy, readonly, nullable) NSString *errorMessage;

/// 状態が変化したら呼ばれる。VC 側で UI 更新に使う（メインスレッド）。
@property (nonatomic, copy, nullable) void (^onStateChange)(void);

/// 犬種一覧を読み込む。
- (void)loadBreeds;

/// index の犬種を返す。
- (Breed *)breedAtIndex:(NSUInteger)index;

/// index の犬種がお気に入りかどうか。
- (BOOL)isFavoriteAtIndex:(NSUInteger)index;

/// index の犬種のお気に入りをトグルする。
- (void)toggleFavoriteAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
