#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Swift 側 (BreedDetailViewController) から push される ObjC 画面。
/// ObjC -> Swift -> ObjC の画面遷移経路と値渡しを確認するためのサンプル画面。
@interface ThirdScreen : UIViewController

- (instancetype)initWithRandomNumber:(NSInteger)randomNumber NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                          bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
