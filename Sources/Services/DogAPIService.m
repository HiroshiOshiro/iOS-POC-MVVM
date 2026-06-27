#import "DogAPIService.h"

static NSString *const kDogAPIBaseURL = @"https://dog.ceo/api";
static NSString *const kDogAPIErrorDomain = @"com.poc.DogAPIService";

@interface DogAPIService ()
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation DogAPIService

+ (instancetype)sharedService {
    static DogAPIService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DogAPIService alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _session = [NSURLSession sessionWithConfiguration:
                    [NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

#pragma mark - Public

- (void)fetchBreedsWithCompletion:(void (^)(NSArray<Breed *> *_Nullable,
                                            NSError *_Nullable))completion {
    NSString *urlString =
        [NSString stringWithFormat:@"%@/breeds/list/all", kDogAPIBaseURL];
    [self getJSONAtURL:urlString completion:^(NSDictionary *json, NSError *error) {
        if (error) {
            [self callOnMain:completion withResult:nil error:error];
            return;
        }
        NSDictionary *message = json[@"message"];
        if (![message isKindOfClass:[NSDictionary class]]) {
            [self callOnMain:completion withResult:nil
                       error:[self parseError]];
            return;
        }
        NSMutableArray<Breed *> *breeds = [NSMutableArray array];
        NSArray<NSString *> *sortedNames =
            [message.allKeys sortedArrayUsingSelector:@selector(compare:)];
        for (NSString *name in sortedNames) {
            NSArray *subs = message[name];
            if (![subs isKindOfClass:[NSArray class]]) {
                subs = @[];
            }
            [breeds addObject:[[Breed alloc] initWithName:name subBreeds:subs]];
        }
        [self callOnMain:completion withResult:breeds error:nil];
    }];
}

- (void)fetchImagesForBreed:(NSString *)breed
                      count:(NSUInteger)count
                 completion:(void (^)(NSArray<NSString *> *_Nullable,
                                      NSError *_Nullable))completion {
    NSString *urlString =
        [NSString stringWithFormat:@"%@/breed/%@/images/random/%lu",
         kDogAPIBaseURL, breed, (unsigned long)count];
    [self getJSONAtURL:urlString completion:^(NSDictionary *json, NSError *error) {
        if (error) {
            [self callOnMain:completion withResult:nil error:error];
            return;
        }
        NSArray *message = json[@"message"];
        if (![message isKindOfClass:[NSArray class]]) {
            [self callOnMain:completion withResult:nil error:[self parseError]];
            return;
        }
        [self callOnMain:completion withResult:message error:nil];
    }];
}

#pragma mark - Helpers

- (void)getJSONAtURL:(NSString *)urlString
          completion:(void (^)(NSDictionary *json, NSError *error))completion {
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        completion(nil, [self parseError]);
        return;
    }
    NSURLSessionDataTask *task =
        [self.session dataTaskWithURL:url
                    completionHandler:^(NSData *data,
                                        NSURLResponse *response,
                                        NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data
                                                  options:0
                                                    error:&jsonError];
        if (jsonError || ![json isKindOfClass:[NSDictionary class]]) {
            completion(nil, jsonError ?: [self parseError]);
            return;
        }
        completion(json, nil);
    }];
    [task resume];
}

- (NSError *)parseError {
    return [NSError errorWithDomain:kDogAPIErrorDomain
                               code:-1
                           userInfo:@{NSLocalizedDescriptionKey:
                                          @"レスポンスの解析に失敗しました"}];
}

- (void)callOnMain:(id)completion withResult:(id)result error:(NSError *)error {
    void (^block)(id, NSError *) = completion;
    dispatch_async(dispatch_get_main_queue(), ^{
        block(result, error);
    });
}

@end
