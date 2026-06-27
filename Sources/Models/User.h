#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// ログイン成功時に表示するユーザー情報モデル。
@interface User : NSObject

@property (nonatomic, copy, readonly) NSString *userId;
@property (nonatomic, copy, readonly) NSString *displayName;
@property (nonatomic, copy, readonly) NSString *email;
@property (nonatomic, copy, readonly) NSString *token;

- (instancetype)initWithUserId:(NSString *)userId
                   displayName:(NSString *)displayName
                         email:(NSString *)email
                         token:(NSString *)token NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
