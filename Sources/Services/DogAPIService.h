#import <Foundation/Foundation.h>
#import "Breed.h"

NS_ASSUME_NONNULL_BEGIN

/// dog.ceo API へのアクセスを担当するサービス層。
@interface DogAPIService : NSObject

+ (instancetype)sharedService;

/// 犬種一覧を取得する。https://dog.ceo/api/breeds/list/all
/// 完了ハンドラはメインスレッドで呼ばれる。
- (void)fetchBreedsWithCompletion:(void (^)(NSArray<Breed *> *_Nullable breeds,
                                            NSError *_Nullable error))completion;

/// 指定した犬種の画像 URL を最大 count 件取得する。
/// https://dog.ceo/api/breed/{breed}/images/random/{count}
/// 完了ハンドラはメインスレッドで呼ばれる。
- (void)fetchImagesForBreed:(NSString *)breed
                      count:(NSUInteger)count
                 completion:(void (^)(NSArray<NSString *> *_Nullable imageURLs,
                                      NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
