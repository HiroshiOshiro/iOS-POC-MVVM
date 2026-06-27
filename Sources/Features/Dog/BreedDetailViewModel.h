#import <Foundation/Foundation.h>
#import "Breed.h"

NS_ASSUME_NONNULL_BEGIN

/// 犬種詳細画面の ViewModel。お気に入りタブからも同じものを使う。
@interface BreedDetailViewModel : NSObject

@property (nonatomic, strong, readonly) Breed *breed;

/// 取得済みの画像 URL 配列。
@property (nonatomic, copy, readonly) NSArray<NSString *> *imageURLs;

@property (nonatomic, assign, readonly) BOOL isLoading;
@property (nonatomic, copy, readonly, nullable) NSString *errorMessage;

/// 状態変化時に呼ばれる（メインスレッド）。
@property (nonatomic, copy, nullable) void (^onStateChange)(void);

- (instancetype)initWithBreed:(Breed *)breed NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, copy, readonly) NSString *title;

/// 現在お気に入りかどうか。
- (BOOL)isFavorite;

/// お気に入りをトグルする。
- (void)toggleFavorite;

/// 画像を読み込む。
- (void)loadImages;

@end

NS_ASSUME_NONNULL_END
