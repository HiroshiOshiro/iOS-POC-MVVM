#import <Foundation/Foundation.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

/// Setting タブ（ログイン）の ViewModel。
@interface SettingsViewModel : NSObject

/// ログイン済みのユーザー（未ログインなら nil）。
@property (nonatomic, strong, readonly, nullable) User *currentUser;

@property (nonatomic, assign, readonly) BOOL isLoading;
@property (nonatomic, copy, readonly, nullable) NSString *errorMessage;

@property (nonatomic, copy, nullable) void (^onStateChange)(void);

/// ログイン済みかどうか。
- (BOOL)isLoggedIn;

/// ログインを実行する（モック）。
- (void)loginWithEmail:(NSString *)email password:(NSString *)password;

/// ログアウトする。
- (void)logout;

@end

NS_ASSUME_NONNULL_END
