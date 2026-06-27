#import "SettingsViewModel.h"
#import "AuthService.h"

@interface SettingsViewModel ()
@property (nonatomic, strong, nullable) User *currentUser;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, copy, nullable) NSString *errorMessage;
@end

@implementation SettingsViewModel

- (BOOL)isLoggedIn {
    return self.currentUser != nil;
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password {
    if (self.isLoading) { return; }
    self.isLoading = YES;
    self.errorMessage = nil;
    [self notifyStateChange];

    __weak typeof(self) weakSelf = self;
    [[AuthService sharedService] loginWithEmail:email
                                       password:password
                                     completion:^(User *user, NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return; }
        self.isLoading = NO;
        if (error) {
            self.errorMessage = error.localizedDescription;
            self.currentUser = nil;
        } else {
            self.currentUser = user;
            self.errorMessage = nil;
        }
        [self notifyStateChange];
    }];
}

- (void)logout {
    self.currentUser = nil;
    self.errorMessage = nil;
    [self notifyStateChange];
}

#pragma mark - Private

- (void)notifyStateChange {
    if (self.onStateChange) {
        self.onStateChange();
    }
}

@end
