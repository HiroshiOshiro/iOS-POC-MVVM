#import "Breed.h"

@implementation Breed

- (instancetype)initWithName:(NSString *)name
                   subBreeds:(NSArray<NSString *> *)subBreeds {
    self = [super init];
    if (self) {
        _name = [name copy];
        _subBreeds = [subBreeds copy] ?: @[];
    }
    return self;
}

- (NSString *)displayName {
    return [self.name capitalizedString];
}

- (NSString *)subBreedsDescription {
    if (self.subBreeds.count == 0) {
        return nil;
    }
    NSMutableArray<NSString *> *capitalized =
        [NSMutableArray arrayWithCapacity:self.subBreeds.count];
    for (NSString *sub in self.subBreeds) {
        [capitalized addObject:[sub capitalizedString]];
    }
    return [capitalized componentsJoinedByString:@", "];
}

@end
