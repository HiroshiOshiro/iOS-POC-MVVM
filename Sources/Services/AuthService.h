#import <Foundation/Foundation.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

/// 認証サービス。実際の API 送信処理の形を模したモック実装。
/// 本来は NSURLSession で POST する箇所をコメントで示しつつ、ローカルで結果を返す。
@interface AuthService : NSObject

+ (instancetype)sharedService;

/// email / password でログインする（モック）。
/// 0.8 秒程度の擬似ネットワーク遅延の後、メインスレッドで完了ハンドラを呼ぶ。
/// 入力が空、または password が "1234" より短い場合は失敗扱い。
- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
            completion:(void (^)(User *_Nullable user,
                                 NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
