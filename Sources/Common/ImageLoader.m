#import "ImageLoader.h"

@interface ImageLoader ()
@property (nonatomic, strong) NSCache<NSString *, UIImage *> *cache;
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation ImageLoader

+ (instancetype)sharedLoader {
    static ImageLoader *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ImageLoader alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cache = [[NSCache alloc] init];
        _session = [NSURLSession sessionWithConfiguration:
                    [NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

- (void)loadImageURL:(NSString *)urlString
          completion:(void (^)(UIImage *_Nullable))completion {
    UIImage *cached = [self.cache objectForKey:urlString];
    if (cached) {
        completion(cached);
        return;
    }
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        completion(nil);
        return;
    }
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task =
        [self.session dataTaskWithURL:url
                    completionHandler:^(NSData *data,
                                        NSURLResponse *response,
                                        NSError *error) {
        UIImage *image = data ? [UIImage imageWithData:data] : nil;
        if (image) {
            [weakSelf.cache setObject:image forKey:urlString];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(image);
        });
    }];
    [task resume];
}

@end
