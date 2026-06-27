#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 犬種を表すモデル。dog.ceo API の `breeds/list/all` の 1 エントリに対応する。
@interface Breed : NSObject

/// API 上の犬種名（例: "bulldog"）。小文字。
@property (nonatomic, copy, readonly) NSString *name;

/// サブ犬種の配列（例: bulldog -> ["boston", "english", "french"]）。無ければ空配列。
@property (nonatomic, copy, readonly) NSArray<NSString *> *subBreeds;

- (instancetype)initWithName:(NSString *)name
                   subBreeds:(NSArray<NSString *> *)subBreeds NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/// 表示用に整形した犬種名（例: "Bulldog"）。
@property (nonatomic, copy, readonly) NSString *displayName;

/// サブ犬種を読みやすい一文にしたもの（無ければ nil）。
@property (nonatomic, copy, readonly, nullable) NSString *subBreedsDescription;

@end

NS_ASSUME_NONNULL_END
