//
//  WVSingleView.m
//  WebVister
//
//  Created by KennethDai on 8/5/16.
//  Copyright © 2016 KennethDai. All rights reserved.
//

#import "WVSingleView.h"

@interface WVSingleView (){
    
    UIWebView *singleWebView;
}

@end

@implementation WVSingleView


- (id)initWithURL:(NSString *)urlStr withFrame:(CGRect)frame {
    
    if (self = [super init])
    {
        self.bounds = [UIScreen mainScreen].bounds;
        
        singleWebView = [[UIWebView alloc] initWithFrame:self.bounds];
        [singleWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://baidu.com"]]];
        [self addSubview:singleWebView];
    }
    
    
    return self;
}



@end
