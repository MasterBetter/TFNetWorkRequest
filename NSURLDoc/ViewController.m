//
//  ViewController.m
//  NSURLDoc
//
//  Created by 吴腾飞 on 2018/12/20.
//  Copyright © 2018 Damon. All rights reserved.
//

#import "ViewController.h" 

#import "TFNetWorkRequest.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    NSString *url = @"https://m.baidu.com";
    
    
    TFNetWorkRequest *req = [[TFNetWorkRequest alloc] init] ;
    req.headerDic = @{@"User-Agent" : @"iphone 5s"};
    req.interval = 1;
    
    [req fetchWithUrl:url httpMedthod:HMPOST params:nil success:^(id responseObject, NSString * objectStr, NSInteger httpCode) {
        
        NSLog(@"nihao = %ld" , (long)httpCode) ;
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
     
    
}


@end
