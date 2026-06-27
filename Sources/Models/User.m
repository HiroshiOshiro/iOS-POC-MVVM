#import "User.h"

@implementation User

- (instancetype)initWithUserId:(NSString *)userId
                   displayName:(NSString *)displayName
                         email:(NSString *)email
                         token:(NSString *)token {
    self = [super init];
    if (self) {
        _userId = [userId copy];
        _displayName = [displayName copy];
        _email = [email copy];
        _token = [token copy];
    }
    return self;
}

@end
