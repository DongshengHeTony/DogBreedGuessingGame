//
//  DogBreedService.h
//  DogBreedGuessingGame
//
//  Created by 李响 on 2024/5/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SuccessBlock)(NSData *data, NSURLResponse *response);
typedef void(^failBlock)(NSError *error);

@interface NetworkService : NSObject

+ (instancetype)sharedNetworkService;

- (void)GETRequestWithUrl:(NSString *)urlString paramaters:(NSMutableDictionary * _Nullable)paramaters successBlock:(SuccessBlock)success FailBlock:(failBlock)fail;

@end

NS_ASSUME_NONNULL_END
