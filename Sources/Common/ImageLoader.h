#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// URL から画像を非同期で取得し、メモリキャッシュする軽量ローダー。
@interface ImageLoader : NSObject

+ (instancetype)sharedLoader;

/// 画像を読み込む。完了ハンドラはメインスレッドで呼ばれる。
- (void)loadImageURL:(NSString *)urlString
          completion:(void (^)(UIImage *_Nullable image))completion;

@end

NS_ASSUME_NONNULL_END
