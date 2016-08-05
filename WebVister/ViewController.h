//
//  ViewController.h
//  WebVister
//
//  Created by KennethDai on 7/25/16.
//  Copyright © 2016 KennethDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>

typedef NS_ENUM(NSInteger, WVMode) {
    WVDisplayDetails    = 0,
    WVDisplayOverview   = 1
};

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>


@end

