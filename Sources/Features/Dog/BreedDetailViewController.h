#import <UIKit/UIKit.h>
#import "Breed.h"

NS_ASSUME_NONNULL_BEGIN

/// 犬種詳細画面。Dog タブ・お気に入りタブの双方から使用する。
@interface BreedDetailViewController : UIViewController

- (instancetype)initWithBreed:(Breed *)breed;

@end

NS_ASSUME_NONNULL_END
