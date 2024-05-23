//
//  DogBreedService.m
//  DogBreedGuessingGame
//
//  Created by 李响 on 2024/5/17.
//

#import "NetworkService.h"

@implementation NetworkService

+ (instancetype)sharedNetworkService {
    static id _instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}

- (void)GETRequestWithUrl:(NSString *)urlString paramaters:(NSMutableDictionary * _Nullable)paramaters successBlock:(SuccessBlock)success FailBlock:(failBlock)fail

{
    NSMutableString *strM = [[NSMutableString alloc] init];
    if (paramaters) {
        [paramaters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *paramaterKey = key;
            NSString *paramaterValue = obj;
            [strM appendFormat:@"%@=%@&",paramaterKey,paramaterValue];
        }];
    }
    urlString = [NSString stringWithFormat:@"%@?%@",urlString,strM];
    urlString = [urlString substringToIndex:urlString.length - 1];
    
    NSLog(@"urlString:%@",urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if (data && !error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    success(data,response);
                }
            });
        } else {
            if (fail) {
                fail(error);
            }
        }
    }] resume];
}

@end
