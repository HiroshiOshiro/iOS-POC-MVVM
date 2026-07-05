#import "AuthService.h"
#import <os/log.h>

static NSString *const kAuthErrorDomain = @"com.poc.AuthService";

static os_log_t AuthLog(void) {
    static os_log_t log;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        log = os_log_create("com.poc.iOS-POC-MVVM", "Auth");
    });
    return log;
}

@implementation AuthService

+ (instancetype)sharedService {
    static AuthService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AuthService alloc] init];
    });
    return instance;
}

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
            completion:(void (^)(User *_Nullable, NSError *_Nullable))completion {

    // --- 本来の API 送信処理（モックのため未実行）-----------------------------
    // NSURL *url = [NSURL URLWithString:@"https://example.com/api/login"];
    // NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // request.HTTPMethod = @"POST";
    // [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // NSDictionary *body = @{@"email": email, @"password": password};
    // request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body
    //                                                    options:0 error:nil];
    // NSURLSessionDataTask *task = [[NSURLSession sharedSession]
    //     dataTaskWithRequest:request completionHandler:^(NSData *data, ...){ ... }];
    // [task resume];
    // -------------------------------------------------------------------------

    NSString *trimmedEmail =
        [email stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // リクエストログ（パスワードは伏せる）
    os_log_info(AuthLog(), "➡️ REQUEST POST /api/login (mock) email=%{public}@", trimmedEmail);

    // 擬似的なネットワーク遅延
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        if (trimmedEmail.length == 0 || password.length < 4) {
            NSError *error =
                [NSError errorWithDomain:kAuthErrorDomain
                                    code:401
                                userInfo:@{NSLocalizedDescriptionKey:
                                               @"メールアドレスまたはパスワードが正しくありません"}];
            os_log_error(AuthLog(), "⬅️ RESPONSE 401 /api/login (mock) — %{public}@",
                         error.localizedDescription);
            completion(nil, error);
            return;
        }

        // モックのユーザー情報を返す
        User *user =
            [[User alloc] initWithUserId:@"u_000123"
                             displayName:@"山田 太郎"
                                   email:trimmedEmail
                                   token:@"mock-token-abcdef123456"];
        os_log_info(AuthLog(), "⬅️ RESPONSE 200 /api/login (mock) userId=%{public}@",
                    user.userId);
        completion(user, nil);
    });
}

@end
