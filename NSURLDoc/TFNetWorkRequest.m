//
//  TFNetWorkRequest.m
//  NSURLDoc
//
//  Created by 吴腾飞 on 2018/12/29.
//  Copyright © 2018 Damon. All rights reserved.
//

#import "TFNetWorkRequest.h"

static TFNetWorkRequest *_requestManager ;

@interface TFNetWorkRequest ()

@end

@implementation TFNetWorkRequest

#pragma mark - 单例方法
+ (TFNetWorkRequest *)shareNetWorkManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_requestManager == nil) {
            _requestManager = [[TFNetWorkRequest alloc] init] ;
        }
    });
    return _requestManager ;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _requestManager = [super allocWithZone:zone] ;
    });
    return _requestManager ;
}

- (id)copyWithZone:(NSZone *)zone {
    return _requestManager ;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _requestManager;
}


- (void)fetchWithUrl:(NSString *)urlStr httpMedthod:(HMRequestType)httpMethod params:(NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure{
    
    NSMutableURLRequest *request;
    
    NSString *urlString;
    
    if (httpMethod == HMGET) {
        
        if (params) {
            //参数拼接url
            NSString *paramStr = [self dealWithParam:params];
            urlString = [urlStr stringByAppendingString:paramStr];
        }else{
            urlString = urlStr;
        }
        
        NSURL *url = [NSURL URLWithString:urlString];
        request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"GET";
        
    }else if (httpMethod == HMPOST){
        
        NSURL *url = [NSURL URLWithString:urlStr];
        request = [NSMutableURLRequest requestWithURL:url];
        //把字典中的参数进行拼接
        NSString *body = [self dealWithParam:params];
        NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
        //设置请求体
        [request setHTTPBody:bodyData];
        request.HTTPMethod = @"POST";
    }
    
    //设置超时时间
    request.timeoutInterval = self.interval !=0 ? self.interval : 5;
    
    NSLog(@"%ld",(long)self.interval);
    //设置请求头
    if (self.headerDic !=nil || ![self.headerDic isEqual:[NSNull null]]) {
        
        [self.headerDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj) {
                [request setValue:self.headerDic[key] forHTTPHeaderField:key] ;
            }
        }];
    }
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data) {
            //利用iOS自带原生JSON解析data数据 保存为Dictionary
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
            
            NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
            
            NSInteger code = [res statusCode];
            
            success(dict,dataStr,code);
        }else{
            failure(error);
        }
    }];
    [dataTask resume];
}

#pragma mark -- 拼接参数
- (NSString *)dealWithParam:(NSDictionary *)param
{
    NSArray *allkeys = [param allKeys];
    NSMutableString *result = [NSMutableString string];
    
    for (NSString *key in allkeys) {
        NSString *string = [NSString stringWithFormat:@"%@=%@&", key, param[key]];
        [result appendString:string];
    }
    return result;
}
@end

