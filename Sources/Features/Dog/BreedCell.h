#import <UIKit/UIKit.h>
#import "Breed.h"

NS_ASSUME_NONNULL_BEGIN

/// 犬種一覧の 1 行を表すセル。タイトル・サブタイトル・お気に入りボタンを持つ。
@interface BreedCell : UITableViewCell

extern NSString *const BreedCellReuseIdentifier;

/// お気に入りボタンが押されたときに呼ばれる。
@property (nonatomic, copy, nullable) void (^onFavoriteTapped)(void);

- (void)configureWithBreed:(Breed *)breed isFavorite:(BOOL)isFavorite;

@end

NS_ASSUME_NONNULL_END
